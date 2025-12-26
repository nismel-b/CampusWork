/**
 * MIDDLEWARE - ADMIN SERVICE
 * 
 * Authentication et validation pour Admin Service.
 */

const jwt = require('jsonwebtoken');
const { body, param, query, validationResult } = require('express-validator');
const { UnauthorizedError, ForbiddenError } = require('../../../shared/utils/errorHandler');

// ======================
// AUTHENTICATION
// ======================

exports.verifyToken = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedError('No token provided');
    }

    const token = authHeader.substring(7);
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    req.user = {
      userId: decoded.userId,
      email: decoded.email,
      role: decoded.role
    };

    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      next(new UnauthorizedError('Invalid token'));
    } else if (error.name === 'TokenExpiredError') {
      next(new UnauthorizedError('Token expired'));
    } else {
      next(error);
    }
  }
};

exports.requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return next(new ForbiddenError('Admin access required'));
  }
  next();
};

// ======================
// VALIDATION
// ======================

const validateResults = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array()
    });
  }
  next();
};

// User Management Validations
exports.validateCreateUser = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }),
  body('firstName').isLength({ min: 2, max: 50 }),
  body('lastName').isLength({ min: 2, max: 50 }),
  body('role').isIn(['student', 'lecturer', 'admin']),
  validateResults
];

exports.validateUpdateUser = [
  body('email').optional().isEmail().normalizeEmail(),
  body('firstName').optional().isLength({ min: 2, max: 50 }),
  body('lastName').optional().isLength({ min: 2, max: 50 }),
  validateResults
];

exports.validateSuspendUser = [
  body('reason').notEmpty().isLength({ min: 5, max: 500 }),
  validateResults
];

exports.validateChangeRole = [
  body('role').isIn(['student', 'lecturer', 'admin']),
  validateResults
];

exports.validateResetPassword = [
  body('newPassword').isLength({ min: 8 }),
  validateResults
];

exports.validateBulkOperation = [
  body('operation').isIn(['suspend', 'activate', 'delete', 'changeRole']),
  body('userIds').isArray({ min: 1 }),
  validateResults
];

// System Config Validations
exports.validateSetConfig = [
  body('key').notEmpty().isLength({ min: 2, max: 100 }),
  body('value').notEmpty(),
  body('category').optional().isIn(['general', 'security', 'email', 'storage', 'notifications', 'features', 'limits', 'other']),
  validateResults
];

exports.validateUpdateConfig = [
  body('value').notEmpty(),
  validateResults
];

// Generic Validations
exports.validateUserId = [
  param('userId').isUUID(),
  validateResults
];

exports.validatePagination = [
  query('page').optional().isInt({ min: 1 }),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  validateResults
];
