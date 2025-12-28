/** 
 * Express application setup
 */
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const cookieParser = require('cookie-parser');

// Config
const corsConfig = require('./config/cors');
const securityConfig = require('./config/security');
const routes = require('./config/routes');

// Middleware
const { verifyToken, optionalAuth, checkRole } = require('./middleware/authMiddleware');
const { 
  apiLimiter, 
  authLimiter, 
  uploadLimiter,
  dynamicRateLimiter 
} = require('./middleware/rateLimiter');
const { requestLogger, errorLogger } = require('./middleware/logger');
const { notFoundHandler, errorHandler } = require('./middleware/errorHandler');
const { requestId } = require('./middleware/requestId');

// Proxy
const { createServiceProxy, addStartTime } = require('./proxy/proxyHandler');
const { healthCheckHandler } = require('./proxy/healthCheck');

const app = express();

// Trust proxy (for production behind load balancer)
if (securityConfig.trustedProxies.length > 0) {
  app.set('trust proxy', securityConfig.trustedProxies);
} else {
  app.set('trust proxy', true);
}

/**
 * ======================
 * SECURITY MIDDLEWARE
 * ======================
 */

// Helmet - Security headers
app.use(helmet(securityConfig.helmet));

// CORS - Cross-Origin Resource Sharing
app.use(cors(corsConfig));

// Compression - Response compression
app.use(compression());

/**
 * ======================
 * BODY PARSING MIDDLEWARE
 * ======================
 */

// JSON body parser
app.use(express.json(securityConfig.bodyParser.json));

// URL-encoded body parser
app.use(express.urlencoded(securityConfig.bodyParser.urlencoded));

// Cookie parser
app.use(cookieParser());

/**
 * ======================
 * REQUEST TRACKING
 * ======================
 */

// Add unique request ID
app.use(requestId);

// Add start time for duration tracking
app.use(addStartTime);

// Request logging
app.use(requestLogger);

/**
 * ======================
 * HEALTH CHECK ENDPOINTS
 * ======================
 */

/**
 * Simple health check
 * GET /health
 */
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'api-gateway',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    requestId: req.id
  });
});

/**
 * Readiness check (includes service health)
 * GET /ready
 */
app.get('/ready', healthCheckHandler);

/**
 * Liveness check
 * GET /live
 */
app.get('/live', (req, res) => {
  res.status(200).json({
    status: 'alive',
    service: 'api-gateway',
    timestamp: new Date().toISOString(),
    requestId: req.id
  });
});

/**
 * ======================
 * RATE LIMITING
 * ======================
 */

// Apply general rate limiter to all API routes
app.use('/api', dynamicRateLimiter);

// Strict rate limiter for auth endpoints
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
app.use('/api/auth/forgot-password', authLimiter);

// Upload rate limiter for file operations
app.use('/api/projects/:projectId/files', uploadLimiter);

/**
 * ======================
 * ROUTE SETUP WITH PROXY
 * ======================
 */

// Setup routes from configuration
routes.forEach(route => {
  const middleware = [];

  // Add authentication middleware if required
  if (route.auth === true) {
    middleware.push(verifyToken);
  } else if (route.auth === 'optional') {
    middleware.push(optionalAuth);
  }

  // Add role check if specified
  if (route.roles && route.roles.length > 0) {
    middleware.push(checkRole(route.roles));
  }

  // Create proxy middleware
  const proxy = createServiceProxy(route);

  // Apply route with middleware and proxy
  app.use(route.path, ...middleware, proxy);
});

/**
 * ======================
 * ERROR HANDLING
 * ======================
 */

// Error logger
app.use(errorLogger);

// 404 handler
app.use(notFoundHandler);

// Global error handler (must be last)
app.use(errorHandler);

module.exports = app;
