/** 
 * Rate limiting middleware
 */
const rateLimit = require('express-rate-limit');
const rateLimitConfig = require('../config/rateLimit');
const { logger } = require('./logger');

/**
 * Create rate limiter with logging
 */
const createRateLimiter = (config) => {
  return rateLimit({
    ...config,
    handler: (req, res) => {
      logger.warn('Rate limit exceeded', {
        ip: req.ip,
        path: req.path,
        method: req.method,
        userId: req.user?.userId
      });

      res.status(429).json(config.message);
    },
    skip: (req) => {
      // Skip rate limiting for health checks
      return req.path === '/health' || req.path === '/ready' || req.path === '/live';
    }
  });
};

/**
 * General API rate limiter
 */
const apiLimiter = createRateLimiter(rateLimitConfig.api);

/**
 * Strict rate limiter for auth endpoints
 */
const authLimiter = createRateLimiter(rateLimitConfig.auth);

/**
 * Upload rate limiter
 */
const uploadLimiter = createRateLimiter(rateLimitConfig.upload);

/**
 * Admin rate limiter (higher limits)
 */
const adminLimiter = createRateLimiter(rateLimitConfig.admin);

/**
 * Dynamic rate limiter based on user role
 */
const dynamicRateLimiter = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    return adminLimiter(req, res, next);
  }
  return apiLimiter(req, res, next);
};

module.exports = {
  apiLimiter,
  authLimiter,
  uploadLimiter,
  adminLimiter,
  dynamicRateLimiter
};

