/**
 * MAIN ADMIN ROUTER
 * 
 * File: src/routes/index.js
 * 
 * Point d'entrée principal pour toutes les routes admin.
 */

const express = require('express');
const router = express.Router();

const adminController = require('../controllers/adminController');
const userManagementController = require('../controllers/adminController'); // Combined controller
const analyticsController = require('../controllers/adminController'); // Combined controller
const systemConfigController = require('../controllers/adminController'); // Combined controller

const {
  verifyToken,
  requireAdmin,
  validateCreateUser,
  validateUpdateUser,
  validateSuspendUser,
  validateChangeRole,
  validateResetPassword,
  validateBulkOperation,
  validateSetConfig,
  validateUpdateConfig,
  validateUserId,
  validatePagination
} = require('../middleware/authMiddleware');

/**
 * Apply authentication middleware to all routes
 */
router.use(verifyToken);
router.use(requireAdmin);

// ======================
// ADMIN LOGS ROUTES
// ======================

/**
 * GET /api/admin/logs
 * Get all admin logs with filters
 */
router.get(
  '/logs',
  validatePagination,
  adminController.getAdminLogs
);

/**
 * GET /api/admin/logs/admin/:adminUserId
 * Get logs by admin user
 */
router.get(
  '/logs/admin/:adminUserId',
  validateUserId,
  validatePagination,
  adminController.getLogsByAdmin
);

/**
 * GET /api/admin/logs/user/:userId
 * Get logs by target user
 */
router.get(
  '/logs/user/:userId',
  validateUserId,
  validatePagination,
  adminController.getLogsByTargetUser
);

/**
 * GET /api/admin/logs/statistics
 * Get admin action statistics
 */
router.get(
  '/logs/statistics',
  adminController.getAdminStatistics
);

// ======================
// USER MANAGEMENT ROUTES
// ======================

/**
 * GET /api/admin/users
 * Get all users
 */
router.get(
  '/users',
  validatePagination,
  userManagementController.getAllUsers
);

/**
 * GET /api/admin/users/:userId
 * Get user by ID
 */
router.get(
  '/users/:userId',
  validateUserId,
  userManagementController.getUserById
);

/**
 * POST /api/admin/users
 * Create new user
 */
router.post(
  '/users',
  validateCreateUser,
  userManagementController.createUser
);

/**
 * PUT /api/admin/users/:userId
 * Update user
 */
router.put(
  '/users/:userId',
  validateUserId,
  validateUpdateUser,
  userManagementController.updateUser
);

/**
 * DELETE /api/admin/users/:userId
 * Delete user
 */
router.delete(
  '/users/:userId',
  validateUserId,
  userManagementController.deleteUser
);

/**
 * POST /api/admin/users/:userId/suspend
 * Suspend user
 */
router.post(
  '/users/:userId/suspend',
  validateUserId,
  validateSuspendUser,
  userManagementController.suspendUser
);

/**
 * POST /api/admin/users/:userId/activate
 * Activate user
 */
router.post(
  '/users/:userId/activate',
  validateUserId,
  userManagementController.activateUser
);

/**
 * PATCH /api/admin/users/:userId/role
 * Change user role
 */
router.patch(
  '/users/:userId/role',
  validateUserId,
  validateChangeRole,
  userManagementController.changeUserRole
);

/**
 * POST /api/admin/users/:userId/reset-password
 * Reset user password
 */
router.post(
  '/users/:userId/reset-password',
  validateUserId,
  validateResetPassword,
  userManagementController.resetUserPassword
);

/**
 * POST /api/admin/users/bulk
 * Bulk operations on users
 */
router.post(
  '/users/bulk',
  validateBulkOperation,
  userManagementController.bulkOperation
);

// ======================
// ANALYTICS ROUTES
// ======================

/**
 * GET /api/admin/analytics/overview
 * Get platform overview
 */
router.get(
  '/analytics/overview',
  analyticsController.getPlatformOverview
);

/**
 * GET /api/admin/analytics/growth
 * Get user growth statistics
 */
router.get(
  '/analytics/growth',
  analyticsController.getUserGrowthStats
);

/**
 * GET /api/admin/analytics/activity
 * Get activity statistics
 */
router.get(
  '/analytics/activity',
  analyticsController.getActivityStats
);

/**
 * GET /api/admin/analytics/top-users
 * Get top users
 */
router.get(
  '/analytics/top-users',
  analyticsController.getTopUsers
);

/**
 * POST /api/admin/analytics/export
 * Export platform data
 */
router.post(
  '/analytics/export',
  analyticsController.exportData
);

// ======================
// SYSTEM CONFIG ROUTES
// ======================

/**
 * GET /api/admin/config
 * Get all system configs
 */
router.get(
  '/config',
  systemConfigController.getAllConfigs
);

/**
 * GET /api/admin/config/public
 * Get public configs (can be accessed without admin)
 */
router.get(
  '/config/public',
  systemConfigController.getPublicConfigs
);

/**
 * GET /api/admin/config/:key
 * Get config by key
 */
router.get(
  '/config/:key',
  systemConfigController.getConfigByKey
);

/**
 * POST /api/admin/config
 * Create or update config
 */
router.post(
  '/config',
  validateSetConfig,
  systemConfigController.setConfig
);

/**
 * PUT /api/admin/config/:key
 * Update config
 */
router.put(
  '/config/:key',
  validateUpdateConfig,
  systemConfigController.updateConfig
);

/**
 * DELETE /api/admin/config/:key
 * Delete config
 */
router.delete(
  '/config/:key',
  systemConfigController.deleteConfig
);

module.exports = router;
