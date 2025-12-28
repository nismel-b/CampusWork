/** 
 * Health check endpoint tests
 */
const request = require('supertest');
const app = require('../app');

describe('Health Check Endpoints', () => {
  describe('GET /health', () => {
    it('should return 200 and health status', async () => {
      const response = await request(app).get('/health');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status', 'healthy');
      expect(response.body).toHaveProperty('service', 'api-gateway');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body).toHaveProperty('uptime');
    });
  });

  describe('GET /live', () => {
    it('should return 200 and liveness status', async () => {
      const response = await request(app).get('/live');
      
      expect(response.status).toBe(200);
      expect(response.body).toHaveProperty('status', 'alive');
      expect(response.body).toHaveProperty('service', 'api-gateway');
    });
  });
});
