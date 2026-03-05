# Synget.ChatIntegrator

Real-time chat integration library using WebSockets/SignalR for Agora video call applications.

## Overview

This library provides a clean abstraction for real-time chat functionality, designed to work alongside Synget.AgoraIntegrator for video calls. It follows the same integrator pattern used throughout the Synget platform.

## Features

- **Chat Rooms**: Automatically created and managed alongside video call channels
- **Participants**: Track users in chat rooms with display names and connection states
- **Message History**: In-memory message storage with configurable retention
- **WebSocket Ready**: Designed to work with SignalR hubs for real-time messaging

## Usage

### Basic Setup

```csharp
using Synget.ChatIntegrator;

// Initialize the chat service
var chat = new ChatService();
chat.Initialize(new ChatConfig
{
    MaxMessagesPerRoom = 1000,
    MessageRetentionHours = 24
});

// Create or get a room
var room = chat.RoomGetOrCreate("my-channel");

// Add a participant
chat.ParticipantJoin("my-channel", "user-123", "John Doe", connectionId);

// Store a message
chat.MessageStore("my-channel", new ChatMessage
{
    SenderId = "user-123",
    SenderName = "John Doe",
    Content = "Hello everyone!",
    Type = ChatMessageType.Text
});

// Get message history
var messages = chat.MessageGetHistory("my-channel", limit: 50);
```

### Integration with API

Register as a singleton in your ASP.NET Core application:

```csharp
// Program.cs
builder.Services.AddSingleton<IChat>(sp =>
{
    var chat = new ChatService();
    chat.Initialize(new ChatConfig
    {
        MaxMessagesPerRoom = 1000
    });
    return chat;
});

// Add SignalR
builder.Services.AddSignalR();

// Map the chat hub
app.MapHub<ChatHub>("/chathub");
```

## Models

### ChatRoom
- `RoomId` - Unique identifier
- `ChannelName` - Associated video call channel
- `Participants` - List of current participants
- `Messages` - Message history
- `IsActive` - Whether the room is active

### ChatParticipant
- `UserId` - Unique user identifier
- `DisplayName` - User's display name
- `ConnectionId` - SignalR connection ID
- `IsConnected` - Connection status

### ChatMessage
- `MessageId` - Unique message identifier
- `SenderId` - Sender's user ID
- `SenderName` - Sender's display name
- `Content` - Message content
- `Timestamp` - When the message was sent
- `Type` - Text, System, Attachment, or Reaction

## License

Proprietary - Synget
