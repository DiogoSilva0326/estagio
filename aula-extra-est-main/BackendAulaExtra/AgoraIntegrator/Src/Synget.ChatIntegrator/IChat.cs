namespace Synget.ChatIntegrator
{
    /// <summary>
    /// Interface for chat integration services.
    /// Defines the contract for real-time messaging in video call sessions.
    /// </summary>
    public interface IChat
    {
        /// <summary>
        /// Error/status message from the last operation.
        /// </summary>
        string Message { get; set; }

        /// <summary>
        /// Initialize the chat service.
        /// </summary>
        /// <param name="config">Chat configuration.</param>
        /// <returns>True if initialization succeeded.</returns>
        bool Initialize(ChatConfig config);

        #region Room Operations

        /// <summary>
        /// Create or get a chat room for a channel.
        /// </summary>
        /// <param name="channelName">The channel/room name.</param>
        /// <returns>The chat room or null on error.</returns>
        ChatRoom? RoomGetOrCreate(string channelName);

        /// <summary>
        /// Get an existing chat room.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <returns>The chat room or null if not found.</returns>
        ChatRoom? RoomGet(string channelName);

        /// <summary>
        /// Close a chat room and remove all participants.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <returns>True if successful.</returns>
        bool RoomClose(string channelName);

        /// <summary>
        /// Get all active chat rooms.
        /// </summary>
        /// <returns>List of active rooms.</returns>
        List<ChatRoom> RoomGetAll();

        #endregion

        #region Participant Operations

        /// <summary>
        /// Add a participant to a chat room.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <param name="userId">The user's unique ID.</param>
        /// <param name="displayName">The user's display name.</param>
        /// <param name="connectionId">The SignalR connection ID.</param>
        /// <returns>True if successful.</returns>
        bool ParticipantJoin(string channelName, string userId, string displayName, string connectionId);

        /// <summary>
        /// Remove a participant from a chat room.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <param name="userId">The user's ID.</param>
        /// <returns>True if successful.</returns>
        bool ParticipantLeave(string channelName, string userId);

        /// <summary>
        /// Get a participant by user ID.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <param name="userId">The user's ID.</param>
        /// <returns>The participant or null.</returns>
        ChatParticipant? ParticipantGet(string channelName, string userId);

        /// <summary>
        /// Get a participant by connection ID.
        /// </summary>
        /// <param name="connectionId">The SignalR connection ID.</param>
        /// <returns>The participant or null.</returns>
        ChatParticipant? ParticipantGetByConnection(string connectionId);

        /// <summary>
        /// Update a participant's connection ID (e.g., on reconnect).
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <param name="userId">The user's ID.</param>
        /// <param name="newConnectionId">The new connection ID.</param>
        /// <returns>True if successful.</returns>
        bool ParticipantUpdateConnection(string channelName, string userId, string newConnectionId);

        #endregion

        #region Message Operations

        /// <summary>
        /// Store a message in the chat room history.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <param name="message">The message to store.</param>
        /// <returns>True if successful.</returns>
        bool MessageStore(string channelName, ChatMessage message);

        /// <summary>
        /// Get message history for a chat room.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <param name="limit">Maximum number of messages to return (0 = all).</param>
        /// <param name="beforeTimestamp">Get messages before this timestamp (null = latest).</param>
        /// <returns>List of messages.</returns>
        List<ChatMessage> MessageGetHistory(string channelName, int limit = 50, DateTime? beforeTimestamp = null);

        /// <summary>
        /// Clear message history for a chat room.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <returns>True if successful.</returns>
        bool MessageClearHistory(string channelName);

        #endregion

        #region Contact Operations

        /// <summary>
        /// Add a contact for a user.
        /// </summary>
        /// <param name="ownerId">The user who is adding the contact.</param>
        /// <param name="contactUserId">The contact's user ID.</param>
        /// <param name="displayName">Display name for the contact.</param>
        /// <returns>The created contact or null on error.</returns>
        Contact? ContactAdd(string ownerId, string contactUserId, string displayName);

        /// <summary>
        /// Remove a contact.
        /// </summary>
        /// <param name="ownerId">The owner user ID.</param>
        /// <param name="contactUserId">The contact to remove.</param>
        /// <returns>True if successful.</returns>
        bool ContactRemove(string ownerId, string contactUserId);

        /// <summary>
        /// Get all contacts for a user.
        /// </summary>
        /// <param name="ownerId">The owner user ID.</param>
        /// <returns>List of contacts.</returns>
        List<Contact> ContactGetAll(string ownerId);

        /// <summary>
        /// Get a specific contact.
        /// </summary>
        /// <param name="ownerId">The owner user ID.</param>
        /// <param name="contactUserId">The contact's user ID.</param>
        /// <returns>The contact or null.</returns>
        Contact? ContactGet(string ownerId, string contactUserId);

        /// <summary>
        /// Update a contact (nickname, blocked status).
        /// </summary>
        /// <param name="contact">The contact to update.</param>
        /// <returns>True if successful.</returns>
        bool ContactUpdate(Contact contact);

        #endregion

        #region Standalone Chat Operations

        /// <summary>
        /// Create a direct message (1-to-1) chat room between two users.
        /// </summary>
        /// <param name="userId1">First user ID.</param>
        /// <param name="userId2">Second user ID.</param>
        /// <returns>The chat room or null on error.</returns>
        StandaloneChatRoom? DirectMessageCreate(string userId1, string userId2);

        /// <summary>
        /// Get or create a direct message room between two users.
        /// </summary>
        /// <param name="userId1">First user ID.</param>
        /// <param name="userId2">Second user ID.</param>
        /// <returns>The chat room or null on error.</returns>
        StandaloneChatRoom? DirectMessageGetOrCreate(string userId1, string userId2);

        /// <summary>
        /// Create a group chat room.
        /// </summary>
        /// <param name="creatorUserId">The user creating the group.</param>
        /// <param name="groupName">Name of the group.</param>
        /// <param name="memberUserIds">Initial member user IDs.</param>
        /// <returns>The group chat room or null on error.</returns>
        StandaloneChatRoom? GroupCreate(string creatorUserId, string groupName, IEnumerable<string> memberUserIds);

        /// <summary>
        /// Add a member to a group chat.
        /// </summary>
        /// <param name="roomId">The room ID.</param>
        /// <param name="userId">The user to add.</param>
        /// <returns>True if successful.</returns>
        bool GroupAddMember(string roomId, string userId);

        /// <summary>
        /// Remove a member from a group chat.
        /// </summary>
        /// <param name="roomId">The room ID.</param>
        /// <param name="userId">The user to remove.</param>
        /// <returns>True if successful.</returns>
        bool GroupRemoveMember(string roomId, string userId);

        /// <summary>
        /// Get all standalone chat rooms for a user (DMs and groups).
        /// </summary>
        /// <param name="userId">The user ID.</param>
        /// <returns>List of chat rooms the user is a member of.</returns>
        List<StandaloneChatRoom> StandaloneChatGetRooms(string userId);

        /// <summary>
        /// Get a standalone chat room by ID.
        /// </summary>
        /// <param name="roomId">The room ID.</param>
        /// <returns>The room or null.</returns>
        StandaloneChatRoom? StandaloneChatGetRoom(string roomId);

        #endregion

        #region High-Level Hub Operations

        /// <summary>
        /// Process a user joining a room. Stores system message and returns all data needed for Hub broadcast.
        /// </summary>
        /// <param name="channelName">The channel to join.</param>
        /// <param name="userId">The user's ID.</param>
        /// <param name="displayName">The user's display name.</param>
        /// <param name="connectionId">The SignalR connection ID.</param>
        /// <returns>Result containing history, participants, and user event info.</returns>
        JoinRoomResult ProcessJoinRoom(string channelName, string userId, string displayName, string connectionId);

        /// <summary>
        /// Process a user leaving a room. Stores system message and returns data for Hub broadcast.
        /// </summary>
        /// <param name="channelName">The channel to leave.</param>
        /// <param name="connectionId">The SignalR connection ID.</param>
        /// <returns>Result containing user event info for broadcast.</returns>
        LeaveRoomResult ProcessLeaveRoom(string channelName, string connectionId);

        /// <summary>
        /// Process sending a message. Validates, stores, and returns data for Hub broadcast.
        /// </summary>
        /// <param name="channelName">The channel to send to.</param>
        /// <param name="content">The message content.</param>
        /// <param name="connectionId">The sender's connection ID.</param>
        /// <returns>Result containing message DTO for broadcast.</returns>
        SendMessageResult ProcessSendMessage(string channelName, string content, string connectionId);

        /// <summary>
        /// Get message history formatted for Hub response.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <param name="limit">Maximum messages.</param>
        /// <param name="beforeTimestamp">Get messages before this time.</param>
        /// <returns>History result with message DTOs.</returns>
        HistoryResult GetHistoryForHub(string channelName, int limit = 50, DateTime? beforeTimestamp = null);

        /// <summary>
        /// Get participants formatted for Hub response.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <returns>Participants result with DTOs.</returns>
        ParticipantsResult GetParticipantsForHub(string channelName);

        /// <summary>
        /// Get user event info for typing indicator.
        /// </summary>
        /// <param name="connectionId">The connection ID.</param>
        /// <param name="isTyping">Whether typing.</param>
        /// <returns>User event DTO or null if user not found.</returns>
        UserEventDto? GetTypingEvent(string connectionId, bool isTyping);

        #endregion

        #region Contact Request Operations

        /// <summary>
        /// Send a contact request to another user.
        /// </summary>
        /// <param name="fromUserId">The sender's user ID.</param>
        /// <param name="fromDisplayName">The sender's display name.</param>
        /// <param name="toUserId">The recipient's user ID.</param>
        /// <param name="message">Optional message with the request.</param>
        /// <returns>Result with the created request.</returns>
        SendContactRequestResult ContactRequestSend(string fromUserId, string fromDisplayName, string toUserId, string? message = null);

        /// <summary>
        /// Accept a contact request.
        /// </summary>
        /// <param name="requestId">The request ID.</param>
        /// <param name="acceptingUserDisplayName">Display name of the accepting user.</param>
        /// <returns>Result with updated request and created contacts.</returns>
        ContactRequestResponseResult ContactRequestAccept(string requestId, string acceptingUserDisplayName);

        /// <summary>
        /// Reject a contact request.
        /// </summary>
        /// <param name="requestId">The request ID.</param>
        /// <returns>Result with updated request.</returns>
        ContactRequestResponseResult ContactRequestReject(string requestId);

        /// <summary>
        /// Cancel a sent contact request.
        /// </summary>
        /// <param name="requestId">The request ID.</param>
        /// <param name="userId">The user cancelling (must be sender).</param>
        /// <returns>True if cancelled successfully.</returns>
        bool ContactRequestCancel(string requestId, string userId);

        /// <summary>
        /// Get pending contact requests for a user (received).
        /// </summary>
        /// <param name="userId">The user ID.</param>
        /// <returns>List of pending requests.</returns>
        List<ContactRequest> ContactRequestGetPending(string userId);

        /// <summary>
        /// Get sent contact requests for a user.
        /// </summary>
        /// <param name="userId">The user ID.</param>
        /// <returns>List of sent requests.</returns>
        List<ContactRequest> ContactRequestGetSent(string userId);

        /// <summary>
        /// Get a contact request by ID.
        /// </summary>
        /// <param name="requestId">The request ID.</param>
        /// <returns>The request or null.</returns>
        ContactRequest? ContactRequestGet(string requestId);

        #endregion

        #region Message Permission Operations

        /// <summary>
        /// Check if a user can send messages to another user (DM).
        /// Requires mutual contact (both accepted).
        /// </summary>
        /// <param name="fromUserId">The sender's user ID.</param>
        /// <param name="toUserId">The recipient's user ID.</param>
        /// <returns>Permission result with reason if denied.</returns>
        MessagePermissionResult CanSendDirectMessage(string fromUserId, string toUserId);

        /// <summary>
        /// Check if a user can send messages to a room.
        /// For DM rooms, checks mutual contact status.
        /// </summary>
        /// <param name="userId">The user's ID.</param>
        /// <param name="roomId">The room ID.</param>
        /// <returns>Permission result with reason if denied.</returns>
        MessagePermissionResult CanSendToRoom(string userId, string roomId);

        #endregion

        #region File Operations

        /// <summary>
        /// Register a file upload.
        /// </summary>
        /// <param name="userId">The uploader's user ID.</param>
        /// <param name="fileName">Original filename.</param>
        /// <param name="contentType">MIME type.</param>
        /// <param name="fileSize">Size in bytes.</param>
        /// <param name="storagePath">Where the file is stored.</param>
        /// <param name="downloadUrl">URL to download the file.</param>
        /// <returns>The created file attachment.</returns>
        FileAttachment? FileRegister(string userId, string fileName, string contentType, long fileSize, string storagePath, string downloadUrl);

        /// <summary>
        /// Get a file by ID.
        /// </summary>
        /// <param name="fileId">The file ID.</param>
        /// <returns>The file attachment or null.</returns>
        FileAttachment? FileGet(string fileId);

        /// <summary>
        /// Send a file message to a channel.
        /// </summary>
        /// <param name="channelName">The channel name.</param>
        /// <param name="fileId">The file ID (must be registered first).</param>
        /// <param name="connectionId">The sender's connection ID.</param>
        /// <param name="caption">Optional caption/message with the file.</param>
        /// <returns>Result with message and file DTOs.</returns>
        SendFileMessageResult ProcessSendFileMessage(string channelName, string fileId, string connectionId, string? caption = null);

        #endregion
    }
}
