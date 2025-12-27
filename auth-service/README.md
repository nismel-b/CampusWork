# Auth Service

Authentication and user management microservice for Campus eduproject.

##  Features

- **User Registration & Authentication**
  - Email/password registration
  - Login with JWT tokens
  - Refresh token mechanism
  - Email verification
  - Password reset functionality

- **Role-Based Access Control (RBAC)**
  - Student role
  - Lecturer role
  - Admin role

- **Security**
  - Bcrypt password hashing
  - JWT token-based authentication
  - Rate limiting
  - CORS protection
  - Helmet security headers

- **Event-Driven Architecture**
  - Publishes events to RabbitMQ
  - `user.created`, `user.updated`, `user.deleted` events

- **Caching**
  - Redis for session management
  - Token blacklisting

##  Prerequisites

- Node.js 18+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+
- RabbitMQ 3+

##  Installation

### Using Docker Compose (Recommended)

```bash
# Clone the repository
cd services/auth-service

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f auth-service
```

### Local Development

```bash
# Navigate to service directory
cd services/auth-service

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env with your configuration
nano .env

# Start PostgreSQL, Redis, and RabbitMQ
docker-compose up -d auth-db redis rabbitmq

# Start the service
npm run dev
```

## 🌐 API Endpoints

### Health Checks

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness check |
| GET | `/live` | Liveness check |

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | Login user |
| POST | `/api/auth/logout` | Logout user |
| POST | `/api/auth/refresh-token` | Refresh access token |
| POST | `/api/auth/verify-email` | Verify email address |
| POST | `/api/auth/forgot-password` | Request password reset |
| POST | `/api/auth/reset-password` | Reset password |

### User Management

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/users/me` | Get current user | ✅ |
| PUT | `/api/users/me` | Update current user | ✅ |
| PUT | `/api/users/me/password` | Change password | ✅ |
| DELETE | `/api/users/me` | Delete account | ✅ |

### Admin Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/users` | Get all users | Admin |
| GET | `/api/users/:userId` | Get user by ID | Admin |
| PUT | `/api/users/:userId` | Update user | Admin |
| DELETE | `/api/users/:userId` | Delete user | Admin |
| GET | `/api/admin/statistics` | Get statistics | Admin |

##  Example Requests

### Register User

```bash
curl -X POST http://localhost:3001/api/auth/register \
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
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "SecurePass123!"
  }'
```

### Get Current User

```bash
curl -X GET http://localhost:3001/api/users/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Refresh Token

```bash
curl -X POST http://localhost:3001/api/auth/refresh-token \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "YOUR_REFRESH_TOKEN"
  }'
```

##  Database Schema

### Users Table

```sql
CREATE TABLE users (
  user_id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('student', 'lecturer', 'admin')),
  is_email_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

##  Environment Variables

```env
# Service Configuration
NODE_ENV=development
PORT=3001

# Database
DB_HOST=auth-db
DB_PORT=5432
DB_NAME=auth_db
DB_USER=postgres
DB_PASSWORD=postgres

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# RabbitMQ
RABBITMQ_URL=amqp://admin:admin@rabbitmq:5672

# JWT
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d
REFRESH_TOKEN_EXPIRES_IN=30d

# Service Auth
SERVICE_AUTH_TOKEN=shared-secret-token-between-services

# CORS
CORS_ORIGIN=*
```

## Event Publishing

The Auth Service publishes these events to RabbitMQ:

### user.created
```json
{
  "eventType": "user.created",
  "data": {
    "userId": "uuid",
    "email": "user@example.com",
    "role": "student",
    "firstName": "John",
    "lastName": "Doe"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### user.updated
```json
{
  "eventType": "user.updated",
  "data": {
    "userId": "uuid",
    "changes": {
      "firstName": "Jane"
    }
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### user.deleted
```json
{
  "eventType": "user.deleted",
  "data": {
    "userId": "uuid"
  },
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

## Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test
npm test auth.test.js
```

## 🐛 Troubleshooting

### Database Connection Issues

```bash
# Check if database is running
docker ps | grep auth-db

# Check database logs
docker logs auth-db

# Test connection
psql -h localhost -p 5431 -U postgres -d auth_db
```

### Redis Connection Issues

```bash
# Check Redis
docker exec -it redis redis-cli ping

# Monitor Redis
docker exec -it redis redis-cli monitor
```

### RabbitMQ Issues

```bash
# Check RabbitMQ
docker logs rabbitmq

# Access management UI
open http://localhost:15672
# Login: admin/admin
```

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│         Auth Service                │
├─────────────────────────────────────┤
│  Controllers (HTTP handlers)        │
│  ↓                                   │
│  Services (Business logic)          │
│  ↓                                   │
│  Models (Data layer)                │
│  ↓                                   │
│  PostgreSQL Database                │
└─────────────────────────────────────┘
         ↕                    ↕
    Redis Cache         RabbitMQ Events
```

## 📄 License

MIT

## 👥 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request
