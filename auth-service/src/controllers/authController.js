const authService = require('../services/authService');
const ResponseHandler = require('../../../shared/utils/responseHandler');
const { asyncHandler } = require('../../../shared/utils/errorHandler');

class AuthController {
  // Register
  register = asyncHandler(async (req, res) => {
    const result = await authService.register(req.body);
    
    ResponseHandler.created(res, result, 'User registered successfully');
  });

  // Login
  login = asyncHandler(async (req, res) => {
    const { email, password } = req.body;
    const ipAddress = req.ip;

    const result = await authService.login(email, password, ipAddress);

    // Set refresh token in HTTP-only cookie
    res.cookie('refreshToken', result.refreshToken, {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: 7 * 24 * 60 * 60 * 1000 // 7 days
    });

    ResponseHandler.success(res, {
      user: result.user,
      accessToken: result.accessToken
    }, 'Login successful');
  });

  // Logout
  logout = asyncHandler(async (req, res) => {
    const userId = req.user.userId;
    const accessToken = req.headers.authorization?.split(' ')[1];

    await authService.logout(userId, accessToken);

    // Clear refresh token cookie
    res.clearCookie('refreshToken');

    ResponseHandler.success(res, null, 'Logout successful');
  });

  // Refresh Token
  refreshToken = asyncHandler(async (req, res) => {
    const refreshToken = req.cookies.refreshToken || req.body.refreshToken;

    if (!refreshToken) {
      return ResponseHandler.error(res, 'Refresh token not provided', 401);
    }

    const result = await authService.refreshToken(refreshToken);

    ResponseHandler.success(res, result, 'Token refreshed successfully');
  });

  // Verify Email
  verifyEmail = asyncHandler(async (req, res) => {
    const { token } = req.params;

    const result = await authService.verifyEmail(token);

    ResponseHandler.success(res, result, 'Email verified successfully');
  });

  // Request Password Reset
  requestPasswordReset = asyncHandler(async (req, res) => {
    const { email } = req.body;

    const result = await authService.requestPasswordReset(email);

    ResponseHandler.success(res, result, 'Password reset email sent');
  });

  // Reset Password
  resetPassword = asyncHandler(async (req, res) => {
    const { token } = req.params;
    const { password } = req.body;

    const result = await authService.resetPassword(token, password);

    ResponseHandler.success(res, result, 'Password reset successful');
  });

  // Get Current User
  getCurrentUser = asyncHandler(async (req, res) => {
    const userId = req.user.userId;

    const user = await authService.getUserById(userId);

    ResponseHandler.success(res, user, 'User retrieved successfully');
  });

  // Validate User (Internal endpoint for other services)
  validateUser = asyncHandler(async (req, res) => {
    const { userId, requiredRole } = req.body;

    const user = await authService.validateUser(userId, requiredRole);

    ResponseHandler.success(res, user, 'User validated successfully');
  });
}

module.exports = new AuthController();
