/**
 * Circuit breaker pattern implementation
 * Prevents cascading failures when a service is down
 */
const { logger } = require('../middleware/logger');

class CircuitBreaker {
  constructor(serviceName, options = {}) {
    this.serviceName = serviceName;
    this.failureThreshold = options.failureThreshold || 5;
    this.resetTimeout = options.resetTimeout || 60000; // 1 minute
    this.monitoringPeriod = options.monitoringPeriod || 10000; // 10 seconds
    
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failures = 0;
    this.lastFailureTime = null;
    this.successCount = 0;
  }

  /**
   * Execute request through circuit breaker
   */
  async execute(request) {
    if (this.state === 'OPEN') {
      // Check if we should try again
      if (Date.now() - this.lastFailureTime >= this.resetTimeout) {
        this.state = 'HALF_OPEN';
        logger.info(`Circuit breaker ${this.serviceName}: Attempting to close (HALF_OPEN)`);
      } else {
        throw new Error(`Circuit breaker is OPEN for ${this.serviceName}`);
      }
    }

    try {
      const result = await request();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  /**
   * Handle successful request
   */
  onSuccess() {
    this.failures = 0;
    
    if (this.state === 'HALF_OPEN') {
      this.successCount++;
      
      if (this.successCount >= 2) {
        this.state = 'CLOSED';
        this.successCount = 0;
        logger.info(`Circuit breaker ${this.serviceName}: CLOSED`);
      }
    }
  }

  /**
   * Handle failed request
   */
  onFailure() {
    this.failures++;
    this.lastFailureTime = Date.now();

    if (this.state === 'HALF_OPEN') {
      this.state = 'OPEN';
      logger.warn(`Circuit breaker ${this.serviceName}: Re-opened after failure in HALF_OPEN state`);
      return;
    }

    if (this.failures >= this.failureThreshold) {
      this.state = 'OPEN';
      logger.error(`Circuit breaker ${this.serviceName}: OPEN after ${this.failures} failures`);
    }
  }

  /**
   * Get current state
   */
  getState() {
    return {
      service: this.serviceName,
      state: this.state,
      failures: this.failures,
      lastFailureTime: this.lastFailureTime,
      successCount: this.successCount
    };
  }

  /**
   * Manually reset circuit breaker
   */
  reset() {
    this.state = 'CLOSED';
    this.failures = 0;
    this.lastFailureTime = null;
    this.successCount = 0;
    logger.info(`Circuit breaker ${this.serviceName}: Manually reset`);
  }
}

// Create circuit breakers for each service
const circuitBreakers = {};

const getCircuitBreaker = (serviceName) => {
  if (!circuitBreakers[serviceName]) {
    circuitBreakers[serviceName] = new CircuitBreaker(serviceName);
  }
  return circuitBreakers[serviceName];
};

module.exports = {
  CircuitBreaker,
  getCircuitBreaker,
  circuitBreakers
};
