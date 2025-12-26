require('dotenv').config();
const app = require('./app');
const { sequelize, testConnection } = require('./config/database');
const eventPublisher = require('../../shared/utils/eventPublisher');
const logger = require('../../shared/utils/logger');

const PORT = process.env.PORT || 3001;

// Graceful shutdown
const gracefulShutdown = async () => {
  logger.info('Received shutdown signal, closing server gracefully');

  try {
    // Close database connection
    await sequelize.close();
    logger.info('Database connection closed');

    // Close event publisher
    await eventPublisher.close();
    logger.info('Event publisher closed');

    process.exit(0);
  } catch (error) {
    logger.error('Error during shutdown', { error: error.message });
    process.exit(1);
  }
};

// Start server
const startServer = async () => {
  try {
    // Test database connection
    await testConnection();

    // Sync database models (in development)
    if (process.env.NODE_ENV === 'development') {
      await sequelize.sync({ alter: true });
      logger.info('Database models synchronized');
    }

    // Connect to RabbitMQ
    await eventPublisher.connect();

    // Start Express server
    const server = app.listen(PORT, () => {
      logger.info(`Auth Service running on port ${PORT}`);
      logger.info(`Environment: ${process.env.NODE_ENV}`);
    });

    // Graceful shutdown handlers
    process.on('SIGTERM', gracefulShutdown);
    process.on('SIGINT', gracefulShutdown);

  } catch (error) {
    logger.error('Failed to start server', { error: error.message });
    process.exit(1);
  }
};

startServer(); 