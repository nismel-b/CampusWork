/**
 * MODELS INDEX - ADMIN SERVICE
 * 
 * File: src/models/index.js
 */

const { sequelize } = require('../config/database');
const AdminLogModel = require('./AdminLog');
const SystemConfigModel = require('./SystemConfig');

/**
 * INITIALIZE MODELS
 */
const AdminLog = AdminLogModel(sequelize);
const SystemConfig = SystemConfigModel(sequelize);

/**
 * DEFINE RELATIONSHIPS
 */
// Pas de relations directes pour l'instant
// Les relations avec User sont via userId (pas de FK car bases différentes)

/**
 * EXPORT
 */
const db = {
  sequelize,
  AdminLog,
  SystemConfig
};

module.exports = db;
