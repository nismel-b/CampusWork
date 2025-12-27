# Lecturer Service

Lecturer profile management microservice for CampusWork.

## Features

 Lecturer profile CRUD operations  
 Academic rank and qualifications management  
 Research interests and publications tracking  
 Office hours and contact information  
 Accepting students status  
 Profile privacy controls  
 Event-driven profile creation (listens to Auth Service events)  
 Caching with Redis  
 Service-to-service communication  

## Prerequisites

- Node.js 18+
- Docker & Docker Compose
- PostgreSQL 15+
- Redis 7+
- RabbitMQ 3+

## Installation

### Using Docker Compose (Recommended)

```bash
# From project root
docker-compose up -d lecturer-service
```

### Local Development

```bash
# Navigate to service directory
cd services/lecturer-service

# Install dependencies
npm install

# Copy environment variables
cp .env.example .env

# Edit .env with your configuration
nano .env

# Start service
npm run dev
```

## Environment Variables

See `.env.example` for all available configuration options.

## API Endpoints

### Public Endpoints

- `GET /health` - Health check
- `GET /ready` - Readiness check
- `GET /api/lecturers/search` - Search lecturers
- `GET /api/lecturers/profile/:userId` - Get lecturer profile
- `GET /api/lecturers/profile/:userId/full` - Get full profile with user info

### Protected Endpoints (Require Authentication)

#### Profile Management

- `POST /api/lecturers/profile` - Create profile
- `GET /api/lecturers/profile/me` - Get own profile
- `GET /api/lecturers/profile/me/full` - Get full own profile
- `PUT /api/lecturers/profile/me` - Update own profile

#### Research Interests

- `POST /api/lecturers/profile/me/research-interests` - Add research interest
- `DELETE /api/lecturers/profile/me/research-interests/:interest` - Remove research interest

#### Publications

- `POST /api/lecturers/profile/me/publications` - Add publication

#### Accepting Students

- `PATCH /api/lecturers/profile/me/accepting-students` - Update accepting students status

### Admin Endpoints

- `PUT /api/lecturers/profile/:userId` - Update any profile
- `DELETE /api/lecturers/profile/:userId` - Delete profile
- `GET /api/lecturers/statistics` - Get statistics

## Testing

```bash
# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test file
npm test lecturer.test.js
```

## Testing API with cURL

### Create Profile

```bash
curl -X POST http://localhost:3003/api/lecturers/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Dr.",
    "department": "Computer Science",
    "specialization": "Artificial Intelligence",
    "academicRank": "senior_lecturer",
    "teachingExperience": 10,
    "qualifications": [
      {
        "degree": "PhD",
        "field": "Computer Science",
        "year": 2015,
        "institution": "MIT"
      }
    ],
    "researchInterests": ["Machine Learning", "NLP"],
    "bio": "Passionate about AI research and education",
    "acceptingStudents": true
  }'
```

### Get Own Profile

```bash
curl -X GET http://localhost:3003/api/lecturers/profile/me \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Search Lecturers

```bash
curl -X GET "http://localhost:3003/api/lecturers/search?department=Computer%20Science&acceptingStudents=true&page=1&limit=20"
```

### Add Research Interest

```bash
curl -X POST http://localhost:3003/api/lecturers/profile/me/research-interests \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "interest": "Deep Learning"
  }'
```

### Add Publication

```bash
curl -X POST http://localhost:3003/api/lecturers/profile/me/publications \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Deep Learning for Natural Language Processing",
    "authors": ["Smith, J.", "Doe, J."],
    "journal": "IEEE Transactions on AI",
    "year": 2023,
    "doi": "10.1109/example"
  }'
```

### Update Accepting Students Status

```bash
curl -X PATCH http://localhost:3003/api/lecturers/profile/me/accepting-students \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "accepting": false
  }'
```

## Event Handlers

The Lecturer Service listens to these events from RabbitMQ:

- `user.created` : Automatically creates lecturer profile for users with role 'lecturer'
- `user.deleted` : Deletes lecturer profile
- `user.updated` : Invalidates cache

## Architecture

```
┌─────────────────────────────────────┐
│         Lecturer Service            │
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

## Database Schema

### `lecturer_profiles` table

| Column | Type | Description |
|--------|------|-------------|
| profile_id | INTEGER | Primary key |
| user_id | UUID | References user from Auth Service |
| title | VARCHAR(20) | Academic title (Dr., Prof., etc.) |
| department | VARCHAR(200) | Department |
| specialization | VARCHAR(200) | Specialization |
| academic_rank | ENUM | Academic rank |
| qualifications | JSONB | Array of degree objects |
| teaching_experience | INTEGER | Years of experience |
| research_interests | JSONB | Array of research interests |
| publications | JSONB | Array of publications |
| research_projects | JSONB | Array of research projects |
| courses_taught | JSONB | Array of courses |
| office_location | VARCHAR(200) | Office location |
| office_hours | JSONB | Office hours schedule |
| phone_number | VARCHAR(20) | Phone number |
| contact_email | VARCHAR(255) | Contact email |
| bio | TEXT | Biography |
| research_statement | TEXT | Research statement |
| linkedin_url | VARCHAR(500) | LinkedIn profile |
| google_scholar_url | VARCHAR(500) | Google Scholar |
| researchgate_url | VARCHAR(500) | ResearchGate |
| orcid_url | VARCHAR(500) | ORCID |
| personal_website | VARCHAR(500) | Personal website |
| accepting_students | BOOLEAN | Accepting new students |
| employment_status | ENUM | Employment status |
| profile_completeness | INTEGER | Completion percentage |
| profile_visibility | ENUM | public/institution/private |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Update timestamp |

## Troubleshooting

### Database Connection Issues

```bash
# Check if database is running
docker ps | grep lecturer-db

# Check database logs
docker logs lecturer-db

# Test connection manually
psql -h localhost -p 5434 -U postgres -d lecturer_db
```

### RabbitMQ Issues

```bash
# Check RabbitMQ
docker logs rabbitmq

# Access RabbitMQ management UI
open http://localhost:15672
# Default credentials: admin/admin
```

### Redis Issues

```bash
# Check Redis
docker exec -it redis redis-cli ping

# Monitor Redis commands
docker exec -it redis redis-cli monitor
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT
