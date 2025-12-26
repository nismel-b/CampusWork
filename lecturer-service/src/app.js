/**
 * EXPRESS APP CONFIGURATION - LECTURER SERVICE
 * 
 * Configure l'application Express avec tous les middleware et routes.
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');

const lecturerRoutes = require('./routes/lecturerRoutes');
const { errorHandler } = require('../../../shared/utils/errorHandler');
const logger = require('../../../shared/utils/logger');

const app = express();

/**
 * ======================
 * SECURITY MIDDLEWARE
 * ======================
 */

/**
 * HELMET
 * Sets security-related HTTP headers.
 */
app.use(helmet());

/**
 * CORS (Cross-Origin Resource Sharing)
 * Allows frontend to make requests to this API.
 */
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

/**
 * ======================
 * BODY PARSING MIDDLEWARE
 * ======================
 */

/**
 * Parse JSON bodies (application/json)
 */
app.use(express.json({ limit: '10mb' }));

/**
 * Parse URL-encoded bodies (application/x-www-form-urlencoded)
 */
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

/**
 * Parse cookies
 */
app.use(cookieParser());

/**
 * ======================
 * LOGGING MIDDLEWARE
 * ======================
 */

/**
 * MORGAN
 * HTTP request logger
 */
app.use(morgan('combined', {
  stream: {
    write: (message) => logger.info(message.trim())
  }
}));

/**
 * ======================
 * HEALTH CHECK ENDPOINTS
 * ======================
 */

/**
 * HEALTH CHECK
 * GET /health
 * 
 * Simple endpoint to check if service is running.
 */
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'lecturer-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

/**
 * READINESS CHECK
 * GET /ready
 * 
 * Checks if service is ready to accept traffic.
 */
app.get('/ready', async (req, res) => {
  try {
    const { sequelize } = require('./config/database');
    
    // Test database connection
    await sequelize.authenticate();
    
    res.status(200).json({
      status: 'ready',
      service: 'lecturer-service',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Readiness check failed', { error: error.message });
    
    res.status(503).json({
      status: 'not ready',
      service: 'lecturer-service',
      database: 'disconnected',
      error: error.message
    });
  }
});

/**
 * LIVENESS CHECK
 * GET /live
 * 
 * Checks if service process is alive.
 */
app.get('/live', (req, res) => {
  res.status(200).json({
    status: 'alive',
    service: 'lecturer-service',
    timestamp: new Date().toISOString()
  });
});

/**
 * ======================
 * API ROUTES
 * ======================
 */

/**
 * Mount lecturer routes at /api/lecturers
 */
app.use('/api/lecturers', lecturerRoutes);

/**
 * ======================
 * 404 HANDLER
 * ======================
 */

/**
 * Handle undefined routes
 */
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.path,
    method: req.method
  });
});

/**
 * ======================
 * ERROR HANDLER
 * ======================
 */

/**
 * Global error handler
 * MUST be last middleware
 */
app.use(errorHandler);

/**
 * ======================
 * EXPORTS
 * ======================
 */

module.exports = app;
