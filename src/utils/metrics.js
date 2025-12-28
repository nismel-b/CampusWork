/** 
 * Metrics collection for monitoring
 */
const { logger } = require('../middleware/logger');

class Metrics {
  constructor() {
    this.requests = {
      total: 0,
      successful: 0,
      failed: 0,
      byService: {},
      byStatus: {}
    };
    
    this.responseTimes = {
      min: Infinity,
      max: 0,
      avg: 0,
      total: 0,
      count: 0
    };

    this.errors = {
      total: 0,
      byType: {},
      byService: {}
    };

    // Reset metrics every hour
    setInterval(() => this.reset(), 60 * 60 * 1000);
  }

  /**
   * Record a request
   */
  recordRequest(service, statusCode, responseTime) {
    this.requests.total++;
    
    if (statusCode >= 200 && statusCode < 400) {
      this.requests.successful++;
    } else {
      this.requests.failed++;
    }

    // By service
    if (!this.requests.byService[service]) {
      this.requests.byService[service] = 0;
    }
    this.requests.byService[service]++;

    // By status
    if (!this.requests.byStatus[statusCode]) {
      this.requests.byStatus[statusCode] = 0;
    }
    this.requests.byStatus[statusCode]++;

    // Response time
    this.recordResponseTime(responseTime);
  }

  /**
   * Record response time
   */
  recordResponseTime(time) {
    this.responseTimes.count++;
    this.responseTimes.total += time;
    this.responseTimes.avg = this.responseTimes.total / this.responseTimes.count;
    
    if (time < this.responseTimes.min) {
      this.responseTimes.min = time;
    }
    
    if (time > this.responseTimes.max) {
      this.responseTimes.max = time;
    }
  }

  /**
   * Record an error
   */
  recordError(service, errorType) {
    this.errors.total++;

    if (!this.errors.byType[errorType]) {
      this.errors.byType[errorType] = 0;
    }
    this.errors.byType[errorType]++;

    if (!this.errors.byService[service]) {
      this.errors.byService[service] = 0;
    }
    this.errors.byService[service]++;
  }

  /**
   * Get current metrics
   */
  getMetrics() {
    return {
      requests: this.requests,
      responseTimes: {
        ...this.responseTimes,
        min: this.responseTimes.min === Infinity ? 0 : this.responseTimes.min
      },
      errors: this.errors,
      timestamp: new Date().toISOString()
    };
  }

  /**
   * Reset metrics
   */
  reset() {
    logger.info('Resetting metrics');
    
    this.requests = {
      total: 0,
      successful: 0,
      failed: 0,
      byService: {},
      byStatus: {}
    };
    
    this.responseTimes = {
      min: Infinity,
      max: 0,
      avg: 0,
      total: 0,
      count: 0
    };

    this.errors = {
      total: 0,
      byType: {},
      byService: {}
    };
  }
}

// Export singleton instance
module.exports = new Metrics();

