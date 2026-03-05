# Synget.AgoraIntegrator

A .NET library providing abstraction for Agora RTC/RTM API integration, following the same architectural pattern as `Synget.ERPIntegrator`.

## Overview

`Synget.AgoraIntegrator` provides a clean, vendor-agnostic interface for integrating with Agora's video call, messaging, whiteboard, and screen sharing services. It abstracts away the complexity of token generation, session management, and API communication.

## Features

- **RTC Token Generation**: Generate tokens for video/audio calls
- **RTM Token Generation**: Generate tokens for real-time messaging
- **Session Management**: Track call sessions, participants, and duration
- **Whiteboard Support**: Integration with Netless whiteboard service (room creation, token generation)
- **Screen Share Support**: Token generation with special UID convention for screen sharing

## Installation

Add a reference to the project or NuGet package:

```bash
dotnet add package Synget.AgoraIntegrator
```

## Quick Start

### 1. Configuration

```csharp
using Synget.AgoraIntegrator;
using Synget.AgoraIntegrator.Models;

var config = new AgoraConfig
{
    Platform = AgoraPlatform.RTC,
    AppId = "your-agora-app-id",
    AppCertificate = "your-agora-app-certificate",
    TokenExpirationSeconds = 3600,
    
    // For Whiteboard functionality
    WhiteboardSdkToken = "your-netless-sdk-token",
    WhiteboardAppIdentifier = "your-netless-app-identifier",
    WhiteboardRegion = "us-sv"  // or "cn-hz", etc.
};
```

### 2. Initialize the Platform

```csharp
var platform = new AgoraPlatformManager();
bool success = platform.Initialize(config);

if (!success)
{
    Console.WriteLine("Initialization failed!");
    return;
}
```

### 3. Generate Tokens

```csharp
// RTC Token for video calls
var rtcToken = platform.Agora.RtcTokenGenerate("my-channel", uid: 0, AgoraRtcRole.Publisher);
Console.WriteLine($"RTC Token: {rtcToken?.Token}");

// RTM Token for messaging
var rtmToken = platform.Agora.RtmTokenGenerate("user-123");
Console.WriteLine($"RTM Token: {rtmToken?.Token}");
```

### 4. Manage Sessions

```csharp
// Create a session
var session = platform.Agora.SessionCreate("my-channel");

// User joins
platform.Agora.SessionUserJoin("my-channel", "user-123");
platform.Agora.SessionUserJoin("my-channel", "user-456");

// Get session info
var info = platform.Agora.SessionGet("my-channel");
Console.WriteLine($"Users in session: {info?.Users.Count}");

// User leaves
platform.Agora.SessionUserLeave("my-channel", "user-456");

// End session
platform.Agora.SessionEnd("my-channel");
```

### 5. Whiteboard Operations

```csharp
// Get whiteboard config for client-side setup
var whiteboardConfig = platform.Agora.WhiteboardGetConfig();
Console.WriteLine($"App Identifier: {whiteboardConfig?.AppIdentifier}");
Console.WriteLine($"Region: {whiteboardConfig?.Region}");

// Get or create a whiteboard room
var room = await platform.Agora.WhiteboardGetOrCreateRoomAsync("my-channel");
Console.WriteLine($"Room UUID: {room?.Uuid}");
Console.WriteLine($"Room Token: {room?.RoomToken}");
```

### 6. Screen Share Operations

```csharp
// Generate a screen share token
// Convention: screenShareUid = baseUid * 100 + 99
uint baseUid = 12345;
var screenShareToken = platform.Agora.ScreenShareTokenGenerate("my-channel", baseUid);
Console.WriteLine($"Screen Share Token: {screenShareToken?.Token}");

// Calculate screen share UID
uint screenShareUid = platform.Agora.ScreenShareUidCalculate(baseUid);
Console.WriteLine($"Screen Share UID: {screenShareUid}"); // 1234599

// Check if a UID is a screen share UID
bool isScreenShare = platform.Agora.ScreenShareUidCheck(1234599); // true
bool isNotScreenShare = platform.Agora.ScreenShareUidCheck(12345); // false
```

## Architecture

The library follows the same pattern as `Synget.ERPIntegrator`:

```
Synget.AgoraIntegrator/
├── Constants.cs           # Enums and constants
├── IAgora.cs              # Main interface
├── AgoraPlatformManager.cs # Platform manager (entry point)
├── AgoraRTC.cs            # Main implementation
├── Models/
│   ├── AgoraConfig.cs     # Configuration
│   ├── AgoraToken.cs      # Token model
│   ├── AgoraSession.cs    # Session model
│   ├── AgoraWhiteboard.cs # Whiteboard models
│   └── AgoraResponse.cs   # Response wrapper
├── Agora/
│   ├── AgoraClient.cs     # HTTP client
│   ├── AgoraClientConfig.cs # Internal config
│   ├── RtcEndpoints.cs    # RTC operations
│   ├── RtmEndpoints.cs    # RTM operations
│   ├── WhiteboardEndpoints.cs # Whiteboard operations
│   └── SessionEndpoints.cs # Session operations
└── Utilities/
    ├── AccessToken2.cs    # Token generation utility
    └── Extensions.cs      # Helper extensions
```

## Comparison with ERPIntegrator

| ERPIntegrator | AgoraIntegrator |
|---------------|-----------------|
| `IERP` | `IAgora` |
| `ERPPlatform` | `AgoraPlatformManager` |
| `ERPMoloni` | `AgoraRTC` |
| `ERPConfig` | `AgoraConfig` |
| `MoloniClient` | `AgoraClient` |

## Requirements

- .NET 8.0 or later
- Agora.io account with App ID and Certificate
- (Optional) Netless credentials for whiteboard features

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
