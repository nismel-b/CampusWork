# Admin Service

Admin management and monitoring service for CampusWork.

## Features

 **User Management**
- Create, read, update, delete users
- Suspend/activate user accounts
- Change user roles
- Reset user passwords
- Bulk operations on multiple users

 **Admin Logging & Audit**
- Track all admin actions
- Searchable audit logs
- Admin activity statistics
- Target user history

 **Platform Analytics**
- Platform overview dashboard
- User growth statistics
- Activity metrics
- Top users tracking
- Data export functionality

 **System Configuration**
- Dynamic system settings
- Configuration categories
- Public/private configs
- Editable/locked configs

## Prerequisites

- Node.js 18+
- Docker & Docker Compose
- PostgreSQL 15+
- Access to other microservices (Auth, Student, Lecturer)

## Installation

### Using Docker Compose (Recommended)

```bash
# From project root
docker-compose up -d admin-service
```

### Local Development

```bash
# Navigate to service directory
cd services/admin-service

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

**Important**: The Admin Service requires URLs for other microservices:
- `AUTH_SERVICE_URL` - Auth Service URL
- `STUDENT_SERVICE_URL` - Student Service URL
- `LECTURER_SERVICE_URL` - Lecturer Service URL

## API Endpoints

### Health Checks

- `GET /health` - Health check
- `GET /ready` - Readiness check
- `GET /live` - Liveness check

### Admin Logs

All require **Admin authentication**.

- `GET /api/admin/logs` - Get all admin logs
- `GET /api/admin/logs/admin/:adminUserId` - Get logs by admin user
- `GET /api/admin/logs/user/:userId` - Get logs for target user
- `GET /api/admin/logs/statistics` - Get admin action statistics

### User Management

- `GET /api/admin/users` - Get all users (with filters & pagination)
- `GET /api/admin/users/:userId` - Get user by ID
- `POST /api/admin/users` - Create new user
- `PUT /api/admin/users/:userId` - Update user
- `DELETE /api/admin/users/:userId` - Delete user
- `POST /api/admin/users/:userId/suspend` - Suspend user
- `POST /api/admin/users/:userId/activate` - Activate user
- `PATCH /api/admin/users/:userId/role` - Change user role
- `POST /api/admin/users/:userId/reset-password` - Reset password
- `POST /api/admin/users/bulk` - Bulk operations

### Analytics

- `GET /api/admin/analytics/overview` - Platform overview
- `GET /api/admin/analytics/growth` - User growth statistics
- `GET /api/admin/analytics/activity` - Activity statistics
- `GET /api/admin/analytics/top-users` - Top users
- `POST /api/admin/analytics/export` - Export data

### System Configuration

- `GET /api/admin/config` - Get all configs
- `GET /api/admin/config/public` - Get public configs
- `GET /api/admin/config/:key` - Get config by key
- `POST /api/admin/config` - Create/update config
- `PUT /api/admin/config/:key` - Update config
- `DELETE /api/admin/config/:key` - Delete config

## Testing API with cURL

### Get All Users

```bash
curl -X GET "http://localhost:3004/api/admin/users?page=1&limit=20" \
  -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN"
```

### Create User

```bash
curl -X POST http://localhost:3004/api/admin/users \
  -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "SecurePass123!",
    "firstName": "John",
    "lastName": "Doe",
    "role": "student"
  }'
```

### Suspend User

```bash
curl -X POST http://localhost:3004/api/admin/users/USER_ID/suspend \
  -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Violation of terms of service"
  }'
```

### Change User Role

```bash
curl -X PATCH http://localhost:3004/api/admin/users/USER_ID/role \
  -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "role": "lecturer"
  }'
```

### Get Platform Overview

```bash
curl -X GET http://localhost:3004/api/admin/analytics/overview \
  -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN"
```

### Set System Config

```bash
curl -X POST http://localhost:3004/api/admin/config \
  -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "max_project_size",
    "value": 52428800,
    "description": "Maximum project file size in bytes (50MB)",
    "category": "storage",
    "isPublic": false,
    "isEditable": true
  }'
```

### Bulk Suspend Users

```bash
curl -X POST http://localhost:3004/api/admin/users/bulk \
  -H "Authorization: Bearer YOUR_ADMIN_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "operation": "suspend",
    "userIds": ["user-id-1", "user-id-2", "user-id-3"],
    "data": {
      "reason": "Bulk suspension for policy violations"
    }
  }'
```

## Architecture

```
┌─────────────────────────────────────────────┐
│            Admin Service                    │
├─────────────────────────────────────────────┤
│  Controllers (HTTP handlers)                │
│  ↓                                           │
│  Services (Business logic)                  │
│  ↓                                           │
│  Models (AdminLog, SystemConfig)            │
│  ↓                                           │
│  PostgreSQL Database                        │
└─────────────────────────────────────────────┘
         ↕              ↕              ↕
   Auth Service   Student Service  Lecturer Service
   (HTTP calls)   (HTTP calls)     (HTTP calls)
```

## Database Schema

### `admin_logs` table

| Column | Type | Description |
|--------|------|-------------|
| log_id | INTEGER | Primary key |
| admin_user_id | UUID | Admin who performed action |
| action_type | ENUM | Type of action |
| target_user_id | UUID | User affected (if applicable) |
| description | TEXT | Action description |
| metadata | JSONB | Additional data |
| ip_address | VARCHAR(45) | Admin's IP address |
| user_agent | VARCHAR(500) | Admin's user agent |
| status | ENUM | success/failed |
| error_message | TEXT | Error if failed |
| created_at | TIMESTAMP | Timestamp |

### `system_configs` table

| Column | Type | Description |
|--------|------|-------------|
| config_id | INTEGER | Primary key |
| key | VARCHAR(100) | Unique config key |
| value | JSONB | Config value |
| description | TEXT | What this config does |
| category | ENUM | Config category |
| is_public | BOOLEAN | Readable by non-admins |
| is_editable | BOOLEAN | Can be edited via UI |
| last_modified_by | UUID | Admin who last modified |
| created_at | TIMESTAMP | Creation timestamp |
| updated_at | TIMESTAMP | Update timestamp |

## Action Types

Admin actions are logged with these types:

- `user_created` - New user created
- `user_updated` - User information updated
- `user_deleted` - User deleted
- `user_suspended` - User account suspended
- `user_activated` - User account activated
- `role_changed` - User role changed
- `password_reset` - Password reset
- `profile_updated` - Profile updated
- `profile_deleted` - Profile deleted
- `system_config_updated` - System config changed
- `bulk_operation` - Bulk operation performed
- `export_data` - Data exported
- `import_data` - Data imported

## Default System Configurations

The service initializes with these default configs:

- **site_name**: Platform name (public)
- **site_description**: Platform description (public)
- **max_upload_size**: Max file upload size (10MB)
- **allowed_file_types**: Allowed file extensions
- **enable_registration**: Allow new registrations
- **require_email_verification**: Email verification required
- **session_timeout**: Session timeout (1 hour)
- **enable_notifications**: Enable notifications

## Security Features

 All endpoints require admin authentication
 All admin actions are logged for audit
 IP address and user agent tracking
 Service-to-service authentication
 Role-based access control
 Graceful error handling

## Troubleshooting

### Database Connection Issues

```bash
# Check if database is running
docker ps | grep admin-db

# Check database logs
docker logs admin-db

# Test connection manually
psql -h localhost -p 5435 -U postgres -d admin_db
```

### Service Communication Issues

```bash
# Check if other services are running
docker ps | grep -E "auth-service|student-service|lecturer-service"

# Test service connectivity
curl http://localhost:3001/health  # Auth Service
curl http://localhost:3002/health  # Student Service
curl http://localhost:3003/health  # Lecturer Service
```

### View Admin Logs

```bash
# View service logs
docker logs admin-service

# Follow logs
docker logs -f admin-service
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT
