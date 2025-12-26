 const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { validationRules, handleValidationErrors } = require('../middleware/validationMiddleware');
const { authenticate } = require('../middleware/authMiddleware');

// Public routes
router.post(
  '/register',
  validationRules.register,
  handleValidationErrors,
  authController.register
);

router.post(
  '/login',
  validationRules.login,
  handleValidationErrors,
  authController.login
);

router.post(
  '/refresh-token',
  authController.refreshToken
);

router.get(
  '/verify-email/:token',
  validationRules.verifyEmail,
  handleValidationErrors,
  authController.verifyEmail
);

router.post(
  '/forgot-password',
  validationRules.requestPasswordReset,
  handleValidationErrors,
  authController.requestPasswordReset
);

router.post(
  '/reset-password/:token',
  validationRules.resetPassword,
  handleValidationErrors,
  authController.resetPassword
);

// Protected routes
router.post(
  '/logout',
  authenticate,
  authController.logout
);

router.get(
  '/me',
  authenticate,
  authController.getCurrentUser
);

// Internal route for service-to-service communication
router.post(
  '/validate',
  authController.validateUser
);

module.exports = router;