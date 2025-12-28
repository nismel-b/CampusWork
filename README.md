# API Gateway

Single entry point for all CampusWork microservices.

##  Features

- **Unified API Entry Point**
  - Single endpoint for all services
  - Automatic request routing
  - Service discovery

- **Authentication & Authorization**
  - JWT token validation
  - Role-based access control
  - Automatic user info forwarding

- **Security**
  - Rate limiting
  - CORS protection
  - Helmet security headers
  - Request/response compression

- **High Availability**
  - Health checks
  - Graceful shutdown
  - Error handling & retry logic
  - Service timeout management

- **Monitoring & Logging**
  - Request/response logging
  - Error tracking
  - Performance metrics

##  Prerequisites

- Node.js 18+
- Docker & Docker Compose
- Running microservices (Auth, Student, Lecturer, Admin, Project)

##  Installation

### Using Docker Compose (Recommended)

```bash
# Navigate to API Gateway directory
cd services/api-gateway

# Start API Gateway
docker-compose up -d

# View logs
docker-compose logs -f api-gateway
```

### Local Development

```bash
# Navigate to service directory
cd services/api-gateway

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env with your configuration
nano .env

# Start the gateway
npm run dev
```

##  API Routes

All requests go through the API Gateway at `http://localhost:3000`

### Auth Service Routes
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login
- `POST /api/auth/logout` - Logout
- `POST /api/auth/refresh-token` - Refresh token
- `GET /api/users/me` - Get current user (auth required)
- `PUT /api/users/me` - Update user (auth required)

### Student Service Routes
- `GET /api/students/search` - Search students
- `POST /api/students/profile` - Create student profile (auth required)
- `GET /api/students/profile/me` - Get own profile (auth required)
- `PUT /api/students/profile/me` - Update profile (auth required)

### Lecturer Service Routes
- `GET /api/lecturers/search` - Search lecturers
- `POST /api/lecturers/profile` - Create lecturer profile (auth required)
- `GET /api/lecturers/profile/me` - Get own profile (auth required)
- `PUT /api/lecturers/profile/me` - Update profile (auth required)

### Admin Service Routes
- `GET /api/admin/users` - Get all users (admin only)
- `POST /api/admin/users` - Create user (admin only)
- `GET /api/admin/logs` - Get admin logs (admin only)
- `GET /api/admin/analytics/overview` - Platform overview (admin only)

### Project Service Routes
- `GET /api/projects` - Get projects
- `POST /api/projects` - Create project (auth required)
- `GET /api/projects/:id` - Get project details
- `PUT /api/projects/:id` - Update project (auth required)

##  Example Usage

### Register User

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "SecurePass123!",
    "firstName": "John",
    "lastName": "Doe",
    "role": "student"
  }'
```

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "SecurePass123!"
  }'
```

Response:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1...",
    "refreshToken": "eyJhbGciOiJIUzI1...",
    "user": {
      "userId": "uuid",
      "email": "student@example.com",
      "role": "student"
    }
  }
}
```

### Access Protected Route

```bash
curl -X GET http://localhost:3000/api/students/profile/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Admin Action

```bash
curl -X GET http://localhost:3000/api/admin/users \
  -H "Authorization: Bearer ADMIN_ACCESS_TOKEN"
```

##  Configuration

### Environment Variables

```env
# Server
NODE_ENV=production
PORT=3000

# JWT (must match Auth Service)
JWT_SECRET=your-super-secret-jwt-key

# Microservices URLs
AUTH_SERVICE_URL=http://auth-service:3001
STUDENT_SERVICE_URL=http://student-service:3002
LECTURER_SERVICE_URL=http://lecturer-service:3003
ADMIN_SERVICE_URL=http://admin-service:3004
PROJECT_SERVICE_URL=http://project-service:3005

# CORS
CORS_ORIGIN=*

# Logging
LOG_LEVEL=info
```

### Rate Limiting

The API Gateway implements rate limiting:

- **General API**: 100 requests per 15 minutes per IP
- **Auth endpoints** (login/register): 5 requests per 15 minutes per IP
- **Upload endpoints**: 50 requests per hour per IP

### Timeouts

- **Default timeout**: 5 seconds
- **Upload timeout**: 10 seconds

##  Architecture


┌─────────────────────────────────────────────────────┐
│                   API Gateway                       │
│                  (Port 3000)                        │
├─────────────────────────────────────────────────────┤
│  - Authentication                                   │
│  - Rate Limiting                                    │
│  - Request Logging                                  │
│  - Error Handling                                   │
└─────────────────────────────────────────────────────┘
                         │
         ┌───────────────┼───────────────┬─────────────┐
         │               │               │             │
    ┌────▼────┐    ┌────▼────┐    ┌────▼────┐   ┌────▼────┐
    │  Auth   │    │ Student │    │Lecturer │   │  Admin  │
    │ Service │    │ Service │    │ Service │   │ Service │
    │  :3001  │    │  :3002  │    │  :3003  │   │  :3004  │
    └─────────┘    └─────────┘    └─────────┘   └─────────┘


##  Security Features

### 1. JWT Authentication
- Validates JWT tokens from Auth Service
- Forwards user info to microservices
- Supports token refresh

### 2. Rate Limiting
- IP-based rate limiting
- Different limits for different endpoints
- Prevents abuse and DDoS

### 3. CORS Protection
- Configurable allowed origins
- Credential support
- Method restrictions

### 4. Request Sanitization
- Body size limits (50MB)
- Header validation
- Query parameter sanitization

### 5. Security Headers (Helmet)
- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security
- Content-Security-Policy

##  Monitoring

### Health Checks

```bash
# Check if gateway is healthy
curl http://localhost:3000/health

# Check if gateway is ready
curl http://localhost:3000/ready

# Check if gateway is alive
curl http://localhost:3000/live
```

### Logs

Logs are written to:
- `logs/combined.log` - All logs
- `logs/error.log` - Error logs only

View logs in real-time:
```bash
tail -f logs/combined.log
```

##  Troubleshooting

### Service Unavailable (503)

**Problem**: API Gateway returns 503 Service Unavailable

**Solutions**:
1. Check if microservices are running:
   ```bash
   docker ps | grep -E "auth-service|student-service|lecturer-service"
   ```

2. Check microservice health:
   ```bash
   curl http://localhost:3001/health  # Auth Service
   curl http://localhost:3002/health  # Student Service
   curl http://localhost:3003/health  # Lecturer Service
   ```

3. Check network connectivity:
   ```bash
   docker network inspect campus-network
   ```

### Gateway Timeout (504)

**Problem**: Requests timing out

**Solutions**:
1. Increase timeout in `src/config/services.js`
2. Check microservice performance
3. Check database connections

### Rate Limit Exceeded

**Problem**: Getting "Too many requests" error

**Solutions**:
1. Wait for the rate limit window to reset
2. Adjust rate limits in `src/middleware/rateLimiter.js`
3. Use different IP or wait

### Authentication Failed

**Problem**: Getting 401 Unauthorized

**Solutions**:
1. Verify JWT_SECRET matches Auth Service
2. Check token expiration
3. Ensure Bearer token format: `Bearer <token>`

##  Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage
```

##  Docker Commands

```bash
# Build image
docker build -t campus-api-gateway .

# Run container
docker run -p 3000:3000 --env-file .env campus-api-gateway

# View logs
docker logs -f campus-api-gateway

# Stop container
docker stop campus-api-gateway

# Remove container
docker rm campus-api-gateway
```

##  Deployment

### Production Checklist

- [ ] Set strong `JWT_SECRET`
- [ ] Configure proper `CORS_ORIGIN`
- [ ] Set `NODE_ENV=production`
- [ ] Configure proper rate limits
- [ ] Set up log rotation
- [ ] Configure HTTPS/SSL
- [ ] Set up monitoring and alerts
- [ ] Configure backup strategy

### Environment-Specific Config

**Development**:
```env
NODE_ENV=development
CORS_ORIGIN=*
LOG_LEVEL=debug
```

**Production**:
```env
NODE_ENV=production
CORS_ORIGIN=https://campus.eduproject.com
LOG_LEVEL=info
```

##  Additional Resources

- [Express.js Documentation](https://expressjs.com/)
- [http-proxy-middleware](https://github.com/chimurai/http-proxy-middleware)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [API Gateway Pattern](https://microservices.io/patterns/apigateway.html)

##  License

MIT

##  Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request
