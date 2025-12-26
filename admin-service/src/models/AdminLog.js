/**
 * ADMIN LOG MODEL
 * 
 * File: src/models/AdminLog.js
 * 
 * Stocke tous les logs d'actions administratives pour l'audit.
 */

const { DataTypes } = require('sequelize');

module.exports = (sequelize) => {
  const AdminLog = sequelize.define('AdminLog', {
    /**
     * PRIMARY KEY
     */
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
      field: 'log_id'
    },

    /**
     * ADMIN USER ID
     * 
     * ID de l'administrateur qui a effectué l'action.
     */
    adminUserId: {
      type: DataTypes.UUID,
      allowNull: false,
      field: 'admin_user_id',
      comment: 'References User.id from Auth Service'
    },

    /**
     * ACTION TYPE
     * 
     * Type d'action administrative effectuée.
     */
    actionType: {
      type: DataTypes.ENUM(
        'user_created',
        'user_updated',
        'user_deleted',
        'user_suspended',
        'user_activated',
        'role_changed',
        'password_reset',
        'profile_updated',
        'profile_deleted',
        'system_config_updated',
        'bulk_operation',
        'export_data',
        'import_data',
        'other'
      ),
      allowNull: false,
      field: 'action_type'
    },

    /**
     * TARGET USER ID
     * 
     * ID de l'utilisateur ciblé par l'action (si applicable).
     */
    targetUserId: {
      type: DataTypes.UUID,
      allowNull: true,
      field: 'target_user_id',
      comment: 'User affected by the action'
    },

    /**
     * DESCRIPTION
     * 
     * Description détaillée de l'action.
     */
    description: {
      type: DataTypes.TEXT,
      allowNull: false,
      comment: 'Detailed description of the action'
    },

    /**
     * METADATA
     * 
     * Données supplémentaires sur l'action.
     * 
     * Exemple:
     * {
     *   "oldValue": "student",
     *   "newValue": "lecturer",
     *   "reason": "Role upgrade request approved"
     * }
     */
    metadata: {
      type: DataTypes.JSONB,
      defaultValue: {},
      allowNull: true,
      comment: 'Additional action metadata'
    },

    /**
     * IP ADDRESS
     * 
     * Adresse IP de l'administrateur.
     */
    ipAddress: {
      type: DataTypes.STRING(45),
      allowNull: true,
      field: 'ip_address',
      comment: 'IPv4 or IPv6 address'
    },

    /**
     * USER AGENT
     * 
     * Navigateur/client utilisé.
     */
    userAgent: {
      type: DataTypes.STRING(500),
      allowNull: true,
      field: 'user_agent'
    },

    /**
     * STATUS
     * 
     * Statut de l'action (succès ou échec).
     */
    status: {
      type: DataTypes.ENUM('success', 'failed'),
      defaultValue: 'success',
      allowNull: false
    },

    /**
     * ERROR MESSAGE
     * 
     * Message d'erreur si l'action a échoué.
     */
    errorMessage: {
      type: DataTypes.TEXT,
      allowNull: true,
      field: 'error_message'
    }
  }, {
    tableName: 'admin_logs',
    
    /**
     * INDEXES
     */
    indexes: [
      { fields: ['admin_user_id'] },
      { fields: ['target_user_id'] },
      { fields: ['action_type'] },
      { fields: ['status'] },
      { fields: ['created_at'] }
    ]
  });

  /**
   * CLASS METHODS
   */
  
  /**
   * LOG ACTION
   * 
   * Méthode helper pour créer un log facilement.
   */
  AdminLog.logAction = async function(actionData) {
    try {
      return await this.create(actionData);
    } catch (error) {
      console.error('Failed to create admin log:', error);
      throw error;
    }
  };

  /**
   * GET LOGS BY ADMIN
   */
  AdminLog.getLogsByAdmin = async function(adminUserId, options = {}) {
    const { page = 1, limit = 50 } = options;
    const offset = (page - 1) * limit;

    return await this.findAndCountAll({
      where: { adminUserId },
      limit,
      offset,
      order: [['created_at', 'DESC']]
    });
  };

  /**
   * GET LOGS BY TARGET USER
   */
  AdminLog.getLogsByTargetUser = async function(targetUserId, options = {}) {
    const { page = 1, limit = 50 } = options;
    const offset = (page - 1) * limit;

    return await this.findAndCountAll({
      where: { targetUserId },
      limit,
      offset,
      order: [['created_at', 'DESC']]
    });
  };

  return AdminLog;
};
