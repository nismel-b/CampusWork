/**
 * Server startup and configuration
 */
require('dotenv').config();

const app = require('./app');
const { logger } = require('./middleware/logger');
const { circuitBreakers } = require('./proxy/circuitBreaker');
const services = require('./config/services');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';

let server;

/**
 * Graceful shutdown handler
 */
const gracefulShutdown = async (signal) => {
  logger.info(`🛑 Received ${signal}. Starting graceful shutdown...`);
  
  try {
    // Stop accepting new connections
    if (server) {
      await new Promise((resolve) => {
        server.close(() => {
          logger.info('✅ HTTP server closed');
          resolve();
        });
      });
    }

    // Wait for ongoing requests to complete (with timeout)
    await new Promise(resolve => setTimeout(resolve, 5000));

    logger.info('✅ Graceful shutdown completed');
    process.exit(0);
  } catch (error) {
    logger.error('❌ Error during shutdown', {
      error: error.message,
      stack: error.stack
    });
    process.exit(1);
  }
};

/**
 * Start server
 */
const startServer = async () => {
  try {
    logger.info('🚀 Starting API Gateway...');
    logger.info('');

    // Log configuration
    logger.info('📋 Configuration:', {
      port: PORT,
      host: HOST,
      nodeEnv: process.env.NODE_ENV || 'development',
      logLevel: process.env.LOG_LEVEL || 'info'
    });

    // Log registered services
    logger.info('');
    logger.info('🔀 Registered Services:');
    Object.entries(services).forEach(([name, config]) => {
      logger.info(`   - ${name.toUpperCase()}: ${config.url}`);
    });

    // Start HTTP server
    logger.info('');
    logger.info('🌐 Starting HTTP server...');
    server = app.listen(PORT, HOST, () => {
      logger.info('');
      logger.info('═══════════════════════════════════════════════════════');
      logger.info(` API Gateway running on http://${HOST}:${PORT}`);
      logger.info('═══════════════════════════════════════════════════════');
      logger.info('');
      logger.info(' Endpoints:');
      logger.info(`   - Health:     http://localhost:${PORT}/health`);
      logger.info(`   - Ready:      http://localhost:${PORT}/ready`);
      logger.info(`   - Auth:       http://localhost:${PORT}/api/auth/*`);
      logger.info(`   - Students:   http://localhost:${PORT}/api/students/*`);
      logger.info(`   - Lecturers:  http://localhost:${PORT}/api/lecturers/*`);
      logger.info(`   - Admin:      http://localhost:${PORT}/api/admin/*`);
      logger.info(`   - Projects:   http://localhost:${PORT}/api/projects/*`);
      logger.info('');
      logger.info(' Features:');
      logger.info('   ✓ Request routing');
      logger.info('   ✓ Authentication');
      logger.info('   ✓ Rate limiting');
      logger.info('   ✓ Request logging');
      logger.info('   ✓ Error handling');
      logger.info('   ✓ Circuit breakers');
      logger.info('');
    });

    // Setup graceful shutdown handlers
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

    // Handle uncaught exceptions
    process.on('uncaughtException', (error) => {
      logger.error('❌ Uncaught Exception', {
        error: error.message,
        stack: error.stack
      });
      gracefulShutdown('uncaughtException');
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason, promise) => {
      logger.error('❌ Unhandled Rejection', {
        reason,
        promise
      });
      gracefulShutdown('unhandledRejection');
    });

    // Log circuit breaker status periodically (every 5 minutes)
    setInterval(() => {
      const states = Object.entries(circuitBreakers).map(([name, breaker]) => 
        breaker.getState()
      );
      
      if (states.length > 0) {
        logger.info('🔌 Circuit Breaker Status:', { states });
      }
    }, 5 * 60 * 1000);

  } catch (error) {
    logger.error('❌ Failed to start server', {
      error: error.message,
      stack: error.stack
    });
    process.exit(1);
  }
};

// Start the server
startServer();


