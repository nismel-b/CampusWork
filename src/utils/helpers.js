/**
 * General helper functions
 */

/**
 * Sleep function
 */
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

/**
 * Retry function with exponential backoff
 */
const retry = async (fn, options = {}) => {
  const {
    maxAttempts = 3,
    delay = 1000,
    backoff = 2,
    onRetry = null
  } = options;

  let lastError;
  
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      
      if (attempt === maxAttempts) {
        throw error;
      }
      
      const waitTime = delay * Math.pow(backoff, attempt - 1);
      
      if (onRetry) {
        onRetry(attempt, waitTime, error);
      }
      
      await sleep(waitTime);
    }
  }
  
  throw lastError;
};

/**
 * Parse pagination parameters
 */
const parsePagination = (req) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const offset = (page - 1) * limit;
  
  return {
    page,
    limit,
    offset
  };
};

/**
 * Build pagination response
 */
const buildPaginationResponse = (total, page, limit) => {
  return {
    page,
    limit,
    total,
    totalPages: Math.ceil(total / limit),
    hasNext: page * limit < total,
    hasPrev: page > 1
  };
};

/**
 * Safe JSON parse
 */
const safeJSONParse = (str, defaultValue = null) => {
  try {
    return JSON.parse(str);
  } catch (error) {
    return defaultValue;
  }
};

/**
 * Remove undefined/null values from object
 */
const cleanObject = (obj) => {
  return Object.entries(obj).reduce((acc, [key, value]) => {
    if (value !== undefined && value !== null) {
      acc[key] = value;
    }
    return acc;
  }, {});
};

/**
 * Generate random string
 */
const randomString = (length = 32) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result = '';
  for (let i = 0; i < length; i++) {
    result += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return result;
};

module.exports = {
  sleep,
  retry,
  parsePagination,
  buildPaginationResponse,
  safeJSONParse,
  cleanObject,
  randomString
};
