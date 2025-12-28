/**
 * CORS configuration
 */
module.exports = {
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: [
    'Content-Type',
    'Authorization',
    'X-Requested-With',
    'Accept',
    'Origin'
  ],
  exposedHeaders: [
    'X-Total-Count',
    'X-Page',
    'X-Per-Page'
  ],
  maxAge: 86400, // 24 hours
  optionsSuccessStatus: 200
};
