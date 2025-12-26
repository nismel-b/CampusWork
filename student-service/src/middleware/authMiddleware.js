const jwt = require('jsonwebtoken');
const redisClient = require('../../../shared/utils/redisClient');
const { AuthenticationError, AuthorizationError } = require('../../../shared/utils/errorHandler');
const { asyncHandler } = require('../../../shared/utils/errorHandler');
const logger = require('../../../shared/utils/logger');
const authenticate = asyncHandler(async (req, res, next) => {
// 1. EXTRACT TOKEN FROM HEADER
const authHeader = req.headers.authorization;

if (!authHeader || !authHeader.startsWith('Bearer ')) {
throw new AuthenticationError('No token provided. Please login.');
}
const token = authHeader.substring(7);  // Remove 'Bearer ' prefix
try {
// 2. VERIFY TOKEN SIGNATURE
const decoded = jwt.verify(token, process.env.JWT_SECRET);
// 3. CHECK IF TOKEN IS BLACKLISTED
// (Tokens are blacklisted on logout in Auth Service)
const isBlacklisted = await redisClient.exists(`blacklist:${token}`);

if (isBlacklisted) {
  throw new AuthenticationError('Token has been revoked. Please login again.');
}

// 4. ATTACH USER INFO TO REQUEST
req.user = {
  userId: decoded.userId,
  email: decoded.email,
  role: decoded.role
};

logger.debug('User authenticated', { 
  userId: decoded.userId,
  role: decoded.role 
});

next();  // Proceed to next middleware/controller
} catch (error) {
if (error.name === 'JsonWebTokenError') {
throw new AuthenticationError('Invalid token. Please login again.');
}
if (error.name === 'TokenExpiredError') {
throw new AuthenticationError('Token has expired. Please login again.');
}
throw error;  // Re-throw if already our custom error
}
});
const optionalAuthenticate = async (req, res, next) => {
try {
const authHeader = req.headers.authorization;
if (authHeader && authHeader.startsWith('Bearer ')) {
const token = authHeader.substring(7);
const decoded = jwt.verify(token, process.env.JWT_SECRET);
// Check blacklist
const isBlacklisted = await redisClient.exists('blacklist:${token}');
if (!isBlacklisted) {
req.user = {
userId: decoded.userId,
email: decoded.email,
role: decoded.role
};
}
}
} catch (error) {
// Silently fail - request continues as unauthenticated
logger.debug('Optional authentication failed', { error: error.message });
}

next();
};
const authorize = (...roles) => {
return (req, res, next) => {
// Ensure user is authenticated
if (!req.user) {
throw new AuthenticationError('Authentication required');
}
// Check if user's role is in allowed roles
if (!roles.includes(req.user.role)) {
logger.warn('Authorization failed', {
userId: req.user.userId,
userRole: req.user.role,
requiredRoles: roles
});
/*throw new AuthorizationError(
'Access denied. Required role:' ${roles.join(' or ')}
);*/

throw new AuthorizationError(
  `Access denied. Required role: ${roles.join(' or ')}`
);

}
next();
};
};

module.exports = {
authenticate,
optionalAuthenticate,
authorize
};
