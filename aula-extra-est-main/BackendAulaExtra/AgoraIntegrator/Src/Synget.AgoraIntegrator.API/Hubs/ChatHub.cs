using Microsoft.AspNetCore.SignalR;
using Synget.ChatIntegrator;
using Synget.AgoraIntegrator.API.Data;
using Synget.AgoraIntegrator.API.Data.Entities;
using Synget.AgoraIntegrator.API.Data.Repositories;
using Microsoft.EntityFrameworkCore;

namespace Synget.AgoraIntegrator.API.Hubs
{
    /// <summary>
    /// SignalR Hub for real-time chat functionality.
    /// Acts as a thin transport layer - all business logic is in IChat (ChatService).
    /// Messages are also persisted to PostgreSQL for history.
    /// </summary>
    public class ChatHub : Hub
    {
        private readonly IChat _chat;
        private readonly ILogger<ChatHub> _logger;
        private readonly IServiceScopeFactory _scopeFactory;

        public ChatHub(IChat chat, ILogger<ChatHub> logger, IServiceScopeFactory scopeFactory)
        {
            _chat = chat;
            _logger = logger;
            _scopeFactory = scopeFactory;
        }

        /// <summary>
        /// Called when a client connects to the hub.
        /// </summary>
        public override async Task OnConnectedAsync()
        {
            _logger.LogInformation("Client connected: {ConnectionId}", Context.ConnectionId);
            await base.OnConnectedAsync();
        }

        /// <summary>
        /// Called when a client disconnects from the hub.
        /// </summary>
        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            var participant = _chat.ParticipantGetByConnection(Context.ConnectionId);
            if (participant != null)
            {
                _logger.LogInformation("User {UserId} disconnected from {Channel}", 
                    participant.UserId, participant.ChannelName);

                var result = _chat.ProcessLeaveRoom(participant.ChannelName, Context.ConnectionId);
                if (result.Success && result.UserEvent != null)
                {
                    await Clients.Group(participant.ChannelName).SendAsync("UserLeft", result.UserEvent);
                }
            }

            await base.OnDisconnectedAsync(exception);
        }

        /// <summary>
        /// Join a chat room for a specific channel.
        /// </summary>
        public async Task JoinRoom(string channelName, string userId, string displayName)
        {
            _logger.LogInformation("User {UserId} ({DisplayName}) joining room {Channel}", 
                userId, displayName, channelName);

            // Add to SignalR group
            await Groups.AddToGroupAsync(Context.ConnectionId, channelName);

            // Ensure user exists in DB
            using var scope = _scopeFactory.CreateScope();
            var userRepo = scope.ServiceProvider.GetRequiredService<IUserRepository>();
            var messageRepo = scope.ServiceProvider.GetRequiredService<IMessageRepository>();

            var dbUser = await userRepo.GetOrCreateAsync(userId, displayName);

            // Process join in the integrator (in-memory)
            var result = _chat.ProcessJoinRoom(channelName, userId, displayName, Context.ConnectionId);

            if (!result.Success)
            {
                await Clients.Caller.SendAsync("Error", result.Error);
                return;
            }

            // Only load message history for persistent rooms (DM or group chats)
            // Video call channels should NOT load history from previous calls
            var historyMessages = new List<object>();
            bool isPersistentRoom = channelName.StartsWith("dm_") || channelName.StartsWith("group_");
            
            if (isPersistentRoom)
            {
                var dbMessages = await messageRepo.GetByRoomAsync(channelName, 50);
                historyMessages = dbMessages.Select(m => new
                {
                    messageId = m.Id.ToString(),
                    senderId = m.SenderUser?.Username ?? m.SenderId ?? "",
                    senderName = m.SenderUser?.DisplayName ?? m.SenderUser?.Username ?? "Unknown",
                    content = m.Content,
                    timestamp = m.CreatedAt.ToString("o"),
                    type = m.Metadata?.Contains("\"type\":\"file\"") == true ? "file" : "text",
                    metadata = m.Metadata,
                    attachment = m.Metadata?.Contains("\"type\":\"file\"") == true 
                        ? System.Text.Json.JsonSerializer.Deserialize<object>(m.Metadata) 
                        : null
                }).ToList<object>();
            }
            else
            {
                _logger.LogInformation("Video call channel {Channel} - not loading message history", channelName);
            }

            // Send history and participants to the joining user
            await Clients.Caller.SendAsync("RoomJoined", new
            {
                channelName = result.ChannelName,
                messages = historyMessages,
                participants = result.Participants,
                dbUserId = dbUser.Id,
                isPersistentRoom = isPersistentRoom
            });

            // Notify others that user joined
            if (result.UserEvent != null)
            {
                await Clients.OthersInGroup(channelName).SendAsync("UserJoined", result.UserEvent);
            }
        }

        /// <summary>
        /// Leave a chat room.
        /// </summary>
        public async Task LeaveRoom(string channelName)
        {
            var result = _chat.ProcessLeaveRoom(channelName, Context.ConnectionId);

            if (result.Success)
            {
                _logger.LogInformation("User left room {Channel}", channelName);

                if (result.UserEvent != null)
                {
                    await Clients.OthersInGroup(channelName).SendAsync("UserLeft", result.UserEvent);
                }
            }

            await Groups.RemoveFromGroupAsync(Context.ConnectionId, channelName);
        }

        /// <summary>
        /// Send a message to the chat room.
        /// </summary>
        public async Task SendMessage(string channelName, string content)
        {
            _logger.LogInformation("SendMessage called: Channel={Channel}, Content={Content}, ConnectionId={ConnectionId}", 
                channelName, content, Context.ConnectionId);

            var result = _chat.ProcessSendMessage(channelName, content, Context.ConnectionId);

            if (!result.Success)
            {
                _logger.LogWarning("SendMessage failed: {Error}", result.Error);
                await Clients.Caller.SendAsync("Error", result.Error);
                return;
            }

            _logger.LogInformation("Message processed successfully, broadcasting to group {Channel}", channelName);

            // Only persist messages to database for persistent rooms (DM or group chats)
            // Video call chat messages are ephemeral and should not be stored
            bool isPersistentRoom = channelName.StartsWith("dm_") || channelName.StartsWith("group_");
            
            if (isPersistentRoom)
            {
                try
                {
                    using var scope = _scopeFactory.CreateScope();
                    var userRepo = scope.ServiceProvider.GetRequiredService<IUserRepository>();
                    var messageRepo = scope.ServiceProvider.GetRequiredService<IMessageRepository>();

                    // Get sender user from DB
                    var participant = _chat.ParticipantGetByConnection(Context.ConnectionId);
                    long? senderUserId = null;
                    if (participant != null)
                    {
                        var dbUser = await userRepo.GetByUsernameAsync(participant.UserId);
                        senderUserId = dbUser?.Id;
                    }

                    var messageEntity = new MessageEntity
                    {
                        RoomId = channelName,
                        SenderId = participant?.UserId,
                        SenderUserId = senderUserId,
                        Content = content,
                        CreatedAt = DateTime.UtcNow
                    };

                    await messageRepo.CreateAsync(messageEntity);
                    _logger.LogDebug("Message persisted to DB with ID {MessageId}", messageEntity.Id);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to persist message to database");
                    // Continue - message was still broadcast in real-time
                }
            }
            else
            {
                _logger.LogDebug("Video call channel {Channel} - message not persisted to DB", channelName);
            }

            // Broadcast to all in room (including sender for confirmation)
            _logger.LogInformation("Broadcasting MessageReceived to group {Channel}", channelName);
            await Clients.Group(channelName).SendAsync("MessageReceived", result.Message);

            // For DM rooms, also notify each participant via their user notification group
            // This ensures they receive the message even if not currently in the room
            if (channelName.StartsWith("dm_"))
            {
                // Parse member IDs from the channel name (format: dm_user1_user2)
                var parts = channelName.Split('_');
                if (parts.Length >= 3)
                {
                    var sender = _chat.ParticipantGetByConnection(Context.ConnectionId);
                    var memberIds = new[] { parts[1], parts[2] };
                    
                    _logger.LogInformation("DM room detected, sending DirectMessageReceived to users: {Members}", 
                        string.Join(", ", memberIds));
                    
                    foreach (var memberId in memberIds)
                    {
                        // Don't send notification to sender (they already got it from the room group)
                        if (sender != null && memberId == sender.UserId) continue;
                        
                        // Send to user's notification group
                        _logger.LogInformation("Sending DirectMessageReceived to user_{MemberId}", memberId);
                        await Clients.Group($"user_{memberId}").SendAsync("DirectMessageReceived", new
                        {
                            channelName = channelName,
                            message = result.Message
                        });
                    }
                }
            }
        }

        /// <summary>
        /// Get the list of participants in a room.
        /// </summary>
        public async Task GetParticipants(string channelName)
        {
            var result = _chat.GetParticipantsForHub(channelName);
            await Clients.Caller.SendAsync("Participants", result);
        }

        /// <summary>
        /// Get message history for a room from database.
        /// </summary>
        public async Task GetHistory(string channelName, int limit = 50, string? beforeTimestamp = null)
        {
            DateTime? before = null;
            if (!string.IsNullOrEmpty(beforeTimestamp) && DateTime.TryParse(beforeTimestamp, out var parsed))
            {
                before = parsed;
            }

            try
            {
                using var scope = _scopeFactory.CreateScope();
                var messageRepo = scope.ServiceProvider.GetRequiredService<IMessageRepository>();

                var dbMessages = await messageRepo.GetByRoomAsync(channelName, limit, before);
                var historyMessages = dbMessages.Select(m => new
                {
                    messageId = m.Id.ToString(),
                    senderId = m.SenderUser?.Username ?? m.SenderId ?? "",
                    senderName = m.SenderUser?.DisplayName ?? m.SenderUser?.Username ?? "Unknown",
                    content = m.Content,
                    timestamp = m.CreatedAt.ToString("o"),
                    type = "text",
                    metadata = m.Metadata
                }).ToList();

                await Clients.Caller.SendAsync("History", historyMessages);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get history from database for {Channel}", channelName);
                // Fall back to in-memory history
                var result = _chat.GetHistoryForHub(channelName, limit, before);
                await Clients.Caller.SendAsync("History", result);
            }
        }

        /// <summary>
        /// Send a typing indicator.
        /// </summary>
        public async Task TypingIndicator(string channelName, bool isTyping)
        {
            var userEvent = _chat.GetTypingEvent(Context.ConnectionId, isTyping);
            if (userEvent != null)
            {
                await Clients.OthersInGroup(channelName).SendAsync("UserTyping", userEvent);
            }
        }

        #region Contact Request Operations

        /// <summary>
        /// Send a contact request to another user.
        /// </summary>
        public async Task SendContactRequest(string fromUserId, string fromDisplayName, string toUserId, string? message = null)
        {
            _logger.LogInformation("Contact request from {FromUserId} to {ToUserId}", fromUserId, toUserId);

            var result = _chat.ContactRequestSend(fromUserId, fromDisplayName, toUserId, message);
            if (!result.Success || result.Request == null)
            {
                await Clients.Caller.SendAsync("Error", result.Error ?? "Failed to send contact request. Request may already exist.");
                return;
            }

            // Notify the sender
            await Clients.Caller.SendAsync("ContactRequestSent", new
            {
                requestId = result.Request.RequestId,
                toUserId = result.Request.ToUserId,
                status = result.Request.Status
            });

            // Notify the recipient if they're connected
            await Clients.Group($"user_{toUserId}").SendAsync("ContactRequestReceived", new
            {
                requestId = result.Request.RequestId,
                fromUserId = result.Request.FromUserId,
                fromDisplayName = result.Request.FromDisplayName,
                message = result.Request.Message,
                sentAt = result.Request.SentAt
            });
        }

        /// <summary>
        /// Accept a contact request.
        /// </summary>
        public async Task AcceptContactRequest(string requestId, string userId, string displayName)
        {
            _logger.LogInformation("User {UserId} accepting request {RequestId}", userId, requestId);

            // Get the request before accepting to know the sender
            var request = _chat.ContactRequestGet(requestId);

            if (request == null || request.ToUserId != userId)
            {
                await Clients.Caller.SendAsync("Error", "Contact request not found or you are not the recipient.");
                return;
            }

            var result = _chat.ContactRequestAccept(requestId, displayName);
            if (!result.Success)
            {
                await Clients.Caller.SendAsync("Error", result.Error ?? "Failed to accept contact request.");
                return;
            }

            // Notify the acceptor
            await Clients.Caller.SendAsync("ContactRequestAccepted", new
            {
                requestId = requestId,
                fromUserId = request.FromUserId,
                fromDisplayName = request.FromDisplayName
            });

            // Notify the original sender that their request was accepted
            await Clients.Group($"user_{request.FromUserId}").SendAsync("ContactRequestWasAccepted", new
            {
                requestId = requestId,
                byUserId = userId,
                byDisplayName = displayName
            });
        }

        /// <summary>
        /// Reject a contact request.
        /// </summary>
        public async Task RejectContactRequest(string requestId, string userId)
        {
            _logger.LogInformation("User {UserId} rejecting request {RequestId}", userId, requestId);

            var request = _chat.ContactRequestGet(requestId);

            if (request == null || request.ToUserId != userId)
            {
                await Clients.Caller.SendAsync("Error", "Contact request not found or you are not the recipient.");
                return;
            }

            var result = _chat.ContactRequestReject(requestId);
            if (!result.Success)
            {
                await Clients.Caller.SendAsync("Error", result.Error ?? "Failed to reject contact request.");
                return;
            }

            await Clients.Caller.SendAsync("ContactRequestRejected", new
            {
                requestId = requestId
            });
        }

        /// <summary>
        /// Cancel a sent contact request.
        /// </summary>
        public async Task CancelContactRequest(string requestId, string userId)
        {
            _logger.LogInformation("User {UserId} cancelling request {RequestId}", userId, requestId);

            var request = _chat.ContactRequestGet(requestId);

            if (request == null || request.FromUserId != userId)
            {
                await Clients.Caller.SendAsync("Error", "Contact request not found or you are not the sender.");
                return;
            }

            var success = _chat.ContactRequestCancel(requestId, userId);
            if (!success)
            {
                await Clients.Caller.SendAsync("Error", _chat.Message ?? "Failed to cancel contact request.");
                return;
            }

            await Clients.Caller.SendAsync("ContactRequestCancelled", new
            {
                requestId = requestId
            });

            // Notify the recipient that the request was cancelled
            await Clients.Group($"user_{request.ToUserId}").SendAsync("ContactRequestWasCancelled", new
            {
                requestId = requestId,
                fromUserId = request.FromUserId
            });
        }

        /// <summary>
        /// Get pending contact requests for the current user.
        /// </summary>
        public async Task GetPendingContactRequests(string userId)
        {
            var requests = _chat.ContactRequestGetPending(userId);
            await Clients.Caller.SendAsync("PendingContactRequests", requests.Select(r => new
            {
                requestId = r.RequestId,
                fromUserId = r.FromUserId,
                fromDisplayName = r.FromDisplayName,
                message = r.Message,
                sentAt = r.SentAt
            }));
        }

        /// <summary>
        /// Get sent contact requests for the current user.
        /// </summary>
        public async Task GetSentContactRequests(string userId)
        {
            var requests = _chat.ContactRequestGetSent(userId);
            await Clients.Caller.SendAsync("SentContactRequests", requests.Select(r => new
            {
                requestId = r.RequestId,
                toUserId = r.ToUserId,
                status = r.Status.ToString(),
                sentAt = r.SentAt
            }));
        }

        /// <summary>
        /// Join a user-specific group for receiving notifications.
        /// Call this after connecting to receive contact request notifications.
        /// </summary>
        public async Task JoinUserNotifications(string userId)
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, $"user_{userId}");
            _logger.LogInformation("User {UserId} joined notification group", userId);
        }

        #endregion

        #region File Attachment Operations

        /// <summary>
        /// Send a message with a file attachment (file must be uploaded first via API).
        /// </summary>
        public async Task SendFileMessage(string channelName, string fileId, string? caption = null)
        {
            _logger.LogInformation("SendFileMessage called: Channel={Channel}, FileId={FileId}, Caption={Caption}", 
                channelName, fileId, caption ?? "(none)");

            // Get file info from database
            using var scope = _scopeFactory.CreateScope();
            var fileRepo = scope.ServiceProvider.GetRequiredService<IChatFileRepository>();
            var userRepo = scope.ServiceProvider.GetRequiredService<IUserRepository>();
            var messageRepo = scope.ServiceProvider.GetRequiredService<IMessageRepository>();

            var fileEntity = await fileRepo.GetByFileIdAsync(fileId);
            if (fileEntity == null)
            {
                _logger.LogWarning("SendFileMessage: File not found in database: {FileId}", fileId);
                await Clients.Caller.SendAsync("Error", "File not found. Please upload the file first.");
                return;
            }
            
            _logger.LogInformation("SendFileMessage: File found - {FileName} ({ContentType}, {Size} bytes)", 
                fileEntity.FileName, fileEntity.ContentType, fileEntity.FileSize);

            // Get sender info - verify they are in the room
            var participant = _chat.ParticipantGetByConnection(Context.ConnectionId);
            if (participant == null)
            {
                _logger.LogWarning("SendFileMessage: Participant not found for connection {ConnectionId}", Context.ConnectionId);
                await Clients.Caller.SendAsync("Error", "You must join a room before sending messages.");
                return;
            }
            
            _logger.LogInformation("SendFileMessage: Sender is {UserId} ({DisplayName})", 
                participant.UserId, participant.DisplayName);

            // Get database user ID
            long? senderUserId = null;
            var dbUser = await userRepo.GetByUsernameAsync(participant.UserId);
            if (dbUser != null)
            {
                senderUserId = dbUser.Id;
            }

            // Only persist messages to database for persistent rooms (DM or group chats)
            // Video call chat messages are ephemeral and should not be stored
            bool isPersistentRoom = channelName.StartsWith("dm_") || channelName.StartsWith("group_");
            long? messageId = null;

            if (isPersistentRoom)
            {
                // Persist message to database with file metadata
                var fileMetadata = System.Text.Json.JsonSerializer.Serialize(new
                {
                    type = "file",
                    fileId = fileEntity.FileId,
                    fileName = fileEntity.FileName,
                    contentType = fileEntity.ContentType,
                    fileSize = fileEntity.FileSize,
                    downloadUrl = $"/api/files/{fileEntity.FileId}"
                });

                var messageEntity = new MessageEntity
                {
                    RoomId = channelName,
                    SenderId = participant?.UserId,
                    SenderUserId = senderUserId,
                    Content = caption ?? $"[Ficheiro: {fileEntity.FileName}]",
                    Metadata = fileMetadata,
                    CreatedAt = DateTime.UtcNow
                };

                await messageRepo.CreateAsync(messageEntity);
                messageId = messageEntity.Id;

                // Update file with message ID and room
                fileEntity.MessageId = messageEntity.Id;
                fileEntity.RoomId = channelName;
                await fileRepo.UpdateAsync(fileEntity);

                // Also create a text message that announces the file (this will persist even if file is deleted)
                var textMessageContent = $"📎 Ficheiro enviado: {fileEntity.FileName}";
                var textMessageEntity = new MessageEntity
                {
                    RoomId = channelName,
                    SenderId = participant?.UserId,
                    SenderUserId = senderUserId,
                    Content = textMessageContent,
                    Metadata = null, // No file metadata for the text message
                    CreatedAt = DateTime.UtcNow
                };
                await messageRepo.CreateAsync(textMessageEntity);

                _logger.LogDebug("File message persisted in {Channel}: {FileId}", channelName, fileId);
            }
            else
            {
                _logger.LogDebug("Video call channel {Channel} - file message not persisted to DB", channelName);
            }

            // Create text notification message
            var textNotificationMessage = new
            {
                messageId = Guid.NewGuid().ToString(),
                senderId = participant?.UserId ?? "",
                senderName = participant?.DisplayName ?? "Unknown",
                content = $"📎 Ficheiro enviado: {fileEntity.FileName}",
                timestamp = DateTime.UtcNow.ToString("o"),
                type = "text",
                attachment = (object?)null
            };

            // Broadcast text notification first
            await Clients.Group(channelName).SendAsync("MessageReceived", textNotificationMessage);

            // Create enriched file message for broadcast
            var enrichedMessage = new
            {
                messageId = messageId?.ToString() ?? Guid.NewGuid().ToString(),
                senderId = participant?.UserId ?? "",
                senderName = participant?.DisplayName ?? "Unknown",
                content = caption ?? $"[Ficheiro: {fileEntity.FileName}]",
                timestamp = DateTime.UtcNow.ToString("o"),
                type = "file",
                attachment = new
                {
                    fileId = fileEntity.FileId,
                    fileName = fileEntity.FileName,
                    contentType = fileEntity.ContentType,
                    fileSize = fileEntity.FileSize,
                    downloadUrl = $"/api/files/{fileEntity.FileId}"
                }
            };

            // Broadcast file message
            await Clients.Group(channelName).SendAsync("MessageReceived", enrichedMessage);
            _logger.LogInformation("File message broadcast to room {Channel}: {FileName}", channelName, fileEntity.FileName);

            // For DM rooms, also notify each participant via their notification group
            // This ensures they receive the notification even if not currently in the room
            if (channelName.StartsWith("dm_"))
            {
                var parts = channelName.Split('_');
                if (parts.Length >= 3)
                {
                    var memberIds = new[] { parts[1], parts[2] };
                    _logger.LogInformation("DM file message - notifying users: {Members}", string.Join(", ", memberIds));
                    
                    foreach (var memberId in memberIds)
                    {
                        // Don't send notification to sender (they already got it from the room group)
                        if (participant != null && memberId == participant.UserId) continue;
                        
                        _logger.LogInformation("Sending file notification to user_{MemberId}", memberId);
                        await Clients.Group($"user_{memberId}").SendAsync("DirectMessageReceived", new
                        {
                            channelName = channelName,
                            message = enrichedMessage
                        });
                    }
                }
            }

            // For video call chats, send a general notification to all participants
            if (!isPersistentRoom)
            {
                _logger.LogInformation("Video call file message broadcast to channel {Channel}", channelName);
            }
        }

        #endregion

        #region Professor Room Status

        /// <summary>
        /// Subscribe to professor room status updates.
        /// Students should call this to receive real-time status changes.
        /// </summary>
        public async Task SubscribeToProfessorRoomUpdates()
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, "professor_room_updates");
            _logger.LogInformation("Client {ConnectionId} subscribed to professor room updates", Context.ConnectionId);
        }

        /// <summary>
        /// Unsubscribe from professor room status updates.
        /// </summary>
        public async Task UnsubscribeFromProfessorRoomUpdates()
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, "professor_room_updates");
            _logger.LogInformation("Client {ConnectionId} unsubscribed from professor room updates", Context.ConnectionId);
        }

        /// <summary>
        /// Notify all subscribers that a professor room's status has changed.
        /// Called by the API when a professor starts/ends a call.
        /// </summary>
        public async Task NotifyProfessorRoomStatus(string roomName, string professorUsername, bool isOnline, int? participantCount = null)
        {
            _logger.LogInformation("Professor room {RoomName} status changed: online={IsOnline}, participants={Count}", 
                roomName, isOnline, participantCount);

            await Clients.Group("professor_room_updates").SendAsync("ProfessorRoomStatusChanged", new
            {
                roomName = roomName,
                professorUsername = professorUsername,
                isOnline = isOnline,
                participantCount = participantCount ?? 0,
                timestamp = DateTime.UtcNow.ToString("o")
            });
        }

        #endregion
    }
}
