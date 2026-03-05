# Synget.AgoraIntegrator.API

ASP.NET Core Web API for Agora RTC/RTM integration. This API serves as a backend for Flutter and other client applications to manage video calls and sessions.

## Features

- **Token Generation**: Generate RTC and RTM tokens for Agora SDK
- **Session Management**: Create, join, leave, and manage video call sessions
- **CORS Enabled**: Ready for cross-origin requests from web and mobile apps

## Endpoints

### Token Endpoints

#### POST /api/token/rtc
Generate an RTC token for video/audio calls.

**Request:**
```json
{
  "channelName": "my-channel",
  "uid": "12345"
}
```

**Response:**
```json
{
  "token": "006xxxxx...",
  "channelName": "my-channel",
  "uid": "12345",
  "tokenType": "RTC"
}
```

#### POST /api/token/rtm
Generate an RTM token for real-time messaging.

**Request:**
```json
{
  "userId": "user123"
}
```

**Response:**
```json
{
  "token": "006xxxxx...",
  "uid": "user123",
  "tokenType": "RTM"
}
```

### Session Endpoints

#### POST /api/session/create
Create a new session (channel).

**Request:**
```json
{
  "channelName": "my-channel",
  "hostUserId": "host123"
}
```

**Response:**
```json
{
  "channelName": "my-channel",
  "hostUserId": "host123",
  "token": "006xxxxx...",
  "createdAt": "2024-01-15T10:30:00Z",
  "users": ["host123"]
}
```

#### POST /api/session/join
Join an existing session.

**Request:**
```json
{
  "channelName": "my-channel",
  "userId": "user456"
}
```

#### POST /api/session/leave
Leave a session.

**Request:**
```json
{
  "channelName": "my-channel",
  "userId": "user456"
}
```

#### GET /api/session/{channelName}
Get session information.

#### GET /api/session
Get all active sessions.

#### DELETE /api/session/{channelName}
End a session.

## Configuration

Update `appsettings.json` or `appsettings.Development.json` with your Agora credentials:

```json
{
  "Agora": {
    "AppId": "YOUR_AGORA_APP_ID",
    "AppCertificate": "YOUR_AGORA_APP_CERTIFICATE",
    "TokenExpirationSeconds": 3600
  }
}
```

## Running the API

```bash
cd Synget.AgoraIntegrator.API
dotnet run
```

The API will start at `http://localhost:5050` by default.

## Swagger UI

When running in development mode, access Swagger UI at:
`http://localhost:5050/swagger`

## Flutter Integration

Update your Flutter app's `.env` file:

```env
API_BASE_URL=http://localhost:5050
```

Then use the `AgoraIntegratorService` from `lib/services/api/agora_integrator_service.dart` to communicate with the API.

## Architecture

```
Synget.AgoraIntegrator.API
├── Controllers/
│   ├── TokenController.cs      # Token generation endpoints
│   └── SessionController.cs    # Session management endpoints
├── DTOs/
│   └── DTOs.cs                 # Request/Response models
├── Program.cs                  # Application entry point
└── appsettings.json           # Configuration
```

## Dependencies

- Synget.AgoraIntegrator (Core library)
- ASP.NET Core 8.0
