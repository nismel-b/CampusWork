/**
 * Route configuration for API Gateway
 * Each route specifies:
 * - path: The gateway endpoint path
 * - target: The microservice URL
 * - auth: Whether authentication is required
 * - roles: Allowed roles (optional)
 * - rateLimit: Custom rate limit config (optional)
 */
const services = require('./services');

module.exports = [
  // ======================
  // AUTH SERVICE ROUTES
  // ======================
  {
    path: '/api/auth',
    target: services.auth.url,
    auth: false, // Public routes
    pathRewrite: {
      '^/api/auth': '/api/auth'
    },
    description: 'Authentication endpoints (register, login, etc.)'
  },
  {
    path: '/api/users',
    target: services.auth.url,
    auth: true, // Protected routes
    pathRewrite: {
      '^/api/users': '/api/users'
    },
    description: 'User management endpoints'
  },

  // ======================
  // STUDENT SERVICE ROUTES
  // ======================
  {
    path: '/api/students/profile/me',
    target: services.student.url,
    auth: true,
    roles: ['student', 'admin'],
    pathRewrite: {
      '^/api/students': '/api/students'
    },
    description: 'Student own profile endpoints'
  },
  {
    path: '/api/students',
    target: services.student.url,
    auth: false, // Public search doesn't need auth
    pathRewrite: {
      '^/api/students': '/api/students'
    },
    description: 'Student service endpoints (public & protected)'
  },

  // ======================
  // LECTURER SERVICE ROUTES
  // ======================
  {
    path: '/api/lecturers/profile/me',
    target: services.lecturer.url,
    auth: true,
    roles: ['lecturer', 'admin'],
    pathRewrite: {
      '^/api/lecturers': '/api/lecturers'
    },
    description: 'Lecturer own profile endpoints'
  },
  {
    path: '/api/lecturers',
    target: services.lecturer.url,
    auth: false, // Public search
    pathRewrite: {
      '^/api/lecturers': '/api/lecturers'
    },
    description: 'Lecturer service endpoints'
  },

  // ======================
  // ADMIN SERVICE ROUTES
  // ======================
  {
    path: '/api/admin',
    target: services.admin.url,
    auth: true,
    roles: ['admin'], // Only admins
    pathRewrite: {
      '^/api/admin': '/api/admin'
    },
    rateLimit: {
      windowMs: 15 * 60 * 1000, // 15 minutes
      max: 200 // Higher limit for admins
    },
    description: 'Admin panel endpoints'
  },

  // ======================
  // PROJECT SERVICE ROUTES
  // ======================
  {
    path: '/api/projects/my',
    target: services.project.url,
    auth: true, // User's own projects
    pathRewrite: {
      '^/api/projects': '/api/projects'
    },
    description: 'User own projects'
  },
  {
    path: '/api/projects/:projectId/files',
    target: services.project.url,
    auth: true, // File operations need auth
    pathRewrite: {
      '^/api/projects': '/api/projects'
    },
    rateLimit: {
      windowMs: 60 * 60 * 1000, // 1 hour
      max: 50 // Limit uploads
    },
    description: 'Project file operations'
  },
  {
    path: '/api/projects',
    target: services.project.url,
    auth: false, // Public search doesn't need auth
    pathRewrite: {
      '^/api/projects': '/api/projects'
    },
    description: 'Project service endpoints'
  }
];
