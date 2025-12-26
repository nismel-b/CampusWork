const { body, param, validationResult } = require('express-validator');
const { ValidationError } = require('../../../shared/utils/errorHandler');

// Validation rules
const validationRules = {
  register: [
    body('email')
      .isEmail().withMessage('Valid email is required')
      .normalizeEmail(),
    body('password')
      .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]/)
      .withMessage('Password must contain uppercase, lowercase, number and special character'),
    body('firstName')
      .trim()
      .isLength({ min: 2, max: 100 }).withMessage('First name must be 2-100 characters'),
    body('lastName')
      .trim()
      .isLength({ min: 2, max: 100 }).withMessage('Last name must be 2-100 characters'),
    body('role')
      .isIn(['student', 'lecturer', 'admin']).withMessage('Invalid role')
  ],

  login: [
    body('email')
      .isEmail().withMessage('Valid email is required')
      .normalizeEmail(),
    body('password')
      .notEmpty().withMessage('Password is required')
  ],

  requestPasswordReset: [
    body('email')
      .isEmail().withMessage('Valid email is required')
      .normalizeEmail()
  ],

  resetPassword: [
    param('token')
      .notEmpty().withMessage('Reset token is required'),
    body('password')
      .isLength({ min: 8 }).withMessage('Password must be at least 8 characters')
      .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#])[A-Za-z\d@$!%*?&#]/)
      .withMessage('Password must contain uppercase, lowercase, number and special character')
  ],

  verifyEmail: [
    param('token')
      .notEmpty().withMessage('Verification token is required')
  ]
};

// Validation error handler
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(err => ({
      field: err.param,
      message: err.msg
    }));

    throw new ValidationError('Validation failed', errorMessages);
  }
  
  next();
};

module.exports = {
  validationRules,
  handleValidationErrors
};
