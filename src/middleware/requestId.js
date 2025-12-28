/**
 * Request ID middleware for tracing
 */
const crypto = require('crypto');

/**
 * Add unique request ID to each request
 */
const requestId = (req, res, next) => {
  req.id = req.headers['x-request-id'] || crypto.randomUUID();
  res.setHeader('X-Request-Id', req.id);
  next();
};

module.exports = { requestId };
