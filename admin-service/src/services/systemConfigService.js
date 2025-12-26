/**
 * SYSTEM CONFIG SERVICE
 * 
 * File: src/services/systemConfigService.js
 * 
 * Gestion des configurations système.
 */

const { SystemConfig } = require('../models');
const adminService = require('./adminService');
const logger = require('../../../shared/utils/logger');
const {
  NotFoundError,
  ValidationError
} = require('../../../shared/utils/errorHandler');

class SystemConfigService {
  
  /**
   * GET ALL CONFIGS
   * 
   * Récupère toutes les configurations (admin seulement).
   */
  async getAllConfigs(category = null) {
    try {
      if (category) {
        return await SystemConfig.getByCategory(category);
      }

      return await SystemConfig.findAll({
        order: [['category', 'ASC'], ['key', 'ASC']]
      });
    } catch (error) {
      logger.error('Failed to get all configs', {
        error: error.message
      });
      throw error;
    }
  }

  /**
   * GET PUBLIC CONFIGS
   * 
   * Récupère les configurations publiques (accessibles à tous).
   */
  async getPublicConfigs() {
    try {
      return await SystemConfig.getPublicConfigs();
    } catch (error) {
      logger.error('Failed to get public configs', {
        error: error.message
      });
      throw error;
    }
  }

  /**
   * GET CONFIG BY KEY
   * 
   * Récupère une configuration spécifique par sa clé.
   */
  async getConfigByKey(key) {
    try {
      const config = await SystemConfig.getByKey(key);
      
      if (!config) {
        throw new NotFoundError(`Configuration '${key}' not found`);
      }

      return config;
    } catch (error) {
      logger.error('Failed to get config by key', {
        key,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * SET CONFIG
   * 
   * Crée ou met à jour une configuration.
   */
  async setConfig(adminUserId, key, value, metadata = {}, requestInfo = {}) {
    try {
      const config = await SystemConfig.setConfig(key, value, {
        ...metadata,
        adminUserId
      });

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'system_config_updated',
        description: `Updated system config: ${key}`,
        metadata: {
          key,
          value,
          category: metadata.category
        },
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('System config updated', {
        adminUserId,
        key
      });

      return config;
    } catch (error) {
      logger.error('Failed to set config', {
        key,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * UPDATE CONFIG
   * 
   * Met à jour une configuration existante.
   */
  async updateConfig(adminUserId, key, value, requestInfo = {}) {
    try {
      const config = await SystemConfig.getByKey(key);
      
      if (!config) {
        throw new NotFoundError(`Configuration '${key}' not found`);
      }

      if (!config.isEditable) {
        throw new ValidationError(`Configuration '${key}' is not editable`);
      }

      await config.update({
        value,
        lastModifiedBy: adminUserId
      });

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'system_config_updated',
        description: `Updated system config: ${key}`,
        metadata: {
          key,
          oldValue: config.value,
          newValue: value
        },
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('System config updated', {
        adminUserId,
        key
      });

      return config;
    } catch (error) {
      logger.error('Failed to update config', {
        key,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * DELETE CONFIG
   * 
   * Supprime une configuration.
   */
  async deleteConfig(adminUserId, key, requestInfo = {}) {
    try {
      const config = await SystemConfig.getByKey(key);
      
      if (!config) {
        throw new NotFoundError(`Configuration '${key}' not found`);
      }

      if (!config.isEditable) {
        throw new ValidationError(`Configuration '${key}' cannot be deleted`);
      }

      await config.destroy();

      // Logger l'action
      await adminService.logAction({
        adminUserId,
        actionType: 'system_config_updated',
        description: `Deleted system config: ${key}`,
        metadata: { key },
        ipAddress: requestInfo.ipAddress,
        userAgent: requestInfo.userAgent
      });

      logger.info('System config deleted', {
        adminUserId,
        key
      });

      return { success: true };
    } catch (error) {
      logger.error('Failed to delete config', {
        key,
        error: error.message
      });
      throw error;
    }
  }

  /**
   * INITIALIZE DEFAULT CONFIGS
   * 
   * Initialise les configurations par défaut au premier démarrage.
   */
  async initializeDefaultConfigs() {
    try {
      const defaultConfigs = [
        {
          key: 'site_name',
          value: 'Campus eduproject',
          description: 'Name of the platform',
          category: 'general',
          isPublic: true,
          isEditable: true
        },
        {
          key: 'site_description',
          value: 'Student project repository platform',
          description: 'Description of the platform',
          category: 'general',
          isPublic: true,
          isEditable: true
        },
        {
          key: 'max_upload_size',
          value: 10485760, // 10MB in bytes
          description: 'Maximum file upload size in bytes',
          category: 'storage',
          isPublic: false,
          isEditable: true
        },
        {
          key: 'allowed_file_types',
          value: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'jpg', 'jpeg', 'png', 'gif', 'mp4'],
          description: 'Allowed file extensions for uploads',
          category: 'storage',
          isPublic: false,
          isEditable: true
        },
        {
          key: 'enable_registration',
          value: true,
          description: 'Allow new user registrations',
          category: 'security',
          isPublic: true,
          isEditable: true
        },
        {
          key: 'require_email_verification',
          value: true,
          description: 'Require email verification for new accounts',
          category: 'security',
          isPublic: false,
          isEditable: true
        },
        {
          key: 'session_timeout',
          value: 3600, // 1 hour in seconds
          description: 'Session timeout in seconds',
          category: 'security',
          isPublic: false,
          isEditable: true
        },
        {
          key: 'enable_notifications',
          value: true,
          description: 'Enable platform notifications',
          category: 'notifications',
          isPublic: false,
          isEditable: true
        }
      ];

      for (const configData of defaultConfigs) {
        await SystemConfig.findOrCreate({
          where: { key: configData.key },
          defaults: configData
        });
      }

      logger.info('Default system configs initialized');
    } catch (error) {
      logger.error('Failed to initialize default configs', {
        error: error.message
      });
    }
  }
}

module.exports = new SystemConfigService();
