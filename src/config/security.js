/** 
 * Security configuration
 */
module.exports = {
  // Helmet configuration
  helmet: {
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
      },
    },
    hsts: {
      maxAge: 31536000, // 1 year
      includeSubDomains: true,
      preload: true
    },
    referrerPolicy: {
      policy: 'strict-origin-when-cross-origin'
    }
  },

  // JWT configuration
  jwt: {
    secret: process.env.JWT_SECRET,
    algorithms: ['HS256'],
    ignoreExpiration: false
  },

  // Body parser limits
  bodyParser: {
    json: {
      limit: '10mb'
    },
    urlencoded: {
      limit: '10mb',
      extended: true,
      parameterLimit: 50000
    }
  },

  // Trusted proxies (for production behind load balancer)
  trustedProxies: process.env.TRUSTED_PROXIES 
    ? process.env.TRUSTED_PROXIES.split(',')
    : []
};
