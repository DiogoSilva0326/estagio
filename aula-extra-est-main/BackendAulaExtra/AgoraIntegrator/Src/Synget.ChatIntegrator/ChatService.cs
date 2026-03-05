namespace Synget.ChatIntegrator
{
    /// <summary>
    /// Implementation of the IChat interface.
    /// Provides in-memory chat room and message management.
    /// </summary>
    public class ChatService : IChat
    {
        /// <inheritdoc/>
        public string Message { get; set; } = string.Empty;

        private ChatConfig? _config;
        private readonly Dictionary<string, ChatRoom> _rooms = new();
        private readonly Dictionary<string, ChatParticipant> _connectionMap = new(); // connectionId -> participant
        private readonly object _lock = new();

        /// <inheritdoc/>
        public bool Initialize(ChatConfig config)
        {
            if (config is null)
            {
                Message = "Configuration cannot be null.";
                return false;
            }

            _config = config;
            Message = string.Empty;
            return true;
        }

        #region Room Operations

        /// <inheritdoc/>
        public ChatRoom? RoomGetOrCreate(string channelName)
        {
            if (string.IsNullOrWhiteSpace(channelName))
            {
                Message = "Channel name is required.";
                return null;
            }

            lock (_lock)
            {
                if (_rooms.TryGetValue(channelName, out var existing))
                {
                    if (!existing.IsActive)
                    {
                        existing.IsActive = true;
                    }
                    return existing;
                }

                var room = new ChatRoom
                {
                    ChannelName = channelName,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                _rooms[channelName] = room;
                Message = string.Empty;
                return room;
            }
        }

        /// <inheritdoc/>
        public ChatRoom? RoomGet(string channelName)
        {
            if (string.IsNullOrWhiteSpace(channelName))
            {
                Message = "Channel name is required.";
                return null;
            }

            lock (_lock)
            {
                return _rooms.TryGetValue(channelName, out var room) ? room : null;
            }
        }

        /// <inheritdoc/>
        public bool RoomClose(string channelName)
        {
            if (string.IsNullOrWhiteSpace(channelName))
            {
                Message = "Channel name is required.";
                return false;
            }

            lock (_lock)
            {
                if (!_rooms.TryGetValue(channelName, out var room))
                {
                    Message = "Room not found.";
                    return false;
                }

                // Remove all participants from connection map
                foreach (var participant in room.Participants)
                {
                    _connectionMap.Remove(participant.ConnectionId);
                }

                room.IsActive = false;
                room.Participants.Clear();
                Message = string.Empty;
                return true;
            }
        }

        /// <inheritdoc/>
        public List<ChatRoom> RoomGetAll()
        {
            lock (_lock)
            {
                return _rooms.Values.Where(r => r.IsActive).ToList();
            }
        }

        #endregion

        #region Participant Operations

        /// <inheritdoc/>
        public bool ParticipantJoin(string channelName, string userId, string displayName, string connectionId)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
            {
                Message = "Channel name and user ID are required.";
                return false;
            }

            lock (_lock)
            {
                var room = RoomGetOrCreate(channelName);
                if (room is null) return false;

                // Check if user already exists
                var existing = room.Participants.FirstOrDefault(p => 
                    string.Equals(p.UserId, userId, StringComparison.OrdinalIgnoreCase));

                if (existing != null)
                {
                    // Update connection ID (reconnect scenario)
                    _connectionMap.Remove(existing.ConnectionId);
                    existing.ConnectionId = connectionId;
                    existing.IsConnected = true;
                    existing.DisplayName = displayName ?? existing.DisplayName;
                    _connectionMap[connectionId] = existing;
                }
                else
                {
                    var participant = new ChatParticipant
                    {
                        UserId = userId,
                        DisplayName = displayName ?? $"User {userId}",
                        ConnectionId = connectionId,
                        ChannelName = channelName,
                        JoinedAt = DateTime.UtcNow,
                        IsConnected = true
                    };

                    room.Participants.Add(participant);
                    _connectionMap[connectionId] = participant;
                }

                Message = string.Empty;
                return true;
            }
        }

        /// <inheritdoc/>
        public bool ParticipantLeave(string channelName, string userId)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
            {
                Message = "Channel name and user ID are required.";
                return false;
            }

            lock (_lock)
            {
                if (!_rooms.TryGetValue(channelName, out var room))
                {
                    Message = "Room not found.";
                    return false;
                }

                var participant = room.Participants.FirstOrDefault(p =>
                    string.Equals(p.UserId, userId, StringComparison.OrdinalIgnoreCase));

                if (participant != null)
                {
                    _connectionMap.Remove(participant.ConnectionId);
                    room.Participants.Remove(participant);
                }

                // Close room if empty
                if (room.Participants.Count == 0)
                {
                    room.IsActive = false;
                }

                Message = string.Empty;
                return true;
            }
        }

        /// <inheritdoc/>
        public ChatParticipant? ParticipantGet(string channelName, string userId)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
                return null;

            lock (_lock)
            {
                if (!_rooms.TryGetValue(channelName, out var room))
                    return null;

                return room.Participants.FirstOrDefault(p =>
                    string.Equals(p.UserId, userId, StringComparison.OrdinalIgnoreCase));
            }
        }

        /// <inheritdoc/>
        public ChatParticipant? ParticipantGetByConnection(string connectionId)
        {
            if (string.IsNullOrWhiteSpace(connectionId))
                return null;

            lock (_lock)
            {
                return _connectionMap.TryGetValue(connectionId, out var participant) ? participant : null;
            }
        }

        /// <inheritdoc/>
        public bool ParticipantUpdateConnection(string channelName, string userId, string newConnectionId)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
            {
                Message = "Channel name and user ID are required.";
                return false;
            }

            lock (_lock)
            {
                var participant = ParticipantGet(channelName, userId);
                if (participant is null)
                {
                    Message = "Participant not found.";
                    return false;
                }

                _connectionMap.Remove(participant.ConnectionId);
                participant.ConnectionId = newConnectionId;
                participant.IsConnected = true;
                _connectionMap[newConnectionId] = participant;

                Message = string.Empty;
                return true;
            }
        }

        #endregion

        #region Message Operations

        /// <inheritdoc/>
        public bool MessageStore(string channelName, ChatMessage message)
        {
            if (string.IsNullOrWhiteSpace(channelName) || message is null)
            {
                Message = "Channel name and message are required.";
                return false;
            }

            lock (_lock)
            {
                if (!_rooms.TryGetValue(channelName, out var room))
                {
                    Message = "Room not found.";
                    return false;
                }

                message.ChannelName = channelName;
                room.Messages.Add(message);
                room.TotalMessageCount++;

                // Trim old messages if exceeding limit
                var maxMessages = _config?.MaxMessagesPerRoom ?? 1000;
                if (room.Messages.Count > maxMessages)
                {
                    room.Messages.RemoveRange(0, room.Messages.Count - maxMessages);
                }

                Message = string.Empty;
                return true;
            }
        }

        /// <inheritdoc/>
        public List<ChatMessage> MessageGetHistory(string channelName, int limit = 50, DateTime? beforeTimestamp = null)
        {
            if (string.IsNullOrWhiteSpace(channelName))
                return new List<ChatMessage>();

            lock (_lock)
            {
                if (!_rooms.TryGetValue(channelName, out var room))
                    return new List<ChatMessage>();

                var query = room.Messages.AsEnumerable();

                if (beforeTimestamp.HasValue)
                {
                    query = query.Where(m => m.Timestamp < beforeTimestamp.Value);
                }

                if (limit > 0)
                {
                    query = query.TakeLast(limit);
                }

                return query.ToList();
            }
        }

        /// <inheritdoc/>
        public bool MessageClearHistory(string channelName)
        {
            if (string.IsNullOrWhiteSpace(channelName))
            {
                Message = "Channel name is required.";
                return false;
            }

            lock (_lock)
            {
                if (!_rooms.TryGetValue(channelName, out var room))
                {
                    Message = "Room not found.";
                    return false;
                }

                room.Messages.Clear();
                Message = string.Empty;
                return true;
            }
        }

        #endregion

        #region Contact Operations

        private readonly Dictionary<string, List<Contact>> _contacts = new(); // ownerId -> contacts

        /// <inheritdoc/>
        public Contact? ContactAdd(string ownerId, string contactUserId, string displayName)
        {
            if (string.IsNullOrWhiteSpace(ownerId) || string.IsNullOrWhiteSpace(contactUserId))
            {
                Message = "Owner ID and contact user ID are required.";
                return null;
            }

            if (ownerId == contactUserId)
            {
                Message = "Cannot add yourself as a contact.";
                return null;
            }

            lock (_lock)
            {
                if (!_contacts.ContainsKey(ownerId))
                {
                    _contacts[ownerId] = new List<Contact>();
                }

                // Check if already exists
                var existing = _contacts[ownerId].FirstOrDefault(c => c.ContactUserId == contactUserId);
                if (existing != null)
                {
                    Message = "Contact already exists.";
                    return existing;
                }

                var contact = new Contact
                {
                    OwnerId = ownerId,
                    ContactUserId = contactUserId,
                    DisplayName = displayName,
                    AddedAt = DateTime.UtcNow
                };

                _contacts[ownerId].Add(contact);
                Message = string.Empty;
                return contact;
            }
        }

        /// <inheritdoc/>
        public bool ContactRemove(string ownerId, string contactUserId)
        {
            if (string.IsNullOrWhiteSpace(ownerId) || string.IsNullOrWhiteSpace(contactUserId))
            {
                Message = "Owner ID and contact user ID are required.";
                return false;
            }

            lock (_lock)
            {
                if (!_contacts.ContainsKey(ownerId))
                {
                    Message = "No contacts found.";
                    return false;
                }

                var removed = _contacts[ownerId].RemoveAll(c => c.ContactUserId == contactUserId);
                if (removed == 0)
                {
                    Message = "Contact not found.";
                    return false;
                }

                Message = string.Empty;
                return true;
            }
        }

        /// <inheritdoc/>
        public List<Contact> ContactGetAll(string ownerId)
        {
            if (string.IsNullOrWhiteSpace(ownerId))
                return new List<Contact>();

            lock (_lock)
            {
                if (_contacts.TryGetValue(ownerId, out var contacts))
                {
                    return contacts.ToList();
                }
                return new List<Contact>();
            }
        }

        /// <inheritdoc/>
        public Contact? ContactGet(string ownerId, string contactUserId)
        {
            if (string.IsNullOrWhiteSpace(ownerId) || string.IsNullOrWhiteSpace(contactUserId))
                return null;

            lock (_lock)
            {
                if (_contacts.TryGetValue(ownerId, out var contacts))
                {
                    return contacts.FirstOrDefault(c => c.ContactUserId == contactUserId);
                }
                return null;
            }
        }

        /// <inheritdoc/>
        public bool ContactUpdate(Contact contact)
        {
            if (contact is null || string.IsNullOrWhiteSpace(contact.OwnerId))
            {
                Message = "Valid contact is required.";
                return false;
            }

            lock (_lock)
            {
                if (!_contacts.TryGetValue(contact.OwnerId, out var contacts))
                {
                    Message = "No contacts found for this user.";
                    return false;
                }

                var existing = contacts.FirstOrDefault(c => c.ContactUserId == contact.ContactUserId);
                if (existing is null)
                {
                    Message = "Contact not found.";
                    return false;
                }

                existing.DisplayName = contact.DisplayName;
                existing.Nickname = contact.Nickname;
                existing.IsBlocked = contact.IsBlocked;
                existing.IsPending = contact.IsPending;

                Message = string.Empty;
                return true;
            }
        }

        #endregion

        #region Standalone Chat Operations

        private readonly Dictionary<string, StandaloneChatRoom> _standaloneRooms = new();

        /// <inheritdoc/>
        public StandaloneChatRoom? DirectMessageCreate(string userId1, string userId2)
        {
            if (string.IsNullOrWhiteSpace(userId1) || string.IsNullOrWhiteSpace(userId2))
            {
                Message = "Both user IDs are required.";
                return null;
            }

            if (userId1 == userId2)
            {
                Message = "Cannot create DM with yourself.";
                return null;
            }

            var roomId = StandaloneChatRoom.GetDirectMessageRoomId(userId1, userId2);

            lock (_lock)
            {
                if (_standaloneRooms.TryGetValue(roomId, out var existing))
                {
                    Message = "DM room already exists.";
                    return existing;
                }

                var room = new StandaloneChatRoom
                {
                    RoomId = roomId,
                    ChannelName = roomId,
                    RoomType = ChatRoomType.DirectMessage,
                    CreatorUserId = userId1,
                    MemberUserIds = new List<string> { userId1, userId2 },
                    CreatedAt = DateTime.UtcNow
                };

                _standaloneRooms[roomId] = room;
                _rooms[roomId] = room; // Also add to main rooms for message operations

                Message = string.Empty;
                return room;
            }
        }

        /// <inheritdoc/>
        public StandaloneChatRoom? DirectMessageGetOrCreate(string userId1, string userId2)
        {
            if (string.IsNullOrWhiteSpace(userId1) || string.IsNullOrWhiteSpace(userId2))
            {
                Message = "Both user IDs are required.";
                return null;
            }

            var roomId = StandaloneChatRoom.GetDirectMessageRoomId(userId1, userId2);

            lock (_lock)
            {
                if (_standaloneRooms.TryGetValue(roomId, out var existing))
                {
                    return existing;
                }
            }

            return DirectMessageCreate(userId1, userId2);
        }

        /// <inheritdoc/>
        public StandaloneChatRoom? GroupCreate(string creatorUserId, string groupName, IEnumerable<string> memberUserIds)
        {
            if (string.IsNullOrWhiteSpace(creatorUserId))
            {
                Message = "Creator user ID is required.";
                return null;
            }

            if (string.IsNullOrWhiteSpace(groupName))
            {
                Message = "Group name is required.";
                return null;
            }

            var members = memberUserIds?.ToList() ?? new List<string>();
            if (!members.Contains(creatorUserId))
            {
                members.Add(creatorUserId);
            }

            lock (_lock)
            {
                var room = new StandaloneChatRoom
                {
                    RoomId = Guid.NewGuid().ToString("N"),
                    ChannelName = $"group_{Guid.NewGuid():N}",
                    RoomType = ChatRoomType.Group,
                    GroupName = groupName,
                    CreatorUserId = creatorUserId,
                    MemberUserIds = members,
                    CreatedAt = DateTime.UtcNow
                };

                _standaloneRooms[room.RoomId] = room;
                _rooms[room.ChannelName] = room;

                Message = string.Empty;
                return room;
            }
        }

        /// <inheritdoc/>
        public bool GroupAddMember(string roomId, string userId)
        {
            if (string.IsNullOrWhiteSpace(roomId) || string.IsNullOrWhiteSpace(userId))
            {
                Message = "Room ID and user ID are required.";
                return false;
            }

            lock (_lock)
            {
                if (!_standaloneRooms.TryGetValue(roomId, out var room))
                {
                    Message = "Room not found.";
                    return false;
                }

                if (room.RoomType != ChatRoomType.Group)
                {
                    Message = "Cannot add members to non-group rooms.";
                    return false;
                }

                if (room.MemberUserIds.Contains(userId))
                {
                    Message = "User is already a member.";
                    return true;
                }

                room.MemberUserIds.Add(userId);
                Message = string.Empty;
                return true;
            }
        }

        /// <inheritdoc/>
        public bool GroupRemoveMember(string roomId, string userId)
        {
            if (string.IsNullOrWhiteSpace(roomId) || string.IsNullOrWhiteSpace(userId))
            {
                Message = "Room ID and user ID are required.";
                return false;
            }

            lock (_lock)
            {
                if (!_standaloneRooms.TryGetValue(roomId, out var room))
                {
                    Message = "Room not found.";
                    return false;
                }

                if (room.RoomType != ChatRoomType.Group)
                {
                    Message = "Cannot remove members from non-group rooms.";
                    return false;
                }

                var removed = room.MemberUserIds.Remove(userId);
                if (!removed)
                {
                    Message = "User is not a member.";
                    return false;
                }

                Message = string.Empty;
                return true;
            }
        }

        /// <inheritdoc/>
        public List<StandaloneChatRoom> StandaloneChatGetRooms(string userId)
        {
            if (string.IsNullOrWhiteSpace(userId))
                return new List<StandaloneChatRoom>();

            lock (_lock)
            {
                return _standaloneRooms.Values
                    .Where(r => r.MemberUserIds.Contains(userId))
                    .ToList();
            }
        }

        /// <inheritdoc/>
        public StandaloneChatRoom? StandaloneChatGetRoom(string roomId)
        {
            if (string.IsNullOrWhiteSpace(roomId))
                return null;

            lock (_lock)
            {
                _standaloneRooms.TryGetValue(roomId, out var room);
                return room;
            }
        }

        #endregion

        #region High-Level Hub Operations

        /// <inheritdoc/>
        public JoinRoomResult ProcessJoinRoom(string channelName, string userId, string displayName, string connectionId)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
            {
                return new JoinRoomResult
                {
                    Success = false,
                    Error = "Channel name and user ID are required."
                };
            }

            // Join the room
            if (!ParticipantJoin(channelName, userId, displayName, connectionId))
            {
                return new JoinRoomResult
                {
                    Success = false,
                    Error = Message
                };
            }

            // Store system message
            MessageStore(channelName, new ChatMessage
            {
                SenderId = "system",
                SenderName = "System",
                Content = $"{displayName} joined the chat",
                Type = ChatMessageType.System
            });

            // Get history and participants
            var history = MessageGetHistory(channelName, limit: 50);
            var room = RoomGet(channelName);

            return new JoinRoomResult
            {
                Success = true,
                ChannelName = channelName,
                Messages = history.Select(MessageDto.FromChatMessage).ToList(),
                Participants = room?.Participants.Select(ParticipantDto.FromChatParticipant).ToList() ?? new List<ParticipantDto>(),
                UserEvent = new UserEventDto
                {
                    UserId = userId,
                    DisplayName = displayName,
                    Timestamp = DateTime.UtcNow
                }
            };
        }

        /// <inheritdoc/>
        public LeaveRoomResult ProcessLeaveRoom(string channelName, string connectionId)
        {
            var participant = ParticipantGetByConnection(connectionId);
            if (participant == null)
            {
                return new LeaveRoomResult { Success = false };
            }

            // Store system message
            MessageStore(channelName, new ChatMessage
            {
                SenderId = "system",
                SenderName = "System",
                Content = $"{participant.DisplayName} left the chat",
                Type = ChatMessageType.System
            });

            var userEvent = new UserEventDto
            {
                UserId = participant.UserId,
                DisplayName = participant.DisplayName,
                Timestamp = DateTime.UtcNow
            };

            ParticipantLeave(channelName, participant.UserId);

            return new LeaveRoomResult
            {
                Success = true,
                UserEvent = userEvent
            };
        }

        /// <inheritdoc/>
        public SendMessageResult ProcessSendMessage(string channelName, string content, string connectionId)
        {
            var participant = ParticipantGetByConnection(connectionId);
            if (participant == null)
            {
                return new SendMessageResult
                {
                    Success = false,
                    Error = "You must join a room before sending messages."
                };
            }

            if (string.IsNullOrWhiteSpace(content))
            {
                return new SendMessageResult
                {
                    Success = false,
                    Error = "Message content is required."
                };
            }

            var message = new ChatMessage
            {
                SenderId = participant.UserId,
                SenderName = participant.DisplayName,
                Content = content.Trim(),
                ChannelName = channelName,
                Type = ChatMessageType.Text
            };

            if (!MessageStore(channelName, message))
            {
                return new SendMessageResult
                {
                    Success = false,
                    Error = Message
                };
            }

            return new SendMessageResult
            {
                Success = true,
                Message = MessageDto.FromChatMessage(message)
            };
        }

        /// <inheritdoc/>
        public HistoryResult GetHistoryForHub(string channelName, int limit = 50, DateTime? beforeTimestamp = null)
        {
            var messages = MessageGetHistory(channelName, limit, beforeTimestamp);
            return new HistoryResult
            {
                ChannelName = channelName,
                Messages = messages.Select(MessageDto.FromChatMessage).ToList()
            };
        }

        /// <inheritdoc/>
        public ParticipantsResult GetParticipantsForHub(string channelName)
        {
            var room = RoomGet(channelName);
            return new ParticipantsResult
            {
                Participants = room?.Participants.Select(ParticipantDto.FromChatParticipant).ToList() ?? new List<ParticipantDto>()
            };
        }

        /// <inheritdoc/>
        public UserEventDto? GetTypingEvent(string connectionId, bool isTyping)
        {
            var participant = ParticipantGetByConnection(connectionId);
            if (participant == null) return null;

            return new UserEventDto
            {
                UserId = participant.UserId,
                DisplayName = participant.DisplayName,
                Timestamp = DateTime.UtcNow,
                IsTyping = isTyping
            };
        }

        #endregion

        #region Contact Request Operations

        private readonly Dictionary<string, ContactRequest> _contactRequests = new(); // requestId -> request

        /// <inheritdoc/>
        public SendContactRequestResult ContactRequestSend(string fromUserId, string fromDisplayName, string toUserId, string? message = null)
        {
            if (string.IsNullOrWhiteSpace(fromUserId) || string.IsNullOrWhiteSpace(toUserId))
            {
                return new SendContactRequestResult
                {
                    Success = false,
                    Error = "Both user IDs are required."
                };
            }

            if (fromUserId == toUserId)
            {
                return new SendContactRequestResult
                {
                    Success = false,
                    Error = "Cannot send contact request to yourself."
                };
            }

            lock (_lock)
            {
                // Check if already contacts
                if (_contacts.TryGetValue(fromUserId, out var senderContacts))
                {
                    var existingContact = senderContacts.FirstOrDefault(c => c.ContactUserId == toUserId && !c.IsPending);
                    if (existingContact != null)
                    {
                        return new SendContactRequestResult
                        {
                            Success = false,
                            Error = "Already a contact."
                        };
                    }
                }

                // Check if pending request already exists
                var existingRequest = _contactRequests.Values.FirstOrDefault(r =>
                    r.Status == ContactRequestStatus.Pending &&
                    ((r.FromUserId == fromUserId && r.ToUserId == toUserId) ||
                     (r.FromUserId == toUserId && r.ToUserId == fromUserId)));

                if (existingRequest != null)
                {
                    return new SendContactRequestResult
                    {
                        Success = false,
                        Error = "A pending request already exists between these users."
                    };
                }

                var request = new ContactRequest
                {
                    FromUserId = fromUserId,
                    FromDisplayName = fromDisplayName,
                    ToUserId = toUserId,
                    Message = message,
                    Status = ContactRequestStatus.Pending
                };

                _contactRequests[request.RequestId] = request;

                Message = string.Empty;
                return new SendContactRequestResult
                {
                    Success = true,
                    Request = ContactRequestDto.FromContactRequest(request)
                };
            }
        }

        /// <inheritdoc/>
        public ContactRequestResponseResult ContactRequestAccept(string requestId, string acceptingUserDisplayName)
        {
            if (string.IsNullOrWhiteSpace(requestId))
            {
                return new ContactRequestResponseResult
                {
                    Success = false,
                    Error = "Request ID is required."
                };
            }

            lock (_lock)
            {
                if (!_contactRequests.TryGetValue(requestId, out var request))
                {
                    return new ContactRequestResponseResult
                    {
                        Success = false,
                        Error = "Request not found."
                    };
                }

                if (request.Status != ContactRequestStatus.Pending)
                {
                    return new ContactRequestResponseResult
                    {
                        Success = false,
                        Error = $"Request is already {request.Status.ToString().ToLowerInvariant()}."
                    };
                }

                request.Status = ContactRequestStatus.Accepted;
                request.RespondedAt = DateTime.UtcNow;

                // Create mutual contacts
                var senderContact = ContactAdd(request.FromUserId, request.ToUserId, acceptingUserDisplayName);
                var receiverContact = ContactAdd(request.ToUserId, request.FromUserId, request.FromDisplayName);

                // Mark as not pending
                if (senderContact != null) senderContact.IsPending = false;
                if (receiverContact != null) receiverContact.IsPending = false;

                Message = string.Empty;
                return new ContactRequestResponseResult
                {
                    Success = true,
                    Request = ContactRequestDto.FromContactRequest(request),
                    SenderContact = senderContact,
                    ReceiverContact = receiverContact
                };
            }
        }

        /// <inheritdoc/>
        public ContactRequestResponseResult ContactRequestReject(string requestId)
        {
            if (string.IsNullOrWhiteSpace(requestId))
            {
                return new ContactRequestResponseResult
                {
                    Success = false,
                    Error = "Request ID is required."
                };
            }

            lock (_lock)
            {
                if (!_contactRequests.TryGetValue(requestId, out var request))
                {
                    return new ContactRequestResponseResult
                    {
                        Success = false,
                        Error = "Request not found."
                    };
                }

                if (request.Status != ContactRequestStatus.Pending)
                {
                    return new ContactRequestResponseResult
                    {
                        Success = false,
                        Error = $"Request is already {request.Status.ToString().ToLowerInvariant()}."
                    };
                }

                request.Status = ContactRequestStatus.Rejected;
                request.RespondedAt = DateTime.UtcNow;

                Message = string.Empty;
                return new ContactRequestResponseResult
                {
                    Success = true,
                    Request = ContactRequestDto.FromContactRequest(request)
                };
            }
        }

        /// <inheritdoc/>
        public bool ContactRequestCancel(string requestId, string userId)
        {
            if (string.IsNullOrWhiteSpace(requestId) || string.IsNullOrWhiteSpace(userId))
            {
                Message = "Request ID and user ID are required.";
                return false;
            }

            lock (_lock)
            {
                if (!_contactRequests.TryGetValue(requestId, out var request))
                {
                    Message = "Request not found.";
                    return false;
                }

                if (request.FromUserId != userId)
                {
                    Message = "Only the sender can cancel a request.";
                    return false;
                }

                if (request.Status != ContactRequestStatus.Pending)
                {
                    Message = $"Cannot cancel a request that is already {request.Status.ToString().ToLowerInvariant()}.";
                    return false;
                }

                request.Status = ContactRequestStatus.Cancelled;
                request.RespondedAt = DateTime.UtcNow;

                Message = string.Empty;
                return true;
            }
        }

        /// <inheritdoc/>
        public List<ContactRequest> ContactRequestGetPending(string userId)
        {
            if (string.IsNullOrWhiteSpace(userId))
                return new List<ContactRequest>();

            lock (_lock)
            {
                return _contactRequests.Values
                    .Where(r => r.ToUserId == userId && r.Status == ContactRequestStatus.Pending)
                    .OrderByDescending(r => r.SentAt)
                    .ToList();
            }
        }

        /// <inheritdoc/>
        public List<ContactRequest> ContactRequestGetSent(string userId)
        {
            if (string.IsNullOrWhiteSpace(userId))
                return new List<ContactRequest>();

            lock (_lock)
            {
                return _contactRequests.Values
                    .Where(r => r.FromUserId == userId)
                    .OrderByDescending(r => r.SentAt)
                    .ToList();
            }
        }

        /// <inheritdoc/>
        public ContactRequest? ContactRequestGet(string requestId)
        {
            if (string.IsNullOrWhiteSpace(requestId))
                return null;

            lock (_lock)
            {
                _contactRequests.TryGetValue(requestId, out var request);
                return request;
            }
        }

        #endregion

        #region Message Permission Operations

        /// <inheritdoc/>
        public MessagePermissionResult CanSendDirectMessage(string fromUserId, string toUserId)
        {
            if (string.IsNullOrWhiteSpace(fromUserId) || string.IsNullOrWhiteSpace(toUserId))
            {
                return new MessagePermissionResult
                {
                    CanSendMessage = false,
                    Reason = "Invalid user IDs."
                };
            }

            lock (_lock)
            {
                // Check if fromUser has toUser as a contact (and not pending/blocked)
                var fromHasTo = false;
                if (_contacts.TryGetValue(fromUserId, out var fromContacts))
                {
                    var contact = fromContacts.FirstOrDefault(c => c.ContactUserId == toUserId);
                    fromHasTo = contact != null && !contact.IsPending && !contact.IsBlocked;
                }

                // Check if toUser has fromUser as a contact (and not pending/blocked)
                var toHasFrom = false;
                if (_contacts.TryGetValue(toUserId, out var toContacts))
                {
                    var contact = toContacts.FirstOrDefault(c => c.ContactUserId == fromUserId);
                    toHasFrom = contact != null && !contact.IsPending && !contact.IsBlocked;
                }

                if (!fromHasTo || !toHasFrom)
                {
                    return new MessagePermissionResult
                    {
                        CanSendMessage = false,
                        Reason = "You can only message users who have accepted your contact request."
                    };
                }

                // Check if blocked
                if (_contacts.TryGetValue(toUserId, out var targetContacts))
                {
                    var blockedByTarget = targetContacts.FirstOrDefault(c => c.ContactUserId == fromUserId && c.IsBlocked);
                    if (blockedByTarget != null)
                    {
                        return new MessagePermissionResult
                        {
                            CanSendMessage = false,
                            Reason = "You cannot message this user."
                        };
                    }
                }

                return new MessagePermissionResult
                {
                    CanSendMessage = true
                };
            }
        }

        /// <inheritdoc/>
        public MessagePermissionResult CanSendToRoom(string userId, string roomId)
        {
            if (string.IsNullOrWhiteSpace(userId) || string.IsNullOrWhiteSpace(roomId))
            {
                return new MessagePermissionResult
                {
                    CanSendMessage = false,
                    Reason = "Invalid parameters."
                };
            }

            lock (_lock)
            {
                // Check if it's a standalone room
                if (_standaloneRooms.TryGetValue(roomId, out var standaloneRoom))
                {
                    // Check if user is a member
                    if (!standaloneRoom.MemberUserIds.Contains(userId))
                    {
                        return new MessagePermissionResult
                        {
                            CanSendMessage = false,
                            Reason = "You are not a member of this room."
                        };
                    }

                    // For DM rooms, check mutual contact
                    if (standaloneRoom.RoomType == ChatRoomType.DirectMessage)
                    {
                        var otherUserId = standaloneRoom.MemberUserIds.FirstOrDefault(id => id != userId);
                        if (otherUserId != null)
                        {
                            return CanSendDirectMessage(userId, otherUserId);
                        }
                    }

                    // For group rooms, just check membership (already done above)
                    return new MessagePermissionResult
                    {
                        CanSendMessage = true
                    };
                }

                // For regular chat rooms (video call associated), allow if participant
                if (_rooms.TryGetValue(roomId, out var room))
                {
                    var isParticipant = room.Participants.Any(p => p.UserId == userId);
                    return new MessagePermissionResult
                    {
                        CanSendMessage = isParticipant,
                        Reason = isParticipant ? null : "You must join the room to send messages."
                    };
                }

                return new MessagePermissionResult
                {
                    CanSendMessage = false,
                    Reason = "Room not found."
                };
            }
        }

        #endregion

        #region File Operations

        private readonly Dictionary<string, FileAttachment> _files = new(); // fileId -> file

        /// <inheritdoc/>
        public FileAttachment? FileRegister(string userId, string fileName, string contentType, long fileSize, string storagePath, string downloadUrl)
        {
            if (string.IsNullOrWhiteSpace(userId) || string.IsNullOrWhiteSpace(fileName))
            {
                Message = "User ID and filename are required.";
                return null;
            }

            lock (_lock)
            {
                var file = new FileAttachment
                {
                    FileName = fileName,
                    ContentType = contentType,
                    FileSize = fileSize,
                    StoragePath = storagePath,
                    DownloadUrl = downloadUrl,
                    UploadedByUserId = userId
                };

                _files[file.FileId] = file;

                Message = string.Empty;
                return file;
            }
        }

        /// <inheritdoc/>
        public FileAttachment? FileGet(string fileId)
        {
            if (string.IsNullOrWhiteSpace(fileId))
                return null;

            lock (_lock)
            {
                _files.TryGetValue(fileId, out var file);
                return file;
            }
        }

        /// <inheritdoc/>
        public SendFileMessageResult ProcessSendFileMessage(string channelName, string fileId, string connectionId, string? caption = null)
        {
            var participant = ParticipantGetByConnection(connectionId);
            if (participant == null)
            {
                return new SendFileMessageResult
                {
                    Success = false,
                    Error = "You must join a room before sending messages."
                };
            }

            var file = FileGet(fileId);
            if (file == null)
            {
                return new SendFileMessageResult
                {
                    Success = false,
                    Error = "File not found. Upload the file first."
                };
            }

            // Check permission for DM rooms
            var permissionResult = CanSendToRoom(participant.UserId, channelName);
            if (!permissionResult.CanSendMessage)
            {
                return new SendFileMessageResult
                {
                    Success = false,
                    Error = permissionResult.Reason
                };
            }

            var message = new ChatMessage
            {
                SenderId = participant.UserId,
                SenderName = participant.DisplayName,
                Content = caption ?? file.FileName,
                ChannelName = channelName,
                Type = ChatMessageType.Attachment,
                Attachment = file
            };

            if (!MessageStore(channelName, message))
            {
                return new SendFileMessageResult
                {
                    Success = false,
                    Error = Message
                };
            }

            return new SendFileMessageResult
            {
                Success = true,
                Message = MessageDto.FromChatMessage(message),
                File = FileAttachmentDto.FromFileAttachment(file)
            };
        }

        #endregion
    }
}
