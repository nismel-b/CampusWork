/**
 * ADMIN CONTROLLERS (COMBINED)
 * 
 * Tous les controllers admin dans un seul fichier.
 */

const adminService = require('../services/adminService');
const userManagementService = require('../services/userManagementService');
const analyticsService = require('../services/analyticsService');
const systemConfigService = require('../services/systemConfigService');
const { successResponse } = require('../../../shared/utils/responseFormatter');

// ======================
// ADMIN GENERAL CONTROLLERS
// File: src/controllers/adminController.js
// ======================

exports.getAdminLogs = async (req, res, next) => {
  try {
    const filters = {
      adminUserId: req.query.adminUserId,
      targetUserId: req.query.targetUserId,
      actionType: req.query.actionType,
      status: req.query.status,
      startDate: req.query.startDate,
      endDate: req.query.endDate
    };

    const pagination = {
      page: req.query.page || 1,
      limit: req.query.limit || 50
    };

    const result = await adminService.getAdminLogs(filters, pagination);

    res.status(200).json(
      successResponse('Admin logs retrieved successfully', result.logs, result.pagination)
    );
  } catch (error) {
    next(error);
  }
};

exports.getLogsByAdmin = async (req, res, next) => {
  try {
    const { adminUserId } = req.params;
    const pagination = {
      page: req.query.page || 1,
      limit: req.query.limit || 50
    };

    const result = await adminService.getLogsByAdmin(adminUserId, pagination);

    res.status(200).json(
      successResponse('Logs retrieved successfully', result.logs, result.pagination)
    );
  } catch (error) {
    next(error);
  }
};

exports.getLogsByTargetUser = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const pagination = {
      page: req.query.page || 1,
      limit: req.query.limit || 50
    };

    const result = await adminService.getLogsByTargetUser(userId, pagination);

    res.status(200).json(
      successResponse('Logs retrieved successfully', result.logs, result.pagination)
    );
  } catch (error) {
    next(error);
  }
};

exports.getAdminStatistics = async (req, res, next) => {
  try {
    const { timeframe = '30d' } = req.query;

    const statistics = await adminService.getStatistics(timeframe);

    res.status(200).json(
      successResponse('Statistics retrieved successfully', { statistics })
    );
  } catch (error) {
    next(error);
  }
};

// ======================
// USER MANAGEMENT CONTROLLERS
// File: src/controllers/userManagementController.js
// ======================

exports.getAllUsers = async (req, res, next) => {
  try {
    const filters = {
      role: req.query.role,
      status: req.query.status,
      search: req.query.search,
      sortBy: req.query.sortBy,
      sortOrder: req.query.sortOrder
    };

    const pagination = {
      page: req.query.page || 1,
      limit: req.query.limit || 50
    };

    const result = await userManagementService.getAllUsers(filters, pagination);

    res.status(200).json(
      successResponse('Users retrieved successfully', result.users, result.pagination)
    );
  } catch (error) {
    next(error);
  }
};

exports.getUserById = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const user = await userManagementService.getUserById(userId);

    res.status(200).json(
      successResponse('User retrieved successfully', { user })
    );
  } catch (error) {
    next(error);
  }
};

exports.createUser = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const userData = req.body;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const user = await userManagementService.createUser(adminUserId, userData, requestInfo);

    res.status(201).json(
      successResponse('User created successfully', { user })
    );
  } catch (error) {
    next(error);
  }
};

exports.updateUser = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { userId } = req.params;
    const updateData = req.body;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const user = await userManagementService.updateUser(adminUserId, userId, updateData, requestInfo);

    res.status(200).json(
      successResponse('User updated successfully', { user })
    );
  } catch (error) {
    next(error);
  }
};

exports.deleteUser = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { userId } = req.params;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    await userManagementService.deleteUser(adminUserId, userId, requestInfo);

    res.status(200).json(
      successResponse('User deleted successfully')
    );
  } catch (error) {
    next(error);
  }
};

exports.suspendUser = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { userId } = req.params;
    const { reason } = req.body;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const user = await userManagementService.suspendUser(adminUserId, userId, reason, requestInfo);

    res.status(200).json(
      successResponse('User suspended successfully', { user })
    );
  } catch (error) {
    next(error);
  }
};

exports.activateUser = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { userId } = req.params;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const user = await userManagementService.activateUser(adminUserId, userId, requestInfo);

    res.status(200).json(
      successResponse('User activated successfully', { user })
    );
  } catch (error) {
    next(error);
  }
};

exports.changeUserRole = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { userId } = req.params;
    const { role } = req.body;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const user = await userManagementService.changeUserRole(adminUserId, userId, role, requestInfo);

    res.status(200).json(
      successResponse('User role changed successfully', { user })
    );
  } catch (error) {
    next(error);
  }
};

exports.resetUserPassword = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { userId } = req.params;
    const { newPassword } = req.body;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const result = await userManagementService.resetUserPassword(adminUserId, userId, newPassword, requestInfo);

    res.status(200).json(
      successResponse(result.message)
    );
  } catch (error) {
    next(error);
  }
};

exports.bulkOperation = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { operation, userIds, data } = req.body;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const results = await userManagementService.bulkOperation(adminUserId, operation, userIds, data, requestInfo);

    res.status(200).json(
      successResponse('Bulk operation completed', results)
    );
  } catch (error) {
    next(error);
  }
};

// ======================
// ANALYTICS CONTROLLERS
// File: src/controllers/analyticsController.js
// ======================

exports.getPlatformOverview = async (req, res, next) => {
  try {
    const overview = await analyticsService.getPlatformOverview();

    res.status(200).json(
      successResponse('Platform overview retrieved successfully', overview)
    );
  } catch (error) {
    next(error);
  }
};

exports.getUserGrowthStats = async (req, res, next) => {
  try {
    const { timeframe = '30d' } = req.query;

    const stats = await analyticsService.getUserGrowthStats(timeframe);

    res.status(200).json(
      successResponse('User growth stats retrieved successfully', stats)
    );
  } catch (error) {
    next(error);
  }
};

exports.getActivityStats = async (req, res, next) => {
  try {
    const { timeframe = '7d' } = req.query;

    const stats = await analyticsService.getActivityStats(timeframe);

    res.status(200).json(
      successResponse('Activity stats retrieved successfully', stats)
    );
  } catch (error) {
    next(error);
  }
};

exports.getTopUsers = async (req, res, next) => {
  try {
    const { metric = 'projects', limit = 10 } = req.query;

    const topUsers = await analyticsService.getTopUsers(metric, parseInt(limit));

    res.status(200).json(
      successResponse('Top users retrieved successfully', topUsers)
    );
  } catch (error) {
    next(error);
  }
};

exports.exportData = async (req, res, next) => {
  try {
    const { dataType, format = 'json' } = req.body;
    const filters = req.body.filters || {};

    const result = await analyticsService.exportData(dataType, format, filters);

    res.status(200).json(
      successResponse('Data export initiated', result)
    );
  } catch (error) {
    next(error);
  }
};

// ======================
// SYSTEM CONFIG CONTROLLERS
// File: src/controllers/systemConfigController.js
// ======================

exports.getAllConfigs = async (req, res, next) => {
  try {
    const { category } = req.query;

    const configs = await systemConfigService.getAllConfigs(category);

    res.status(200).json(
      successResponse('Configs retrieved successfully', configs)
    );
  } catch (error) {
    next(error);
  }
};

exports.getPublicConfigs = async (req, res, next) => {
  try {
    const configs = await systemConfigService.getPublicConfigs();

    res.status(200).json(
      successResponse('Public configs retrieved successfully', configs)
    );
  } catch (error) {
    next(error);
  }
};

exports.getConfigByKey = async (req, res, next) => {
  try {
    const { key } = req.params;

    const config = await systemConfigService.getConfigByKey(key);

    res.status(200).json(
      successResponse('Config retrieved successfully', { config })
    );
  } catch (error) {
    next(error);
  }
};

exports.setConfig = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { key, value, description, category, isPublic, isEditable } = req.body;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const config = await systemConfigService.setConfig(
      adminUserId,
      key,
      value,
      { description, category, isPublic, isEditable },
      requestInfo
    );

    res.status(201).json(
      successResponse('Config set successfully', { config })
    );
  } catch (error) {
    next(error);
  }
};

exports.updateConfig = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { key } = req.params;
    const { value } = req.body;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    const config = await systemConfigService.updateConfig(adminUserId, key, value, requestInfo);

    res.status(200).json(
      successResponse('Config updated successfully', { config })
    );
  } catch (error) {
    next(error);
  }
};

exports.deleteConfig = async (req, res, next) => {
  try {
    const adminUserId = req.user.userId;
    const { key } = req.params;
    const requestInfo = {
      ipAddress: req.ip,
      userAgent: req.get('user-agent')
    };

    await systemConfigService.deleteConfig(adminUserId, key, requestInfo);

    res.status(200).json(
      successResponse('Config deleted successfully')
    );
  } catch (error) {
    next(error);
  }
};
