const { Sequelize } = require('sequelize');
const logger = require('../../../shared/utils/logger');
const sequelize = new Sequelize(
process.env.DB_NAME,      // Database name: 'student_db'
process.env.DB_USER,      // Database user: 'postgres'
process.env.DB_PASSWORD,  // Database password
{
host: process.env.DB_HOST,  // Database host: 'student-db' (Docker container name)
port: process.env.DB_PORT || 5432,
dialect: 'postgres',  // Database type
logging: (msg) => logger.debug(msg),
pool: {
max: 10,
min: 2,
acquire: 30000,  // 30 seconds
idle: 10000      // 10 seconds
},
define: {
timestamps: true,
underscored: true,
createdAt: 'created_at',
updatedAt: 'updated_at'
}
}
);
const testConnection = async () => {
try {
// Attempt to authenticate
await sequelize.authenticate();
logger.info('✅ Student Service database connection established successfully', {
database: process.env.DB_NAME,
host: process.env.DB_HOST
});
} catch (error) {
logger.error('❌ Unable to connect to Student Service database', {
error: error.message,
database: process.env.DB_NAME
});
// Exit process with failure code
process.exit(1);
}
};
const syncDatabase = async () => {
try {
if (process.env.NODE_ENV === 'development') {
// In development, update tables to match models
await sequelize.sync({ alter: true });
logger.info('📊 Database models synchronized (development mode)');
} else {
// In production, use migrations instead of sync
logger.info('📊 Skipping sync in production (use migrations)');
}
} catch (error) {
logger.error('Failed to sync database', { error: error.message });
}
};



module.exports = {
sequelize,
testConnection,
syncDatabase
};

