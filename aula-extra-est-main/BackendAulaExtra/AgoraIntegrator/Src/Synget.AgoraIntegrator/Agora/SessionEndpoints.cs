using Synget.AgoraIntegrator.Models;

namespace Synget.AgoraIntegrator.Agora
{
    /// <summary>
    /// Endpoints for session (channel/room) management.
    /// Handles session lifecycle and user tracking.
    /// </summary>
    public class SessionEndpoints
    {
        private readonly AgoraClient _client;
        private readonly Dictionary<string, AgoraSession> _sessions = new();
        private readonly object _lock = new();

        public SessionEndpoints(AgoraClient client)
        {
            _client = client ?? throw new ArgumentNullException(nameof(client));
        }

        /// <summary>
        /// Create a new session.
        /// </summary>
        /// <param name="channelName">Channel name for the session.</param>
        /// <returns>Created session.</returns>
        public AgoraSession Create(string channelName)
        {
            if (string.IsNullOrWhiteSpace(channelName))
                throw new ArgumentException("Channel name is required.", nameof(channelName));

            lock (_lock)
            {
                if (_sessions.TryGetValue(channelName, out var existing) && existing.IsActive)
                {
                    return existing;
                }

                var session = new AgoraSession
                {
                    SessionId = Guid.NewGuid().ToString("N"),
                    ChannelName = channelName,
                    Status = AgoraSessionStatus.Idle,
                    CreatedAt = DateTime.UtcNow
                };

                _sessions[channelName] = session;
                return session;
            }
        }

        /// <summary>
        /// Get a session by channel name.
        /// </summary>
        /// <param name="channelName">Channel name.</param>
        /// <returns>Session or null if not found.</returns>
        public AgoraSession? Get(string channelName)
        {
            if (string.IsNullOrWhiteSpace(channelName))
                return null;

            lock (_lock)
            {
                return _sessions.TryGetValue(channelName, out var session) ? session : null;
            }
        }

        /// <summary>
        /// End a session.
        /// </summary>
        /// <param name="channelName">Channel name.</param>
        /// <returns>True on success.</returns>
        public bool End(string channelName)
        {
            if (string.IsNullOrWhiteSpace(channelName))
                return false;

            lock (_lock)
            {
                if (!_sessions.TryGetValue(channelName, out var session))
                    return false;

                session.Status = AgoraSessionStatus.Disconnected;
                session.EndedAt = DateTime.UtcNow;
                return true;
            }
        }

        /// <summary>
        /// Add a user to a session.
        /// </summary>
        /// <param name="channelName">Channel name.</param>
        /// <param name="userId">User ID to add.</param>
        /// <returns>True on success.</returns>
        public bool UserJoin(string channelName, string userId, string? displayName = null)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
                return false;

            lock (_lock)
            {
                if (!_sessions.TryGetValue(channelName, out var session))
                {
                    session = Create(channelName);
                }

                if (!session.Users.Any(u => string.Equals(u.UserId, userId, StringComparison.OrdinalIgnoreCase)))
                {
                    session.Users.Add(new AgoraSessionUser
                    {
                        UserId = userId,
                        DisplayName = displayName,
                        IsAudioMuted = false,
                        IsVideoMuted = false,
                        JoinedAt = DateTime.UtcNow
                    });
                    session.TotalUniqueUsers++;
                }

                if (session.Users.Count > session.PeakUserCount)
                {
                    session.PeakUserCount = session.Users.Count;
                }

                if (session.Status == AgoraSessionStatus.Idle)
                {
                    session.Status = AgoraSessionStatus.Connected;
                    session.StartedAt = DateTime.UtcNow;
                }

                return true;
            }
        }

        /// <summary>
        /// Remove a user from a session.
        /// </summary>
        /// <param name="channelName">Channel name.</param>
        /// <param name="userId">User ID to remove.</param>
        /// <returns>True on success.</returns>
        public bool UserLeave(string channelName, string userId)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
                return false;

            lock (_lock)
            {
                if (!_sessions.TryGetValue(channelName, out var session))
                    return false;

                session.Users.RemoveAll(u => string.Equals(u.UserId, userId, StringComparison.OrdinalIgnoreCase));

                // End session if no users left
                if (session.Users.Count == 0)
                {
                    session.Status = AgoraSessionStatus.Disconnected;
                    session.EndedAt = DateTime.UtcNow;
                }

                return true;
            }
        }

        /// <summary>
        /// Set a participant's audio mute state.
        /// </summary>
        public bool SetUserAudioMuted(string channelName, string userId, bool muted)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
                return false;

            lock (_lock)
            {
                if (!_sessions.TryGetValue(channelName, out var session))
                    return false;

                var user = session.Users.FirstOrDefault(u => string.Equals(u.UserId, userId, StringComparison.OrdinalIgnoreCase));
                if (user == null) return false;
                user.IsAudioMuted = muted;
                return true;
            }
        }

        /// <summary>
        /// Set a participant's video mute state.
        /// </summary>
        public bool SetUserVideoMuted(string channelName, string userId, bool muted)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
                return false;

            lock (_lock)
            {
                if (!_sessions.TryGetValue(channelName, out var session))
                    return false;

                var user = session.Users.FirstOrDefault(u => string.Equals(u.UserId, userId, StringComparison.OrdinalIgnoreCase));
                if (user == null) return false;
                user.IsVideoMuted = muted;
                return true;
            }
        }

        /// <summary>
        /// Get participant info for a session.
        /// </summary>
        public AgoraSessionUser? GetUser(string channelName, string userId)
        {
            if (string.IsNullOrWhiteSpace(channelName) || string.IsNullOrWhiteSpace(userId))
                return null;

            lock (_lock)
            {
                if (!_sessions.TryGetValue(channelName, out var session))
                    return null;

                return session.Users.FirstOrDefault(u => string.Equals(u.UserId, userId, StringComparison.OrdinalIgnoreCase));
            }
        }

        /// <summary>
        /// Get all sessions.
        /// </summary>
        /// <returns>List of all sessions.</returns>
        public List<AgoraSession> GetAll()
        {
            lock (_lock)
            {
                return _sessions.Values.ToList();
            }
        }

        /// <summary>
        /// Get all active sessions.
        /// </summary>
        /// <returns>List of active sessions.</returns>
        public List<AgoraSession> GetActive()
        {
            lock (_lock)
            {
                return _sessions.Values.Where(s => s.IsActive).ToList();
            }
        }

        /// <summary>
        /// Clear all sessions.
        /// </summary>
        public void Clear()
        {
            lock (_lock)
            {
                _sessions.Clear();
            }
        }
    }
}
