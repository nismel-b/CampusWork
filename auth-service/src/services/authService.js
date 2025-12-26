const { User } = require('../models');
const tokenService = require('./tokenService');
const eventPublisher = require('../../../shared/utils/eventPublisher');
const redisClient = require('../../../shared/utils/redisClient');
const logger = require('../../../shared/utils/logger');
const { 
  ValidationError, 
  AuthenticationError, 
  ConflictError,
  NotFoundError 
} = require('../../../shared/utils/errorHandler');

class AuthService {
  // Register new user
  async register(userData) {
    try {
      // Check if user already exists
      const existingUser = await User.findOne({ 
        where: { email: userData.email } 
      });

      if (existingUser) {
        throw new ConflictError('Email address already registered');
      }

      // Generate verification token
      const verificationToken = tokenService.generateVerificationToken();
      const verificationExpires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours

      // Create user
      const user = await User.create({
        ...userData,
        emailVerificationToken: verificationToken,
        emailVerificationExpires: verificationExpires
      });

      logger.info('User registered', { 
        userId: user.id, 
        email: user.email,
        role: user.role 
      });

      // Publish user.created event
      await eventPublisher.publish('user.created', {
        userId: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        verificationToken,
        verificationExpires
      });

      return {
        user: user.toJSON(),
        verificationToken // In production, send via email
      };
    } catch (error) {
      logger.error('Registration failed', { 
        email: userData.email,
        error: error.message 
      });
      throw error;
    }
  }

  // Login user
  async login(email, password, ipAddress) {
    try {
      // Find user
      const user = await User.findOne({ where: { email } });

      if (!user) {
        throw new AuthenticationError('Invalid email or password');
      }

      // Check if account is locked
      if (user.isLocked()) {
        const lockTimeRemaining = Math.ceil((user.lockUntil - Date.now()) / 1000 / 60);
        throw new AuthenticationError(
          `Account is temporarily locked. Please try again in ${lockTimeRemaining} minutes`
        );
      }

      // Check account status
      if (user.accountStatus !== 'active') {
        throw new AuthenticationError('Account is suspended or deleted');
      }

      // Verify password
      const isPasswordValid = await user.comparePassword(password);

      if (!isPasswordValid) {
        // Increment login attempts
        user.loginAttempts += 1;

        // Lock account after 5 failed attempts
        if (user.loginAttempts >= 5) {
          user.lockUntil = new Date(Date.now() + 30 * 60 * 1000); // 30 minutes
          await user.save();
          
          logger.warn('Account locked due to failed login attempts', { 
            userId: user.id,
            email: user.email 
          });

          throw new AuthenticationError(
            'Account locked due to too many failed login attempts. Please try again in 30 minutes'
          );
        }

        await user.save();
        throw new AuthenticationError('Invalid email or password');
      }

      // Reset login attempts on successful login
      user.loginAttempts = 0;
      user.lockUntil = null;
      user.lastLogin = new Date();
      await user.save();

      // Generate tokens
      const accessToken = tokenService.generateAccessToken(user);
      const refreshToken = tokenService.generateRefreshToken(user);

      // Cache user session in Redis
      await redisClient.set(
        `session:${user.id}`,
        { 
          userId: user.id,
          email: user.email,
          role: user.role,
          lastLogin: user.lastLogin 
        },
        3600 // 1 hour
      );

      logger.info('User logged in', { 
        userId: user.id,
        email: user.email,
        ipAddress 
      });

      // Publish user.logged_in event
      await eventPublisher.publish('user.logged_in', {
        userId: user.id,
        email: user.email,
        role: user.role,
        ipAddress,
        timestamp: new Date()
      });

      return {
        user: user.toJSON(),
        accessToken,
        refreshToken
      };
    } catch (error) {
      logger.error('Login failed', { 
        email,
        error: error.message 
      });
      throw error;
    }
  }

  // Logout user
  async logout(userId, accessToken) {
    try {
      // Blacklist the token
      await tokenService.blacklistToken(accessToken);

      // Remove session from Redis
      await redisClient.del(`session:${userId}`);

      logger.info('User logged out', { userId });

      // Publish user.logged_out event
      await eventPublisher.publish('user.logged_out', {
        userId,
        timestamp: new Date()
      });

      return { success: true };
    } catch (error) {
      logger.error('Logout failed', { 
        userId,
        error: error.message 
      });
      throw error;
    }
  }

  // Refresh access token
  async refreshToken(refreshToken) {
    try {
      // Verify refresh token
      const decoded = tokenService.verifyRefreshToken(refreshToken);

      // Check if token is blacklisted
      const isBlacklisted = await tokenService.isTokenBlacklisted(refreshToken);
      if (isBlacklisted) {
        throw new AuthenticationError('Token has been revoked');
      }

      // Find user
      const user = await User.findByPk(decoded.userId);

      if (!user || user.accountStatus !== 'active') {
        throw new AuthenticationError('User not found or inactive');
      }

      // Generate new access token
      const newAccessToken = tokenService.generateAccessToken(user);

      logger.info('Token refreshed', { userId: user.id });

      return {
        accessToken: newAccessToken,
        user: user.toJSON()
      };
    } catch (error) {
      logger.error('Token refresh failed', { error: error.message });
      throw error;
    }
  }

  // Verify email
  async verifyEmail(token) {
    try {
      const user = await User.findOne({ 
        where: { 
          emailVerificationToken: token,
          emailVerified: false
        } 
      });

      if (!user) {
        throw new NotFoundError('Invalid or expired verification token');
      }

      // Check if token has expired
      if (user.emailVerificationExpires < new Date()) {
        throw new ValidationError('Verification token has expired');
      }

      // Update user
      user.emailVerified = true;
      user.emailVerificationToken = null;
      user.emailVerificationExpires = null;
      await user.save();

      logger.info('Email verified', { 
        userId: user.id,
        email: user.email 
      });

      // Publish user.email_verified event
      await eventPublisher.publish('user.email_verified', {
        userId: user.id,
        email: user.email
      });

      return { 
        success: true,
        user: user.toJSON() 
      };
    } catch (error) {
      logger.error('Email verification failed', { error: error.message });
      throw error;
    }
  }

  // Request password reset
  async requestPasswordReset(email) {
    try {
      const user = await User.findOne({ where: { email } });

      if (!user) {
        // Don't reveal if email exists
        logger.warn('Password reset requested for non-existent email', { email });
        return { 
          success: true,
          message: 'If the email exists, a reset link has been sent' 
        };
      }

      // Generate reset token
      const resetToken = tokenService.generatePasswordResetToken();
      const resetExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

      user.passwordResetToken = resetToken;
      user.passwordResetExpires = resetExpires;
      await user.save();

      logger.info('Password reset requested', { 
        userId: user.id,
        email: user.email 
      });

      // Publish password_reset.requested event
      await eventPublisher.publish('password_reset.requested', {
        userId: user.id,
        email: user.email,
        resetToken,
        resetExpires
      });

      return { 
        success: true,
        resetToken // In production, send via email
      };
    } catch (error) {
      logger.error('Password reset request failed', { 
        email,
        error: error.message 
      });
      throw error;
    }
  }

  // Reset password
  async resetPassword(token, newPassword) {
    try {
      const user = await User.findOne({ 
        where: { passwordResetToken: token } 
      });

      if (!user) {
        throw new NotFoundError('Invalid or expired reset token');
      }

      // Check if token has expired
      if (user.passwordResetExpires < new Date()) {
        throw new ValidationError('Reset token has expired');
      }

      // Update password
      user.password = newPassword;
      user.passwordResetToken = null;
      user.passwordResetExpires = null;
      user.loginAttempts = 0;
      user.lockUntil = null;
      await user.save();

      logger.info('Password reset', { 
        userId: user.id,
        email: user.email 
      });

      // Publish password_reset.completed event
      await eventPublisher.publish('password_reset.completed', {
        userId: user.id,
        email: user.email
      });

      return { 
        success: true,
        message: 'Password reset successfully' 
      };
    } catch (error) {
      logger.error('Password reset failed', { error: error.message });
      throw error;
    }
  }

  // Get user by ID
  async getUserById(userId) {
    try {
      // Check cache first
      const cachedUser = await redisClient.get(`user:${userId}`);
      if (cachedUser) {
        return cachedUser;
      }

      const user = await User.findByPk(userId);

      if (!user) {
        throw new NotFoundError('User not found');
      }

      const userData = user.toJSON();

      // Cache for 1 hour
      await redisClient.set(`user:${userId}`, userData, 3600);

      return userData;
    } catch (error) {
      logger.error('Failed to get user', { 
        userId,
        error: error.message 
      });
      throw error;
    }
  }

  // Validate user credentials (for internal service calls)
  async validateUser(userId, requiredRole = null) {
    try {
      const user = await this.getUserById(userId);

      if (user.accountStatus !== 'active') {
        throw new AuthenticationError('User account is not active');
      }

      if (requiredRole && user.role !== requiredRole) {
        throw new AuthenticationError('Insufficient permissions');
      }

      return user;
    } catch (error) {
      logger.error('User validation failed', { 
        userId,
        error: error.message 
      });
      throw error;
    }
  }
}

module.exports = new AuthService();
