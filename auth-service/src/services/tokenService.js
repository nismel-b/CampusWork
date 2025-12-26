const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const redisClient = require('../../../shared/utils/redisClient');
const logger = require('../../../shared/utils/logger');

class TokenService {
  // Generate Access Token
  generateAccessToken(user) {
    const payload = {
      userId: user.id,
      email: user.email,
      role: user.role,
      type: 'access'
    };

    return jwt.sign(payload, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '24h'
    });
  }

  // Generate Refresh Token
  generateRefreshToken(user) {
    const payload = {
      userId: user.id,
      email: user.email,
      type: 'refresh',
      tokenId: uuidv4()
    };

    return jwt.sign(payload, process.env.REFRESH_TOKEN_SECRET, {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '7d'
    });
  }

  // Verify Access Token
  verifyAccessToken(token) {
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      if (decoded.type !== 'access') {
        throw new Error('Invalid token type');
      }
      return decoded;
    } catch (error) {
      logger.error('Access token verification failed', { error: error.message });
      throw error;
    }
  }

  // Verify Refresh Token
  verifyRefreshToken(token) {
    try {
      const decoded = jwt.verify(token, process.env.REFRESH_TOKEN_SECRET);
      if (decoded.type !== 'refresh') {
        throw new Error('Invalid token type');
      }
      return decoded;
    } catch (error) {
      logger.error('Refresh token verification failed', { error: error.message });
      throw error;
    }
  }

  // Blacklist Token (for logout)
  async blacklistToken(token) {
    try {
      const decoded = jwt.decode(token);
if (!decoded || !decoded.exp) {
return false;
}
const ttl = decoded.exp - Math.floor(Date.now() / 1000);
  if (ttl > 0) {
    await redisClient.set(`blacklist:${token}`, 'true', ttl);
    logger.info('Token blacklisted', { userId: decoded.userId });
    return true;
  }
  return false;
} catch (error) {
  logger.error('Failed to blacklist token', { error: error.message });
  return false;
}
}
// Check if token is blacklisted
async isTokenBlacklisted(token) {
try {
return await redisClient.exists(`blacklist:${token}`);
} catch (error) {
logger.error('Failed to check token blacklist', { error: error.message });
return false;
}
}
// Generate Email Verification Token
generateVerificationToken() {
return uuidv4();
}
// Generate Password Reset Token
generatePasswordResetToken() {
return uuidv4();
}
}
module.exports = new TokenService();
