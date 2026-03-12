# Authentication & Role-Based Access Control Implementation

## Overview

This document describes the authentication system with role-based access control for video calls.

## Roles

| Role | Description | Video Call Permissions |
|------|-------------|----------------------|
| `admin` | Full system access | Can start and join any video call |
| `professor` | Teaching role | Can start and join video calls |
| `aluno` | Student role | Can only join video calls that have been started by a professor/admin |

## Database Changes

### Migration File: `ConfidantPostgreSQL/docker/08-auth-and-roles.sql`

New columns added to `users` table:
- `password_hash VARCHAR(255)` - BCrypt hashed password
- `role VARCHAR(50) DEFAULT 'aluno'` - User role (admin, professor, aluno)
- `is_active BOOLEAN DEFAULT true` - Account status
- `last_login_at TIMESTAMP` - Last login timestamp

New tables created:
- `sessions` - User authentication sessions with tokens
- `video_rooms` - Video call rooms with host information
- `video_room_participants` - Participants in video rooms

## API Endpoints

### Authentication (`/api/auth`)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Register a new user (roles: professor, aluno) |
| POST | `/login` | Login and get session token |
| POST | `/logout` | Logout and revoke session |
| GET | `/me` | Get current user information |
| POST | `/change-password` | Change user password |
| POST | `/change-role/{userId}` | Change user role (admin only) |

### Video Rooms (`/api/videoroom`)

| Method | Endpoint | Description | Access |
|--------|----------|-------------|--------|
| POST | `/create` | Create new video room | Professor, Admin |
| POST | `/join` | Join existing video room | All authenticated users |
| POST | `/leave` | Leave video room | All authenticated users |
| POST | `/end` | End video room | Host, Admin |
| GET | `/active` | List active rooms | All authenticated users |
| GET | `/can-start` | Check if user can start calls | All authenticated users |

## Backend Files

### Entities (C#)

- `Data/Entities/UserEntity.cs` - Updated with auth fields
- `Data/Entities/SessionEntity.cs` - New: Session tokens
- `Data/Entities/VideoRoomEntity.cs` - New: Video rooms with participants

### Repositories (C#)

- `Data/Repositories/IUserRepository.cs` - Added auth methods
- `Data/Repositories/UserRepository.cs` - BCrypt password hashing
- `Data/Repositories/ISessionRepository.cs` - New: Session management
- `Data/Repositories/SessionRepository.cs` - New: Token-based sessions
- `Data/Repositories/IVideoRoomRepository.cs` - New: Video room CRUD
- `Data/Repositories/VideoRoomRepositoryAuth.cs` - New: Role-based access

### Controllers (C#)

- `Controllers/AuthController.cs` - New: Authentication endpoints
- `Controllers/VideoRoomController.cs` - New: Role-based video rooms

### DTOs (C#)

- `DTOs/AuthDTOs.cs` - Request/Response classes for auth

## Flutter App Files

### Services

- `lib/services/auth_service.dart` - New: Authentication service with token storage

### Pages

- `lib/pages/login_page.dart` - New: Login screen
- `lib/pages/register_page.dart` - New: Registration with role selection
- `lib/pages/home_page.dart` - Updated: Role-based UI, logout, user info

### Dependencies Added

```yaml
shared_preferences: ^2.3.5  # For storing auth token
```

## Usage Flow

### Registration
1. User fills registration form with username, password, display name, email
2. User selects role: "Student (Aluno)" or "Professor"
3. API creates user with BCrypt hashed password
4. Session token is returned and stored locally
5. User is redirected to home page

### Login
1. User enters username and password
2. API validates credentials with BCrypt
3. Session token is created (expires in 30 days)
4. Token is stored in SharedPreferences
5. User is redirected to home page

### Video Call Access
1. **Professors/Admins**: See "Start Video Call" button
2. **Students**: See "Join Video Call" button only
3. When student tries to join non-existent room: Error "Only professors can start video calls"
4. When professor starts a call: Room is created in database
5. Students can then join the active room

## Authentication Token

- Token is a GUID generated server-side
- Sent in `Authorization: Bearer <token>` header
- Stored in `SharedPreferences` on Flutter
- Valid for 30 days
- Can be revoked via logout

## Security Notes

- Passwords are hashed with BCrypt (cost factor 11)
- Admin role can only be assigned by existing admins
- Session tokens are unique and revocable
- All video room operations require authentication
- Role validation happens server-side

## Running the Migration

To apply the database changes:

```bash
# If using Docker Compose with the init scripts
docker-compose down
docker-compose up -d

# Or connect to PostgreSQL and run manually
psql -h localhost -U postgres -d confidant -f ConfidantPostgreSQL/docker/08-auth-and-roles.sql
```

## Building

### Backend
```bash
cd AgoraIntegrator/Src/Synget.AgoraIntegrator.API
dotnet build
dotnet run
```

### Flutter App
```bash
cd AgoraIntegrator/agora_test_app
flutter pub get
flutter run
```
