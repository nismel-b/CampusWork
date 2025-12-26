/**
 * SERVER ENTRY POINT - LECTURER SERVICE
 * 
 * Démarre le Lecturer Service et initialise toutes les dépendances.
 */

require('dotenv').config();

const app = require('./app');
const { sequelize, testConnection, syncDatabase } = require('./config/database');
const { startEventConsumer, eventConsumer } = require('./events/eventHandlers');
const redisClient = require('../../shared/utils/redisClient');
const logger = require('../../shared/utils/logger');

const PORT = process.env.PORT || 3003;

let server;

/**
 * GRACEFUL SHUTDOWN
 * 
 * Handles shutdown signals (SIGTERM, SIGINT) to close connections cleanly.
 */
const gracefulShutdown = async (signal) => {
  logger.info(`🛑 Received ${signal}. Starting graceful shutdown...`);
  
  try {
    // Stop accepting new connections
    if (server) {
      server.close(() => {
        logger.info('✅ HTTP server closed');
      });
    }
    
    // Close database connection
    await sequelize.close();
    logger.info('✅ Database connection closed');
    
    // Close event consumer
    await eventConsumer.close();
    logger.info('✅ Event consumer closed');
    
    // Close Redis connection
    redisClient.disconnect();
    logger.info('✅ Redis connection closed');
    
    logger.info('✅ Graceful shutdown completed');
    process.exit(0);
  } catch (error) {
    logger.error('❌ Error during shutdown', { error: error.message });
    process.exit(1);
  }
};

/**
 * START SERVER
 * 
 * Initializes all dependencies and starts the HTTP server.
 */
const startServer = async () => {
  try {
    logger.info('🚀 Starting Lecturer Service...');
    
    /**
     * STEP 1: Test database connection
     */
    logger.info('📊 Connecting to database...');
    await testConnection();
    
    /**
     * STEP 2: Sync database models
     */
    if (process.env.NODE_ENV === 'development') {
      logger.info('📊 Syncing database models...');
      await syncDatabase();
    }
    
    /**
     * STEP 3: Start event consumer
     */
    logger.info('📨 Starting event consumer...');
    await startEventConsumer();
    
    /**
     * STEP 4: Start HTTP server
     */
    logger.info('🌐 Starting HTTP server...');
    server = app.listen(PORT, () => {
      logger.info(`✅ Lecturer Service running on port ${PORT}`);
      logger.info(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`📍 Database: ${process.env.DB_NAME}`);
      logger.info(`📍 Health check: http://localhost:${PORT}/health`);
    });
    
    /**
     * STEP 5: Setup graceful shutdown handlers
     */
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
    
    /**
     * Handle uncaught exceptions
     */
    process.on('uncaughtException', (error) => {
      logger.error('❌ Uncaught Exception', {
        error: error.message,
        stack: error.stack
      });
      gracefulShutdown('uncaughtException');
    });
    
    /**
     * Handle unhandled promise rejections
     */
    process.on('unhandledRejection', (reason, promise) => {
      logger.error('❌ Unhandled Rejection', {
        reason,
        promise
      });
      gracefulShutdown('unhandledRejection');
    });
    
  } catch (error) {
    logger.error('❌ Failed to start server', {
      error: error.message,
      stack: error.stack
    });
    process.exit(1);
  }
};

/**
 * Start the server
 */
startServer();
