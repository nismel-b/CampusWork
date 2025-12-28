/**
 * Authentication middleware tests
 */
const jwt = require('jsonwebtoken');
const { verifyToken, checkRole } = require('../middleware/authMiddleware');

// Mock jwt module
jest.mock('jsonwebtoken');

describe('Authentication Middleware', () => {
  beforeEach(() => {
    // Reset mocks before each test
    jest.clearAllMocks();
    // Set environment variable
    process.env.JWT_SECRET = 'test-secret';
  });

  describe('verifyToken', () => {
    it('should reject request without token', async () => {
      const req = { headers: {} };
      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn()
      };
      const next = jest.fn();

      verifyToken(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: false,
          message: expect.stringContaining('No token')
        })
      );
    });

    it('should reject invalid token', async () => {
      // Mock jwt.verify to throw error
      jwt.verify.mockImplementation(() => {
        const error = new Error('Invalid token');
        error.name = 'JsonWebTokenError';
        throw error;
      });

      const req = {
        headers: {
          authorization: 'Bearer invalid-token'
        }
      };
      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn()
      };
      const next = jest.fn();

      verifyToken(req, res, next);

      expect(res.status).toHaveBeenCalledWith(401);
    });

    it('should accept valid token', async () => {
      // Mock jwt.verify to return valid decoded token
      jwt.verify.mockReturnValue({
        userId: 'test-id',
        email: 'test@example.com',
        role: 'student',
        iat: Math.floor(Date.now() / 1000),
        exp: Math.floor(Date.now() / 1000) + 3600
      });

      const req = {
        headers: {
          authorization: 'Bearer valid-token'
        }
      };
      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn()
      };
      const next = jest.fn();

      verifyToken(req, res, next);

      expect(next).toHaveBeenCalled();
      expect(req.user).toBeDefined();
      expect(req.user.userId).toBe('test-id');
    });
  });

  describe('checkRole', () => {
    it('should allow user with correct role', () => {
      const req = {
        user: { role: 'admin' }
      };
      const res = {};
      const next = jest.fn();

      const middleware = checkRole(['admin']);
      middleware(req, res, next);

      expect(next).toHaveBeenCalled();
    });

    it('should reject user with incorrect role', () => {
      const req = {
        user: { role: 'student' }
      };
      const res = {
        status: jest.fn().mockReturnThis(),
        json: jest.fn()
      };
      const next = jest.fn();

      const middleware = checkRole(['admin']);
      middleware(req, res, next);

      expect(res.status).toHaveBeenCalledWith(403);
      expect(res.json).toHaveBeenCalledWith(
        expect.objectContaining({
          success: false,
          message: expect.stringContaining('Access denied')
        })
      );
    });
  });
});

