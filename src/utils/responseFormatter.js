/**
 * Standardized API response formatting
 */

/**
 * Success response
 */
const successResponse = (message, data = null, pagination = null) => {
  const response = {
    success: true,
    message,
    ...(data && { data }),
    ...(pagination && { pagination })
  };

  return response;
};

/**
 * Error response
 */
const errorResponse = (message, errors = null, statusCode = 500) => {
  const response = {
    success: false,
    message,
    statusCode,
    ...(errors && { errors })
  };

  return response;
};

/**
 * Validation error response
 */
const validationErrorResponse = (errors) => {
  return {
    success: false,
    message: 'Validation failed',
    errors: Array.isArray(errors) ? errors : [errors]
  };
};

module.exports = {
  successResponse,
  errorResponse,
  validationErrorResponse
};
