/**
 * Microservices URL configuration
 */
module.exports = {
  auth: {
    url: process.env.AUTH_SERVICE_URL || 'http://localhost:3001',
    timeout: 5000,
    healthCheck: '/health'
  },
  student: {
    url: process.env.STUDENT_SERVICE_URL || 'http://localhost:3002',
    timeout: 5000,
    healthCheck: '/health'
  },
  lecturer: {
    url: process.env.LECTURER_SERVICE_URL || 'http://localhost:3003',
    timeout: 5000,
    healthCheck: '/health'
  },
  admin: {
    url: process.env.ADMIN_SERVICE_URL || 'http://localhost:3004',
    timeout: 5000,
    healthCheck: '/health'
  },
  project: {
    url: process.env.PROJECT_SERVICE_URL || 'http://localhost:3005',
    timeout: 10000, // Longer timeout for file uploads
    healthCheck: '/health'
  }
};