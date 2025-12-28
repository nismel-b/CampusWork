# Student Service

Student profile management microservice for CampusWork.

##  Features

- **Profile Management**
  - Create, read, update, delete student profiles
  - Profile completeness tracking
  - Profile visibility controls (public/institution/private)

- **Academic Information**
  - Matriculation number
  - Program/major
  - Graduation year
  - GPA tracking
  - Enrollment status

- **Skills & Interests**
  - Add/remove skills
  - Track interests
  - Portfolio management

- **Professional Links**
  - LinkedIn profile
  - GitHub profile
  - Personal website/portfolio

- **Event-Driven Architecture**
  - Automatically creates profile when user registers with 'student' role
  - Listens to user.created, user.updated, user.deleted events
  - Updates cache on user changes

- **Performance**
  - Redis caching (1 hour TTL)
  - Efficient database queries
  - Profile search with pagination

##  Prerequisites

- Node.js 18+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+
- RabbitMQ 3+
- Running Auth Service

##  Installation

### Using Docker Compose (Recommended)

```bash
cd services/student-service
docker-compose up -d
```

### Local Development

```bash
# Install dependencies
npm install

# Copy environment file
cp .env.example .env

# Edit configuration
nano .env

# Start dependencies
docker-compose up -d student-db redis rabbitmq

# Start service
npm run dev
```

## 🌐 API Endpoints

### Health Checks

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| GET | `/ready` | Readiness check |
| GET | `/live` | Liveness check |

### Profile Management

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/students/profile` | Create profile | ✅ Student |
| GET | `/api/students/profile/me` | Get own profile | ✅ Student |
| GET | `/api/students/profile/me/full` | Get full profile with user info | ✅ Student |
| PUT | `/api/students/profile/me` | Update own profile | ✅ Student |
| GET | `/api/students/profile/:userId` | Get student profile | Public |
| GET | `/api/students/profile/:userId/full` | Get full profile | Public |

### Skills Management

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/students/profile/me/skills` | Add skill | ✅ Student |
| DELETE | `/api/students/profile/me/skills/:skill` | Remove skill | ✅ Student |

### Search

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/students/search` | Search students | Public |

### Admin Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| GET | `/api/students/profile/matriculation/:number` | Get by matric number | Admin |
| PUT | `/api/students/profile/:userId` | Update any profile | Admin |
| DELETE | `/api/students/profile/:userId` | Delete profile | Admin |
| GET | `/api/students/statistics` | Get statistics | Admin |

##  Example Requests

### Create Profile

```bash
curl -X POST http://localhost:3002/api/students/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "matriculationNumber": "CS2024001",
    "program": "Computer Science",
    "graduationYear": 2025,
    "gpa": 3.8,
    "bio": "Passionate about AI and machine learning",
    "skills": ["JavaScript", "Python", "React", "Node.js"],
    "interests": ["Artificial Intelligence", "Web Development"],
    "linkedinUrl": "https://linkedin.com/in/johndoe",
    "githubUrl": "https://github.com/johndoe",
    "portfolioUrl": "https://johndoe.dev"
  }'
```

### Get Own Profile

```bash
curl -X GET http://localhost:3002/api/students/profile/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Update Profile

```bash
curl -X PUT http://localhost:3002/api/students/profile/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "bio": "Updated bio",
    "gpa": 3.9,
    "skills": ["JavaScript", "Python", "React", "Node.js", "Docker"]
  }'
```

### Add Skill

```bash
curl -X POST http://localhost:3002/api/students/profile/me/skills \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "skill": "TypeScript"
  }'
```

### Search Students

```bash
curl -X GET "http://localhost:3002/api/students/search?program=Computer%20Science&graduationYear=2025&page=1&limit=20"
```

### Get Full Profile (with User Info)

```bash
curl -X GET http://localhost:3002/api/students/profile/me/full \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

##  Database Schema

### student_profiles Table

```sql
CREATE TABLE student_profiles (
  profile_id SERIAL PRIMARY KEY,
  user_id UUID UNIQUE NOT NULL,
  matriculation_number VARCHAR(50) UNIQUE,
  program VARCHAR(200),
  graduation_year INTEGER,
  gpa DECIMAL(3,2),
  bio TEXT,
  skills JSONB DEFAULT '[]',
  interests JSONB DEFAULT '[]',
  linkedin_url VARCHAR(500),
  github_url VARCHAR(500),
  portfolio_url VARCHAR(500),
  profile_completeness INTEGER DEFAULT 0,
  profile_visibility VARCHAR(20) DEFAULT 'public',
  enrollment_status VARCHAR(20) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  
  CHECK (gpa >= 0 AND gpa <= 4.0),
  CHECK (profile_completeness >= 0 AND profile_completeness <= 100),
  CHECK (profile_visibility IN ('public', 'institution', 'private')),
  CHECK (enrollment_status IN ('active', 'on_leave', 'graduated', 'withdrawn'))
);

CREATE INDEX idx_student_user_id ON student_profiles(user_id);
CREATE INDEX idx_student_program ON student_profiles(program);
CREATE INDEX idx_student_graduation_year ON student_profiles(graduation_year);
CREATE INDEX idx_student_enrollment ON student_profiles(enrollment_status);
```

##  Environment Variables

```env
# Service Configuration
NODE_ENV=development
PORT=3002
SERVICE_NAME=student-service

# Database
DB_HOST=student-db
DB_PORT=5432
DB_NAME=student_db
DB_USER=postgres
DB_PASSWORD=postgres

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# RabbitMQ
RABBITMQ_URL=amqp://admin:admin@rabbitmq:5672

# Auth Service
AUTH_SERVICE_URL=http://auth-service:3001
JWT_SECRET=your-super-secret-jwt-key
SERVICE_AUTH_TOKEN=shared-secret-token

# CORS
CORS_ORIGIN=*

# Logging
LOG_LEVEL=info
```

##  Event Handling

### Events Consumed

#### user.created
```json
{
  "eventType": "user.created",
  "data": {
    "userId": "uuid",
    "email": "student@example.com",
    "role": "student"
  }
}
```
**Action**: Automatically creates student profile with default values

#### user.deleted
```json
{
  "eventType": "user.deleted",
  "data": {
    "userId": "uuid"
  }
}
```
**Action**: Deletes student profile

#### user.updated
```json
{
  "eventType": "user.updated",
  "data": {
    "userId": "uuid",
    "changes": {...}
  }
}
```
**Action**: Invalidates cache for updated user

## 🧪 Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run in watch mode
npm run test:watch
```

### Test Structure

```javascript
describe('Student Profile', () => {
  test('should create profile', async () => {
    const profile = await studentService.createProfile(userId, data);
    expect(profile).toBeDefined();
  });
});


##  Architecture


┌─────────────────────────────────────┐
│       Student Service               │
├─────────────────────────────────────┤
│  Routes                             │
│    ↓                                │
│  Controllers                        │
│    ↓                                │
│  Services (Business Logic)          │
│    ↓                                │
│  Models (Sequelize ORM)             │
│    ↓                                │
│  PostgreSQL Database                │
└─────────────────────────────────────┘
         ↕              ↕
    Redis Cache    RabbitMQ Events


##  Troubleshooting

### Database Connection Issues

```bash
# Check database
docker ps | grep student-db

# View logs
docker logs student-db

# Connect manually
psql -h localhost -p 5432 -U postgres -d student_db
```

### Cache Issues

```bash
# Check Redis
docker exec -it redis redis-cli ping

# Clear cache
docker exec -it redis redis-cli FLUSHDB
```

### Event Consumer Issues

```bash
# Check RabbitMQ
docker logs rabbitmq

# Access management UI
open http://localhost:15672
```

## 📄 License

MIT

## 👥 Contributing

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for contribution guidelines.
