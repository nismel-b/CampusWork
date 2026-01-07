# Architecture - Academic Project Management Platform

## Overview
A comprehensive academic project management platform allowing students, lecturers, and administrators to collaborate, share, evaluate, and manage academic projects.

## User Roles
1. **Student**: Create/share projects, collaborate, like/comment, seek help
2. **Lecturer**: View/evaluate projects, comment, assign grades, manage course groups
3. **Admin**: Manage authentication, moderate content, validate registrations

## Core Features (MVP)
- Role-based authentication (Student/Lecturer/Admin)
- Project creation with file uploads (Student)
- Project listing with advanced filtering
- Like and comment system
- Project evaluation by lecturers
- Role-specific dashboards
- In-app notifications
- User registration approval by admin

## Data Models

### User (Base)
- id, firstName, lastName, email, password
- role (student/lecturer/admin)
- createdAt, updatedAt

### Student (extends User)
- matricule, birthday, level, semester, section, filiere, academicYear
- githubLink, linkedinLink, otherLinks[]

### Lecturer (extends User)
- uniteDenseignement, section
- evaluationGrid, validationRequirements, finalSubmissionRequirements

### Admin (extends User)
- Basic fields only

### Project
- id, projectName, courseName, description, architecturePatterns
- uml, prototypeLink, downloadLink, status (private/public)
- resources[], prerequisites[], powerpointLink, reportLink
- state (en_cours/termine/note), grade
- studentId, collaborators[]
- likes[], comments[]
- createdAt, updatedAt

### Comment
- id, projectId, userId, content, createdAt

### Like
- id, projectId, userId, createdAt

### Notification
- id, userId, title, message, type, isRead, createdAt

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── nav.dart                  # Go router navigation
├── theme.dart                # App theme
├── models/                   # Data models
│   ├── user.dart
│   ├── student.dart
│   ├── lecturer.dart
│   ├── admin.dart
│   ├── project.dart
│   ├── comment.dart
│   ├── like.dart
│   └── notification.dart
├── services/                 # Business logic
│   ├── auth_service.dart
│   ├── user_service.dart
│   ├── project_service.dart
│   ├── comment_service.dart
│   ├── like_service.dart
│   └── notification_service.dart
├── pages/                    # Main screens
│   ├── auth/
│   │   ├── login_page.dart
│   │   └── register_page.dart
│   ├── student/
│   │   ├── student_dashboard.dart
│   │   ├── create_project_page.dart
│   │   └── my_projects_page.dart
│   ├── lecturer/
│   │   ├── lecturer_dashboard.dart
│   │   └── evaluate_project_page.dart
│   ├── admin/
│   │   ├── admin_dashboard.dart
│   │   └── manage_users_page.dart
│   ├── shared/
│   │   ├── projects_list_page.dart
│   │   ├── project_details_page.dart
│   │   └── notifications_page.dart
└── components/               # Reusable widgets
    ├── project_card.dart
    ├── comment_item.dart
    ├── user_avatar.dart
    └── filter_bottom_sheet.dart
```

## Navigation Flow
- `/` → Login Page
- `/register` → Registration Page
- `/student-dashboard` → Student Dashboard
- `/lecturer-dashboard` → Lecturer Dashboard
- `/admin-dashboard` → Admin Dashboard
- `/projects` → Projects List (all roles)
- `/project/:id` → Project Details
- `/create-project` → Create Project (Student only)
- `/my-projects` → My Projects (Student only)
- `/notifications` → Notifications

## Data Storage
- **Default**: Local storage using shared_preferences
- All services implement CRUD operations with local persistence
- Sample data included for testing

## Design Approach
- **Style**: Sophisticated Monochrome (Professional Academic Platform)
- **Light Mode**: White backgrounds with blue-grey accents
- **Dark Mode**: Deep blue-charcoal with blue-grey elevations
- **Accent Color**: Deep blue (#2563EB) for academic professionalism
- **Layout**: Card-based design with generous whitespace
- **Icons**: Material Icons only
- **Typography**: Clear hierarchy with good contrast

## Key Features Implementation

### Authentication
- Email/password login
- Role-based registration (Student/Lecturer)
- Admin approval required for new accounts
- Session persistence with shared_preferences

### Project Management
- Students can create/edit projects
- File upload support (using file_picker)
- Public/Private visibility
- Collaboration support

### Social Features
- Like projects
- Comment on projects
- View project statistics

### Lecturer Features
- View all projects from courses
- Add comments and evaluations
- Assign grades
- Manage evaluation grids

### Admin Features
- Approve/reject user registrations
- Moderate content
- Manage user accounts

### Filtering & Search
- Filter by course, section, state, status
- Search by project name
- Sort by date, likes, grade

## Future Enhancements (Not in MVP)
- Posts and reactions
- Project history/changelog
- Real-time collaboration
- File preview without download
- Plagiarism detection
- Downloadable student portfolio
