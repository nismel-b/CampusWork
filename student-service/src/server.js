require('dotenv').config();
const app = require('./app');
const { sequelize, testConnection, syncDatabase } = require('./config/database');
const { startEventConsumer, eventConsumer } = require('./events/eventHandlers');
const redisClient = require('../../shared/utils/redisClient');
const logger = require('../../shared/utils/logger');
const PORT = process.env.PORT || 3002;
const gracefulShutdown = async (signal) => {
logger.info('🛑 Received ${signal}. Starting graceful shutdown...');

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

const startServer = async () => {
try {
logger.info('🚀 Starting Student Service...');
/**

STEP 1: Test database connection
*/
logger.info('📊 Connecting to database...');
await testConnection();

if (process.env.NODE_ENV === 'development') {
logger.info('📊 Syncing database models...');
await syncDatabase();
}
logger.info('📨 Starting event consumer...');
await startEventConsumer();
logger.info('🌐 Starting HTTP server...');
const server = app.listen(PORT, () => {
logger.info('✅ Student Service running on port ${PORT}');
logger.info(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
logger.info('📍 Database: ${process.env.DB_NAME}');
logger.info('📍 Health check: http://localhost:${PORT}/health');
});

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
startServer();

