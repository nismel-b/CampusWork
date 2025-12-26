/**
 * ADMIN SERVICE (Business Logic)
 * 
 * File: src/services/adminService.js
 * 
 * Logique métier générale pour les opérations admin.
 */

const { AdminLog } = require('../models');
const logger = require('../../../shared/utils/logger');

class AdminService {
  
  /**
   * LOG ADMIN ACTION
   * 
   * Enregistre une action administrative pour l'audit.
   */
  async logAction(actionData) {
    try {
      const log = await AdminLog.create({
        adminUserId: actionData.adminUserId,
        actionType: actionData.actionType,
        targetUserId: actionData.targetUserId || null,
        description: actionData.description,
        metadata: actionData.metadata || {},
        ipAddress: actionData.ipAddress || null,
        userAgent: actionData.userAgent || null,
        status: actionData.status || 'success',
        errorMessage: actionData.errorMessage || null
      });

      logger.info('Admin action logged', {
        logId: log.id,
        actionType: actionData.actionType,
        adminUserId: actionData.adminUserId
      });

      return log;
    } catch (error) {
      logger.error('Failed to log admin action', {
        error: error.message,
        actionData
      });
      // Ne pas throw pour éviter d'interrompre l'opération principale
    }
  }

  /**
   * GET ADMIN LOGS
   * 
   * Récupère les logs d'actions admin avec filtres et pagination.
   */
  async getAdminLogs(filters = {}, pagination = {}) {
    try {
      const {
        adminUserId,
        targetUserId,
        actionType,
        status,
        startDate,
        endDate
      } = filters;

      const {
        page = 1,
        limit = 50
      } = pagination;

      const offset = (page - 1) * limit;

      // Construire les conditions WHERE
      const whereClause = {};

      if (adminUserId) {
        whereClause.adminUserId = adminUserId;
      }

      if (targetUserId) {
        whereClause.targetUserId = targetUserId;
      }

      if (actionType) {
        whereClause.actionType = actionType;
      }

      if (status) {
        whereClause.status = status;
      }

      // Filtres de date
      if (startDate || endDate) {
        whereClause.created_at = {};
        if (startDate) {
          whereClause.created_at[Op.gte] = new Date(startDate);
        }
        if (endDate) {
          whereClause.created_at[Op.lte] = new Date(endDate);
        }
      }

      const { rows: logs, count: total } = await AdminLog.findAndCountAll({
        where: whereClause,
        limit: parseInt(limit),
        offset: parseInt(offset),
        order: [['created_at', 'DESC']]
      });

      return {
        logs,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total,
          totalPages: Math.ceil(total / limit)
        }
      };
    } catch (error) {
      logger.error('Failed to get admin logs', {
        error: error.message,
        filters
      });
      throw error;
    }
  }

  /**
   * GET LOGS BY ADMIN USER
   * 
   * Récupère tous les logs d'un admin spécifique.
   */
  async getLogsByAdmin(adminUserId, pagination = {}) {
    try {
      const { page = 1, limit = 50 } = pagination;

      const result = await AdminLog.getLogsByAdmin(adminUserId, { page, limit });

      return {
        logs: result.rows,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: result.count,
          totalPages: Math.ceil(result.count / limit)
        }
      };
    } catch (error) {
      logger.error('Failed to get logs by admin', {
        adminUserId,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * GET LOGS BY TARGET USER
   * 
   * Récupère tous les logs concernant un utilisateur spécifique.
   */
  async getLogsByTargetUser(targetUserId, pagination = {}) {
    try {
      const { page = 1, limit = 50 } = pagination;

      const result = await AdminLog.getLogsByTargetUser(targetUserId, { page, limit });

      return {
        logs: result.rows,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: result.count,
          totalPages: Math.ceil(result.count / limit)
        }
      };
    } catch (error) {
      logger.error('Failed to get logs by target user', {
        targetUserId,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * GET ADMIN STATISTICS
   * 
   * Statistiques globales sur les actions admin.
   */
  async getStatistics(timeframe = '30d') {
    try {
      const { Op } = require('sequelize');
      
      // Calculer la date de début selon le timeframe
      const now = new Date();
      let startDate;
      
      switch (timeframe) {
        case '24h':
          startDate = new Date(now - 24 * 60 * 60 * 1000);
          break;
        case '7d':
          startDate = new Date(now - 7 * 24 * 60 * 60 * 1000);
          break;
        case '30d':
          startDate = new Date(now - 30 * 24 * 60 * 60 * 1000);
          break;
        case '90d':
          startDate = new Date(now - 90 * 24 * 60 * 60 * 1000);
          break;
        default:
          startDate = new Date(now - 30 * 24 * 60 * 60 * 1000);
      }

      const [
        totalActions,
        successfulActions,
        failedActions,
        actionsByType,
        mostActiveAdmins
      ] = await Promise.all([
        // Total actions
        AdminLog.count({
          where: {
            created_at: { [Op.gte]: startDate }
          }
        }),

        // Successful actions
        AdminLog.count({
          where: {
            created_at: { [Op.gte]: startDate },
            status: 'success'
          }
        }),

        // Failed actions
        AdminLog.count({
          where: {
            created_at: { [Op.gte]: startDate },
            status: 'failed'
          }
        }),

        // Actions by type
        AdminLog.findAll({
          attributes: [
            'action_type',
            [sequelize.fn('COUNT', sequelize.col('log_id')), 'count']
          ],
          where: {
            created_at: { [Op.gte]: startDate }
          },
          group: ['action_type'],
          order: [[sequelize.literal('count'), 'DESC']]
        }),

        // Most active admins
        AdminLog.findAll({
          attributes: [
            'admin_user_id',
            [sequelize.fn('COUNT', sequelize.col('log_id')), 'count']
          ],
          where: {
            created_at: { [Op.gte]: startDate }
          },
          group: ['admin_user_id'],
          order: [[sequelize.literal('count'), 'DESC']],
          limit: 10
        })
      ]);

      return {
        timeframe,
        totalActions,
        successfulActions,
        failedActions,
        successRate: totalActions > 0 ? (successfulActions / totalActions * 100).toFixed(2) : 0,
        actionsByType,
        mostActiveAdmins
      };
    } catch (error) {
      logger.error('Failed to get admin statistics', {
        error: error.message
      });
      throw error;
    }
  }
}

module.exports = new AdminService();
