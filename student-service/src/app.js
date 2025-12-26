const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');
const studentRoutes = require('./routes/studentRoutes');
const { errorHandler } = require('../../shared/utils/errorHandler');
const logger = require('../../shared/utils/logger');
const app = express();
app.use(helmet());
app.use(cors({
origin: process.env.CORS_ORIGIN || '',
credentials: true,
methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(cookieParser());
app.use(morgan('combined', {
stream: {
write: (message) => logger.info(message.trim())
}
}));
app.get('/health', (req, res) => {
res.status(200).json({
status: 'healthy',
service: 'student-service',
timestamp: new Date().toISOString(),
uptime: process.uptime()
});
});
app.get('/ready', async (req, res) => {
try {
const { sequelize } = require('./config/database');
// Test database connection
await sequelize.authenticate();
res.status(200).json({
status: 'ready',
service: 'student-service',
database: 'connected',
timestamp: new Date().toISOString()
});
} catch (error) {
logger.error('Readiness check failed', { error: error.message });
res.status(503).json({
status: 'not ready',
service: 'student-service',
database: 'disconnected',
error: error.message
});
}
});

app.get('/live', (req, res) => {
res.status(200).json({
status: 'alive',
service: 'student-service',
timestamp: new Date().toISOString()
});
});
app.use('/api/students', studentRoutes);
app.use((req, res) => {
res.status(404).json({
success: false,
message: 'Route not found',
path: req.path,
method: req.method
});
});
app.use(errorHandler);
module.exports = app;

