/**
 * DATABASE CONFIGURATION - ADMIN SERVICE
 * 
 * File: src/config/database.js
 * 
 * Configuration pour la base de données PostgreSQL du Admin Service.
 */

const { Sequelize } = require('sequelize');
const logger = require('../../../shared/utils/logger');

/**
 * CRÉER L'INSTANCE SEQUELIZE
 */
const sequelize = new Sequelize(
  process.env.DB_NAME,        // Database: 'admin_db'
  process.env.DB_USER,        // User: 'postgres'
  process.env.DB_PASSWORD,    // Password
  {
    host: process.env.DB_HOST,  // Host: 'admin-db' (Docker)
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    
    /**
     * LOGGING
     */
    logging: (msg) => logger.debug(msg),
    
    /**
     * CONNECTION POOL
     */
    pool: {
      max: 10,
      min: 2,
      acquire: 30000,
      idle: 10000
    },
    
    /**
     * MODEL DEFAULTS
     */
    define: {
      timestamps: true,
      underscored: true,
      createdAt: 'created_at',
      updatedAt: 'updated_at'
    }
  }
);

/**
 * TEST CONNECTION
 */
const testConnection = async () => {
  try {
    await sequelize.authenticate();
    logger.info('✅ Admin Service database connection established', {
      database: process.env.DB_NAME,
      host: process.env.DB_HOST
    });
  } catch (error) {
    logger.error('❌ Unable to connect to Admin Service database', {
      error: error.message,
      database: process.env.DB_NAME
    });
    process.exit(1);
  }
};

/**
 * SYNC DATABASE
 */
const syncDatabase = async () => {
  try {
    if (process.env.NODE_ENV === 'development') {
      await sequelize.sync({ alter: true });
      logger.info('📊 Admin database models synchronized');
    } else {
      logger.info('📊 Skipping sync in production (use migrations)');
    }
  } catch (error) {
    logger.error('Failed to sync admin database', {
      error: error.message
    });
  }
};

module.exports = {
  sequelize,
  testConnection,
  syncDatabase
};

