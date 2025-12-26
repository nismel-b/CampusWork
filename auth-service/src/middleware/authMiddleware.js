const tokenService = require('../services/tokenService');
const { AuthenticationError } = require('../../../shared/utils/errorHandler');
const { asyncHandler } = require('../../../shared/utils/errorHandler');
const logger = require('../../../shared/utils/logger');

// Authenticate user from JWT token
const authenticate = asyncHandler(async (req, res, next) => {
  // Get token from header
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new AuthenticationError('No token provided');
  }

  const token = authHeader.substring(7);

  // Check if token is blacklisted
  const isBlacklisted = await tokenService.isTokenBlacklisted(token);
  if (isBlacklisted) {
    throw new AuthenticationError('Token has been revoked');
  }

  // Verify token
  const decoded = tokenService.verifyAccessToken(token);

  // Attach user info to request
  req.user = {
    userId: decoded.userId,
    email: decoded.email,
    role: decoded.role
  };

  logger.debug('User authenticated', { userId: decoded.userId });

  next();
});

// Optional authentication (doesn't fail if no token)
const optionalAuthenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const decoded = tokenService.verifyAccessToken(token);

      req.user = {
        userId: decoded.userId,
        email: decoded.email,
        role: decoded.role
      };
    }
  } catch (error) {
    // Silently fail - user remains unauthenticated
    logger.debug('Optional authentication failed', { error: error.message });
  }

  next();
};

// Authorize by role
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      throw new AuthenticationError('Authentication required');
    }

    if (!roles.includes(req.user.role)) {
      throw new AuthenticationError('Insufficient permissions');
    }

    next();
  };
};

module.exports = {
  authenticate,
  optionalAuthenticate,
  authorize
};
