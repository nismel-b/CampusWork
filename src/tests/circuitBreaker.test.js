/** 
 * Circuit breaker tests
 */
const { CircuitBreaker } = require('../proxy/circuitBreaker');

describe('Circuit Breaker', () => {
  let breaker;

  beforeEach(() => {
    breaker = new CircuitBreaker('test-service', {
      failureThreshold: 3,
      resetTimeout: 1000
    });
  });

  it('should start in CLOSED state', () => {
    expect(breaker.state).toBe('CLOSED');
  });

  it('should open after threshold failures', async () => {
    const failingRequest = jest.fn().mockRejectedValue(new Error('Service error'));

    for (let i = 0; i < 3; i++) {
      try {
        await breaker.execute(failingRequest);
      } catch (error) {
        // Expected
      }
    }

    expect(breaker.state).toBe('OPEN');
  });

  it('should transition to HALF_OPEN after timeout', async () => {
    const failingRequest = jest.fn().mockRejectedValue(new Error('Service error'));

    // Trigger circuit to open
    for (let i = 0; i < 3; i++) {
      try {
        await breaker.execute(failingRequest);
      } catch (error) {
        // Expected
      }
    }

    expect(breaker.state).toBe('OPEN');

    // Wait for reset timeout
    await new Promise(resolve => setTimeout(resolve, 1100));

    // Next request should transition to HALF_OPEN
    const successRequest = jest.fn().mockResolvedValue('success');
    await breaker.execute(successRequest);

    expect(breaker.state).toBe('HALF_OPEN');
  });

  it('should reset failures on success', async () => {
    const failingRequest = jest.fn().mockRejectedValue(new Error('Service error'));
    const successRequest = jest.fn().mockResolvedValue('success');

    // One failure
    try {
      await breaker.execute(failingRequest);
    } catch (error) {
      // Expected
    }

    expect(breaker.failures).toBe(1);

    // Success should reset
    await breaker.execute(successRequest);

    expect(breaker.failures).toBe(0);
  });
});
