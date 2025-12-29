
/**
 * HTTP proxy middleware for forwarding requests to microservices
 */
const { createProxyMiddleware } = require('http-proxy-middleware');
const { logger } = require('../middleware/logger');

/**
 * Get service name from request path
 */
const getServiceNameFromPath = (path) => {
  if (path.startsWith('/api/auth') || path.startsWith('/api/users')) {
    return 'auth-service';
  } else if (path.startsWith('/api/students')) {
    return 'student-service';
  } else if (path.startsWith('/api/lecturers')) {
    return 'lecturer-service';
  } else if (path.startsWith('/api/admin')) {
    return 'admin-service';
  } else if (path.startsWith('/api/projects')) {
    return 'project-service';
  }
  return 'unknown';
};

/**
 * Create proxy middleware for a route
 */
const createServiceProxy = (routeConfig) => {
  const timeoutMs = routeConfig.timeout || 5000;
  const proxyTimeoutMs = routeConfig.proxyTimeout || timeoutMs;

  return createProxyMiddleware({
    target: routeConfig.target,
    changeOrigin: true,
    pathRewrite: routeConfig.pathRewrite || {},
    timeout: timeoutMs,
    proxyTimeout: proxyTimeoutMs,
    secure: routeConfig.secure !== undefined ? routeConfig.secure : true,

    /**
     * Modify request before sending to service
     */
    onProxyReq: (proxyReq, req, res) => {
      // Add request ID for tracing
      if (req.id) {
        proxyReq.setHeader('X-Request-Id', req.id);
      }

      // Forward user information to microservice
      if (req.user) {
        proxyReq.setHeader('X-User-Id', req.user.userId);
        proxyReq.setHeader('X-User-Email', req.user.email);
        proxyReq.setHeader('X-User-Role', req.user.role);
      }

      // Forward original client IP
      const clientIp = req.ip ||
                      req.headers['x-forwarded-for'] ||
                      req.connection && req.connection.remoteAddress;
      if (clientIp) {
        proxyReq.setHeader('X-Forwarded-For', clientIp);
        proxyReq.setHeader('X-Real-IP', clientIp);
      }

      // Forward original host
      if (req.headers.host) {
        proxyReq.setHeader('X-Forwarded-Host', req.headers.host);
      }

      // Add gateway identifier
      proxyReq.setHeader('X-Gateway', 'campus-api-gateway');

      logger.debug('Proxying request', {
        requestId: req.id,
        method: req.method,
        originalUrl: req.originalUrl,
        target: routeConfig.target,
        userId: req.user?.userId,
        ip: clientIp
      });
    },

    /**
     * Modify response from service
     */
    onProxyRes: (proxyRes, req, res) => {
      try {
        // Add custom headers to response (only if headers not already sent)
        if (proxyRes && proxyRes.headers) {
          proxyRes.headers['x-proxied-by'] = 'campus-api-gateway';
          proxyRes.headers['x-service'] = getServiceNameFromPath(req.path);
          if (req.id) {
            proxyRes.headers['x-request-id'] = req.id;
          }
        }

        logger.debug('Proxy response received', {
          requestId: req.id,
          statusCode: proxyRes.statusCode,
          url: req.originalUrl,
          service: getServiceNameFromPath(req.path)
        });

        // Log slow responses
        const duration = Date.now() - (req.startTime || Date.now());
        if (duration > 1000) {
          logger.warn('Slow response detected', {
            requestId: req.id,
            url: req.originalUrl,
            duration: `${duration}ms`,
            service: getServiceNameFromPath(req.path)
          });
        }
      } catch (err) {
        logger.error('Error in onProxyRes handler', { error: err.message, stack: err.stack });
      }
    },

    /**
     * Handle proxy errors
     */
    onError: (err, req, res) => {
      const serviceName = getServiceNameFromPath(req.path);

      logger.error('Proxy error', {
        requestId: req.id,
        error: err.message,
        code: err.code,
        url: req.originalUrl,
        target: routeConfig.target,
        service: serviceName
      });

      // Send response only if headers not already sent
      if (res.headersSent) {
        // If headers are already sent, just end the response
        try {
          res.end();
        } catch (e) {
          logger.error('Failed to end response after headersSent', { error: e.message });
        }
        return;
      }

      // Handle specific error types
      if (err.code === 'ETIMEDOUT' || err.code === 'ECONNABORTED') {
        return res.status(504).json({
          success: false,
          message: 'Service timeout. Please try again.',
          service: serviceName,
          requestId: req.id
        });
      }

      if (err.code === 'ECONNREFUSED' || err.code === 'ENOTFOUND') {
        return res.status(503).json({
          success: false,
          message: 'Service temporarily unavailable. Please try again later.',
          service: serviceName,
          requestId: req.id
        });
      }

      if (err.code === 'ECONNRESET') {
        return res.status(502).json({
          success: false,
          message: 'Connection to service was reset. Please try again.',
          service: serviceName,
          requestId: req.id
        });
      }

      // Generic proxy error
      res.status(502).json({
        success: false,
        message: 'Bad gateway. Error communicating with service.',
        service: serviceName,
        requestId: req.id,
        ...(process.env.NODE_ENV === 'development' && {
          error: err.message,
          code: err.code
        })
      });
    },

    /**
     * Log provider for debugging
     */
    logProvider: () => {
      return {
        log: (message) => logger.debug(message),
        debug: (message) => logger.debug(message),
        info: (message) => logger.info(message),
        warn: (message) => logger.warn(message),
        error: (message) => logger.error(message)
      };
    }
  });
};

/**
 * Middleware to add start time for request duration tracking
 */
const addStartTime = (req, res, next) => {
  req.startTime = Date.now();
  next();
};

module.exports = {
  createServiceProxy,
  addStartTime,
  getServiceNameFromPath
};