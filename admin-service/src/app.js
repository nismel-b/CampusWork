/**
 * ==============================================
 * EXPRESS APP CONFIGURATION - ADMIN SERVICE
 * File: src/app.js
 * ==============================================
 */

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');

const adminRoutes = require('./routes/index');
const { errorHandler } = require('../../shared/utils/errorHandler');
const logger = require('../../shared/utils/logger');

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cookieParser());

// Logging
app.use(morgan('combined', {
  stream: { write: (message) => logger.info(message.trim()) }
}));

// Health checks
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    service: 'admin-service',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/ready', async (req, res) => {
  try {
    const { sequelize } = require('./config/database');
    await sequelize.authenticate();
    
    res.status(200).json({
      status: 'ready',
      service: 'admin-service',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    logger.error('Readiness check failed', { error: error.message });
    res.status(503).json({
      status: 'not ready',
      service: 'admin-service',
      database: 'disconnected',
      error: error.message
    });
  }
});

app.get('/live', (req, res) => {
  res.status(200).json({
    status: 'alive',
    service: 'admin-service',
    timestamp: new Date().toISOString()
  });
});

// API routes
app.use('/api/admin', adminRoutes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.path,
    method: req.method
  });
});

// Error handler
app.use(errorHandler);

module.exports = app;

/**
 * ==============================================
 * SERVER ENTRY POINT - ADMIN SERVICE
 * File: src/server.js
 * ==============================================
 */

require('dotenv').config();

const app = require('./app');
const { sequelize, testConnection, syncDatabase } = require('./config/database');
const systemConfigService = require('./services/systemConfigService');
const logger = require('../../shared/utils/logger');

const PORT = process.env.PORT || 3004;

let server;

const gracefulShutdown = async (signal) => {
  logger.info(`🛑 Received ${signal}. Starting graceful shutdown...`);
  
  try {
    if (server) {
      server.close(() => {
        logger.info('✅ HTTP server closed');
      });
    }
    
    await sequelize.close();
    logger.info('✅ Database connection closed');
    
    logger.info('✅ Graceful shutdown completed');
    process.exit(0);
  } catch (error) {
    logger.error('❌ Error during shutdown', { error: error.message });
    process.exit(1);
  }
};

const startServer = async () => {
  try {
    logger.info('🚀 Starting Admin Service...');
    
    // Step 1: Database connection
    logger.info('📊 Connecting to database...');
    await testConnection();
    
    // Step 2: Sync database
    if (process.env.NODE_ENV === 'development') {
      logger.info('📊 Syncing database models...');
      await syncDatabase();
    }
    
    // Step 3: Initialize default configs
    logger.info('⚙️  Initializing default system configs...');
    await systemConfigService.initializeDefaultConfigs();
    
    // Step 4: Start HTTP server
    logger.info('🌐 Starting HTTP server...');
    server = app.listen(PORT, () => {
      logger.info(`✅ Admin Service running on port ${PORT}`);
      logger.info(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
      logger.info(`📍 Database: ${process.env.DB_NAME}`);
      logger.info(`📍 Health check: http://localhost:${PORT}/health`);
    });
    
    // Step 5: Graceful shutdown handlers
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
    
    process.on('uncaughtException', (error) => {
      logger.error('❌ Uncaught Exception', {
        error: error.message,
        stack: error.stack
      });
      gracefulShutdown('uncaughtException');
    });
    
    process.on('unhandledRejection', (reason, promise) => {
      logger.error('❌ Unhandled Rejection', { reason, promise });
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

startServer();
