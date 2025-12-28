/**
 * Error handling middleware
 */
const { logger } = require('./logger');

/**
 * Not Found Handler
 */
const notFoundHandler = (req, res) => {
  logger.warn('Route not found', {
    method: req.method,
    url: req.originalUrl,
    ip: req.ip
  });

  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.originalUrl,
    method: req.method
  });
};

/**
 * Global Error Handler
 */
const errorHandler = (err, req, res, next) => {
  // Log error
  logger.error('Error handler caught error', {
    error: err.message,
    stack: err.stack,
    url: req.originalUrl,
    method: req.method,
    userId: req.user?.userId
  });

  // Default error
  let statusCode = err.statusCode || 500;
  let message = err.message || 'Internal server error';

  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation error';
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    message = 'Unauthorized';
  } else if (err.name === 'ForbiddenError') {
    statusCode = 403;
    message = 'Forbidden';
  } else if (err.name === 'NotFoundError') {
    statusCode = 404;
    message = 'Resource not found';
  } else if (err.code === 'ECONNREFUSED') {
    statusCode = 503;
    message = 'Service unavailable';
  } else if (err.code === 'ETIMEDOUT') {
    statusCode = 504;
    message = 'Gateway timeout';
  }

  // Don't leak error details in production
  const response = {
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && {
      error: err.message,
      stack: err.stack
    })
  };

  res.status(statusCode).json(response);
};

module.exports = {
  notFoundHandler,
  errorHandler
};

