require('dotenv').config();

module.exports = {
  port: process.env.PORT || 4001,
  mongoUri: process.env.MONGO_URI || 'mongodb://mongo:27017/project_upload',
  // L'URL interne de ton service d'auth (ex: http://auth-service:3000)
  authServiceUrl: process.env.AUTH_SERVICE_URL || 'http://host.docker.internal:3000',
};