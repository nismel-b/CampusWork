/**
 * Metrics collection tests
 */
const Metrics = require('../utils/metrics');

describe('Metrics', () => {
  beforeEach(() => {
    Metrics.reset();
  });

  it('should record requests', () => {
    Metrics.recordRequest('auth-service', 200, 100);
    Metrics.recordRequest('auth-service', 404, 50);

    const metrics = Metrics.getMetrics();

    expect(metrics.requests.total).toBe(2);
    expect(metrics.requests.successful).toBe(1);
    expect(metrics.requests.failed).toBe(1);
  });

  it('should track response times', () => {
    Metrics.recordRequest('auth-service', 200, 100);
    Metrics.recordRequest('auth-service', 200, 200);

    const metrics = Metrics.getMetrics();

    expect(metrics.responseTimes.min).toBe(100);
    expect(metrics.responseTimes.max).toBe(200);
    expect(metrics.responseTimes.avg).toBe(150);
  });

  it('should track errors by service', () => {
    Metrics.recordError('auth-service', 'TIMEOUT');
    Metrics.recordError('auth-service', 'TIMEOUT');
    Metrics.recordError('student-service', 'NOT_FOUND');

    const metrics = Metrics.getMetrics();

    expect(metrics.errors.total).toBe(3);
    expect(metrics.errors.byService['auth-service']).toBe(2);
    expect(metrics.errors.byService['student-service']).toBe(1);
  });
});

/**
 * FILE: src/__tests__/helpers.test.js
 * 
 * Helper functions tests
 */
const {
  cleanObject,
  buildPaginationResponse,
  safeJSONParse
} = require('../utils/helpers');

describe('Helper Functions', () => {
  describe('cleanObject', () => {
    it('should remove null and undefined values', () => {
      const input = {
        a: 1,
        b: null,
        c: undefined,
        d: 0,
        e: ''
      };

      const result = cleanObject(input);

      expect(result).toEqual({
        a: 1,
        d: 0,
        e: ''
      });
    });
  });

  describe('buildPaginationResponse', () => {
    it('should build correct pagination info', () => {
      const result = buildPaginationResponse(100, 2, 20);

      expect(result).toEqual({
        page: 2,
        limit: 20,
        total: 100,
        totalPages: 5,
        hasNext: true,
        hasPrev: true
      });
    });
  });

  describe('safeJSONParse', () => {
    it('should parse valid JSON', () => {
      const result = safeJSONParse('{"key": "value"}');
      expect(result).toEqual({ key: 'value' });
    });

    it('should return default on invalid JSON', () => {
      const result = safeJSONParse('invalid', { default: true });
      expect(result).toEqual({ default: true });
    });
  });
});

/**
 * FILE: src/__tests__/integration.test.js
 * 
 * Integration tests
 */
const request = require('supertest');
const app = require('../app');

describe('Integration Tests', () => {
  describe('Request Flow', () => {
    it('should add request ID to response', async () => {
      const response = await request(app).get('/health');

      expect(response.headers).toHaveProperty('x-request-id');
      expect(response.body).toHaveProperty('requestId');
    });

    it('should handle 404 correctly', async () => {
      const response = await request(app).get('/api/nonexistent');

      expect(response.status).toBe(404);
      expect(response.body).toHaveProperty('success', false);
      expect(response.body).toHaveProperty('message', 'Route not found');
    });
  });

  describe('CORS', () => {
    it('should include CORS headers', async () => {
      const response = await request(app)
        .options('/health')
        .set('Origin', 'http://example.com');

      expect(response.headers).toHaveProperty('access-control-allow-origin');
    });
  });

  describe('Security Headers', () => {
    it('should include security headers', async () => {
      const response = await request(app).get('/health');

      expect(response.headers).toHaveProperty('x-content-type-options');
      expect(response.headers).toHaveProperty('x-frame-options');
    });
  });
});
