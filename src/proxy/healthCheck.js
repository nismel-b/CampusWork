/** 
 * Health check proxy for monitoring service availability
 */
const axios = require('axios');
const services = require('../config/services');
const { logger } = require('../middleware/logger');

/**
 * Check health of a single service
 */
const checkServiceHealth = async (serviceName, serviceConfig) => {
  try {
    const healthUrl = `${serviceConfig.url}${serviceConfig.healthCheck}`;
    const response = await axios.get(healthUrl, {
      timeout: 3000,
      validateStatus: (status) => status === 200
    });

    return {
      service: serviceName,
      status: 'healthy',
      url: serviceConfig.url,
      responseTime: response.headers['x-response-time'] || 'N/A',
      timestamp: new Date().toISOString()
    };
  } catch (error) {
    logger.warn(`Health check failed for ${serviceName}`, {
      service: serviceName,
      error: error.message,
      code: error.code
    });

    return {
      service: serviceName,
      status: 'unhealthy',
      url: serviceConfig.url,
      error: error.message,
      code: error.code,
      timestamp: new Date().toISOString()
    };
  }
};

/**
 * Check health of all services
 */
const checkAllServicesHealth = async () => {
  const healthChecks = Object.entries(services).map(([name, config]) =>
    checkServiceHealth(name, config)
  );

  const results = await Promise.all(healthChecks);
  
  const summary = {
    totalServices: results.length,
    healthy: results.filter(r => r.status === 'healthy').length,
    unhealthy: results.filter(r => r.status === 'unhealthy').length,
    services: results,
    timestamp: new Date().toISOString()
  };

  return summary;
};

/**
 * Health check endpoint handler
 */
const healthCheckHandler = async (req, res) => {
  try {
    const health = await checkAllServicesHealth();
    
    const statusCode = health.unhealthy === 0 ? 200 : 503;
    
    res.status(statusCode).json({
      success: health.unhealthy === 0,
      gateway: 'healthy',
      ...health
    });
  } catch (error) {
    logger.error('Health check error', { error: error.message });
    
    res.status(500).json({
      success: false,
      gateway: 'error',
      error: error.message
    });
  }
};

module.exports = {
  checkServiceHealth,
  checkAllServicesHealth,
  healthCheckHandler
};

