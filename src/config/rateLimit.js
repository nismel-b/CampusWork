/**
 * Rate limiting configuration
 */
module.exports = {
  // General API rate limit
  api: {
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: {
      success: false,
      message: 'Too many requests from this IP, please try again later'
    },
    standardHeaders: true, // Return rate limit info in headers
    legacyHeaders: false,
    skipSuccessfulRequests: false,
    skipFailedRequests: false
  },

  // Strict rate limit for authentication endpoints
  auth: {
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // Only 5 attempts per windowMs
    message: {
      success: false,
      message: 'Too many login attempts, please try again after 15 minutes'
    },
    standardHeaders: true,
    legacyHeaders: false,
    skipSuccessfulRequests: true, // Don't count successful requests
    skipFailedRequests: false
  },

  // Rate limit for file uploads
  upload: {
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 50, // Max 50 uploads per hour
    message: {
      success: false,
      message: 'Upload limit exceeded, please try again later'
    },
    standardHeaders: true,
    legacyHeaders: false
  },

  // Admin operations (higher limit)
  admin: {
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 200, // Higher limit for admins
    message: {
      success: false,
      message: 'Rate limit exceeded'
    },
    standardHeaders: true,
    legacyHeaders: false
  }
};

