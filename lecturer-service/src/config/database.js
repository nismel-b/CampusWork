const { Sequelize } = require('sequelize');
const logger = require('../../../shared/utils/logger');
const sequelize = new Sequelize(
process.env.DB_NAME,         // Database: 'lecturer_db'
process.env.DB_USER,         // User: 'postgres'
process.env.DB_PASSWORD,     // Password
{
host: process.env.DB_HOST, // Host: 'lecturer-db' (Docker)
port: process.env.DB_PORT || 5432,
dialect: 'postgres',

logging: (msg) => logger.debug(msg),

pool: {
max: 10,       // Maximum 10 connexions simultanées
min: 2,        // Minimum 2 connexions toujours prêtes
acquire: 30000, // 30s timeout pour obtenir une connexion
idle: 10000     // 10s avant de libérer une connexion inactive
},
define: {
timestamps: true,           // Ajouter createdAt et updatedAt
underscored: true,          // Utiliser snake_case (created_at)
createdAt: 'created_at',
updatedAt: 'updated_at'
}
}
);
const testConnection = async () => {
try {
await sequelize.authenticate();
logger.info('✅ Lecturer Service database connection established', {
database: process.env.DB_NAME,
host: process.env.DB_HOST
});
} catch (error) {
logger.error('❌ Unable to connect to Lecturer Service database', {
error: error.message,
database: process.env.DB_NAME
});
// Arrêter le processus en cas d'échec
process.exit(1);
}
};
const syncDatabase = async () => {
try {
if (process.env.NODE_ENV === 'development') {
// Mettre à jour les tables pour correspondre aux modèles
await sequelize.sync({ alter: true });
logger.info('📊 Lecturer database models synchronized');
} else {
logger.info('📊 Skipping sync in production (use migrations)');
}
} catch (error) {
logger.error('Failed to sync lecturer database', {
error: error.message
});
}
};

module.exports = {
sequelize,
testConnection,
syncDatabase
};
