/**
 * Request validation utilities
 */
const { validationResult } = require('express-validator');

/**
 * Validate request
 */
const validateRequest = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: err.param,
        message: err.msg,
        value: err.value
      }))
    });
  }
  
  next();
};

/**
 * Common validation rules
 */
const commonValidations = {
  email: {
    isEmail: {
      errorMessage: 'Invalid email format'
    },
    normalizeEmail: true
  },
  
  password: {
    isLength: {
      options: { min: 8 },
      errorMessage: 'Password must be at least 8 characters long'
    }
  },
  
  uuid: {
    isUUID: {
      errorMessage: 'Invalid UUID format'
    }
  },
  
  pagination: {
    page: {
      optional: true,
      isInt: {
        options: { min: 1 },
        errorMessage: 'Page must be a positive integer'
      },
      toInt: true
    },
    limit: {
      optional: true,
      isInt: {
        options: { min: 1, max: 100 },
        errorMessage: 'Limit must be between 1 and 100'
      },
      toInt: true
    }
  }
};

module.exports = {
  validateRequest,
  commonValidations
};
