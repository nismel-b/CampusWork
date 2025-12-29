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
// securityConfig.trustedProxies expected to be an array (default provided in config/security)
if (Array.isArray(securityConfig.trustedProxies) && securityConfig.trustedProxies.length > 0) {
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
 *
 * IMPORTANT: placer les rate-limiters spécifiques AVANT la règle générale ('/api')
 * pour éviter que la règle générale ne capte tout et rende inopérante la règle spécifique.
 */

// Strict rate limiter for auth endpoints (do this before generic api limiter)
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
app.use('/api/auth/forgot-password', authLimiter);

// Upload rate limiter for file operations (specific)
app.use('/api/projects/:projectId/files', uploadLimiter);

// Apply general rate limiter to all API routes (after specifics)
app.use('/api', dynamicRateLimiter);

/**
 * ======================
 * ROUTE SETUP WITH PROXY
 * ======================
 */

// Validate routes is an array
if (!Array.isArray(routes)) {
  // prefer to fail fast in startup so misconfiguration is obvious
  throw new Error('Route configuration invalid: routes must be an array');
}

routes.forEach(route => {
  const middleware = [];

  // Add authentication middleware if required
  if (route.auth === true) {
    middleware.push(verifyToken);
  } else if (route.auth === 'optional') {
    middleware.push(optionalAuth);
  }

  // Add role check if specified
  if (route.roles && Array.isArray(route.roles) && route.roles.length > 0) {
    middleware.push(checkRole(route.roles));
  }

  // If the route config is invalid (missing target), provide a friendly 502 response
  if (!route.target) {
    app.use(route.path, ...middleware, (req, res) => {
      // This route is misconfigured on the gateway
      return res.status(502).json({
        success: false,
        message: 'Bad gateway: target service not configured',
        path: route.path,
        requestId: req.id
      });
    });
    return;
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