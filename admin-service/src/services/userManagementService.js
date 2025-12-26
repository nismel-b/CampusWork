/**
 * USER MANAGEMENT SERVICE
 * 
 * File: src/services/userManagementService.js
 * 
 * Gestion des utilisateurs par les admins (CRUD, suspension, etc.).
 */

const axios = require('axios');
const bcrypt = require('bcrypt');
const adminService = require('./adminService');
const logger = require('../../../shared/utils/logger');
const {
  NotFoundError,
  ValidationError,
  ConflictError
} = require('../../../shared/utils/errorHandler');

class UserManagementService {
  
  /**
   * GET ALL USERS
   * 
   * Récupère tous les utilisateurs avec filtres et pagination.
   */
  async getAllUsers(filters = {}, pagination = {}) {
    try {
      const {
        role,
        status,
        search,
        sortBy = 'created_at',
        sortOrder = 'DESC'
      } = filters;

      const {
        page = 1,
        limit = 50
      } = pagination;

      // Appeler Auth Service
      const response = await axios.get(
        `${process.env.AUTH_SERVICE_URL}/api/admin/users`,
        {
          params: {
            role,
            status,
            search,
            sortBy,
            sortOrder,
            page,
            limit
          },
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`
          }
        }
      );

      return response.data.data;
    } catch (error) {
      logger.error('Failed to get all users', {
        error: error.message
      });
      throw new Error('Failed to retrieve users');
    }
  }

  /**
   * GET USER BY ID
   * 
   * Récupère un utilisateur spécifique avec tous ses détails.
   */
  async getUserById(userId) {
    try {
      const response = await axios.get(
        `${process.env.AUTH_SERVICE_URL}/api/users/${userId}`,
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`
          }
        }
      );

      return response.data.data;
    } catch (error) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User not found');
      }
      logger.error('Failed to get user by ID', {
        userId,
        error: error.message
      });
      throw new Error('Failed to retrieve user');
    }
  }

  /**
   * CREATE USER (ADMIN)
   * 
   * Crée un nouvel utilisateur (sans inscription).
   */
  async createUser(adminUserId, userData, requestInfo = {}) {
    try {
      // Appeler Auth Service pour créer l'utilisateur
      const response = await axios.post(
        `${process.env.AUTH_SERVICE_URL}/api/admin/users`,
        userData,
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const newUser = response.data.data;

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'user_created',
        targetUserId: newUser.userId,
        description: `Created new user: ${newUser.email} with role ${newUser.role}`,
        metadata: {
          email: newUser.email,
          role: newUser.role,
          firstName: newUser.firstName,
          lastName: newUser.lastName
        },
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('User created by admin', {
        adminUserId,
        newUserId: newUser.userId
      });

      return newUser;
    } catch (error) {
      if (error.response?.status === 409) {
        throw new ConflictError('Email already exists');
      }
      logger.error('Failed to create user', {
        adminUserId,
        error: error.message
      });
      throw new Error('Failed to create user');
    }
  }

  /**
   * UPDATE USER
   * 
   * Met à jour les informations d'un utilisateur.
   */
  async updateUser(adminUserId, userId, updateData, requestInfo = {}) {
    try {
      const response = await axios.put(
        `${process.env.AUTH_SERVICE_URL}/api/admin/users/${userId}`,
        updateData,
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`,
            'Content-Type': 'application/json'
          }
        }
      );

      const updatedUser = response.data.data;

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'user_updated',
        targetUserId: userId,
        description: `Updated user: ${updatedUser.email}`,
        metadata: {
          updatedFields: Object.keys(updateData),
          changes: updateData
        },
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('User updated by admin', {
        adminUserId,
        userId
      });

      return updatedUser;
    } catch (error) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User not found');
      }
      logger.error('Failed to update user', {
        adminUserId,
        userId,
        error: error.message
      });
      throw new Error('Failed to update user');
    }
  }

  /**
   * DELETE USER
   * 
   * Supprime un utilisateur (soft delete).
   */
  async deleteUser(adminUserId, userId, requestInfo = {}) {
    try {
      const response = await axios.delete(
        `${process.env.AUTH_SERVICE_URL}/api/admin/users/${userId}`,
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`
          }
        }
      );

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'user_deleted',
        targetUserId: userId,
        description: `Deleted user: ${userId}`,
        metadata: {},
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('User deleted by admin', {
        adminUserId,
        userId
      });

      return { success: true };
    } catch (error) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User not found');
      }
      logger.error('Failed to delete user', {
        adminUserId,
        userId,
        error: error.message
      });
      throw new Error('Failed to delete user');
    }
  }

  /**
   * SUSPEND USER
   * 
   * Suspend un utilisateur (désactive son compte).
   */
  async suspendUser(adminUserId, userId, reason, requestInfo = {}) {
    try {
      const response = await axios.post(
        `${process.env.AUTH_SERVICE_URL}/api/admin/users/${userId}/suspend`,
        { reason },
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`,
            'Content-Type': 'application/json'
          }
        }
      );

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'user_suspended',
        targetUserId: userId,
        description: `Suspended user: ${userId}`,
        metadata: { reason },
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('User suspended by admin', {
        adminUserId,
        userId,
        reason
      });

      return response.data.data;
    } catch (error) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User not found');
      }
      logger.error('Failed to suspend user', {
        adminUserId,
        userId,
        error: error.message
      });
      throw new Error('Failed to suspend user');
    }
  }

  /**
   * ACTIVATE USER
   * 
   * Réactive un utilisateur suspendu.
   */
  async activateUser(adminUserId, userId, requestInfo = {}) {
    try {
      const response = await axios.post(
        `${process.env.AUTH_SERVICE_URL}/api/admin/users/${userId}/activate`,
        {},
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`
          }
        }
      );

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'user_activated',
        targetUserId: userId,
        description: `Activated user: ${userId}`,
        metadata: {},
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('User activated by admin', {
        adminUserId,
        userId
      });

      return response.data.data;
    } catch (error) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User not found');
      }
      logger.error('Failed to activate user', {
        adminUserId,
        userId,
        error: error.message
      });
      throw new Error('Failed to activate user');
    }
  }

  /**
   * CHANGE USER ROLE
   * 
   * Change le rôle d'un utilisateur.
   */
  async changeUserRole(adminUserId, userId, newRole, requestInfo = {}) {
    try {
      const response = await axios.patch(
        `${process.env.AUTH_SERVICE_URL}/api/admin/users/${userId}/role`,
        { role: newRole },
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`,
            'Content-Type': 'application/json'
          }
        }
      );

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'role_changed',
        targetUserId: userId,
        description: `Changed role for user: ${userId} to ${newRole}`,
        metadata: { newRole },
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('User role changed by admin', {
        adminUserId,
        userId,
        newRole
      });

      return response.data.data;
    } catch (error) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User not found');
      }
      logger.error('Failed to change user role', {
        adminUserId,
        userId,
        error: error.message
      });
      throw new Error('Failed to change user role');
    }
  }

  /**
   * RESET USER PASSWORD
   * 
   * Réinitialise le mot de passe d'un utilisateur.
   */
  async resetUserPassword(adminUserId, userId, newPassword, requestInfo = {}) {
    try {
      const response = await axios.post(
        `${process.env.AUTH_SERVICE_URL}/api/admin/users/${userId}/reset-password`,
        { newPassword },
        {
          headers: {
            'Authorization': `Bearer ${process.env.SERVICE_AUTH_TOKEN}`,
            'Content-Type': 'application/json'
          }
        }
      );

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'password_reset',
        targetUserId: userId,
        description: `Reset password for user: ${userId}`,
        metadata: {},
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('User password reset by admin', {
        adminUserId,
        userId
      });

      return { success: true, message: 'Password reset successfully' };
    } catch (error) {
      if (error.response?.status === 404) {
        throw new NotFoundError('User not found');
      }
      logger.error('Failed to reset user password', {
        adminUserId,
        userId,
        error: error.message
      });
      throw new Error('Failed to reset password');
    }
  }

  /**
   * BULK OPERATIONS
   * 
   * Effectue des opérations en masse sur plusieurs utilisateurs.
   */
  async bulkOperation(adminUserId, operation, userIds, data = {}, requestInfo = {}) {
    try {
      const results = {
        successful: [],
        failed: []
      };

      for (const userId of userIds) {
        try {
          let result;
          
          switch (operation) {
            case 'suspend':
              result = await this.suspendUser(adminUserId, userId, data.reason, requestInfo);
              break;
            case 'activate':
              result = await this.activateUser(adminUserId, userId, requestInfo);
              break;
            case 'delete':
              result = await this.deleteUser(adminUserId, userId, requestInfo);
              break;
            case 'changeRole':
              result = await this.changeUserRole(adminUserId, userId, data.newRole, requestInfo);
              break;
            default:
              throw new Error(`Unknown operation: ${operation}`);
          }

          results.successful.push({ userId, result });
        } catch (error) {
          results.failed.push({ userId, error: error.message });
        }
      }

      // Logger l'opération bulk
      await adminService.logAction({
        adminUserId,
        actionType: 'bulk_operation',
        description: `Bulk ${operation} on ${userIds.length} users`,
        metadata: {
          operation,
          totalUsers: userIds.length,
          successful: results.successful.length,
          failed: results.failed.length
        },
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      return results;
    } catch (error) {
      logger.error('Failed bulk operation', {
        adminUserId,
        operation,
        error: error.message
      });
      throw error;
    }
  }
}

module.exports = new UserManagementService();
