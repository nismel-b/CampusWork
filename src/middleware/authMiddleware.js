/**
 * Authentication and authorization middleware
 */
const jwt = require('jsonwebtoken');
const securityConfig = require('../config/security');
const { logger } = require('./logger');

/**
 * Verify JWT Token
 * 
 * Validates JWT token from Authorization header
 */
const verifyToken = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'No token provided. Please authenticate.'
      });
    }

    const token = authHeader.substring(7); // Remove "Bearer "
    
    // Verify token
    const decoded = jwt.verify(token, securityConfig.jwt.secret, {
      algorithms: securityConfig.jwt.algorithms
    });

    // Add user info to request
    req.user = {
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role,
      iat: decoded.iat,
      exp: decoded.exp
    };

    logger.debug('Token verified', {
      userId: req.user.userId,
      role: req.user.role
    });

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        message: 'Invalid token. Please login again.'
      });
    } else if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        message: 'Token expired. Please login again.',
        expiredAt: error.expiredAt
      });
    } else {
      logger.error('Token verification error', {
        error: error.message,
        stack: error.stack
      });
      return res.status(500).json({
        success: false,
        message: 'Error verifying token'
      });
    }
  }
};

/**
 * Optional Authentication
 * 
 * Tries to authenticate but doesn't fail if no token
 * Used for routes that work with or without authentication
 */
const optionalAuth = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      
      try {
        const decoded = jwt.verify(token, securityConfig.jwt.secret, {
          algorithms: securityConfig.jwt.algorithms
        });

        req.user = {
          userId: decoded.userId,
          email: decoded.email,
          role: decoded.role
        };

        logger.debug('Optional auth: Token verified', {
          userId: req.user.userId
        });
      } catch (error) {
        // Invalid token but continue as unauthenticated
        logger.debug('Optional auth: Invalid token, continuing as guest');
      }
    }

    next();
  } catch (error) {
    logger.error('Optional auth error', { error: error.message });
    next(); // Continue anyway
  }
};

/**
 * Check Role
 * 
 * Verifies user has one of the allowed roles
 */
const checkRole = (allowedRoles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: 'Authentication required'
      });
    }

    if (!allowedRoles.includes(req.user.role)) {
      logger.warn('Unauthorized role access attempt', {
        userId: req.user.userId,
        role: req.user.role,
        allowedRoles,
        path: req.path
      });

      return res.status(403).json({
        success: false,
        message: `Access denied. Required role: ${allowedRoles.join(' or ')}`,
        userRole: req.user.role
      });
    }

    next();
  };
};

/**
 * Require Admin
 * 
 * Shortcut for admin-only routes
 */
const requireAdmin = checkRole(['admin']);

/**
 * Require Student
 * 
 * Shortcut for student routes
 */
const requireStudent = checkRole(['student', 'admin']);

/**
 * Require Lecturer
 * 
 * Shortcut for lecturer routes
 */
const requireLecturer = checkRole(['lecturer', 'admin']);

module.exports = {
  verifyToken,
  optionalAuth,
  checkRole,
  requireAdmin,
  requireStudent,
  requireLecturer
};

