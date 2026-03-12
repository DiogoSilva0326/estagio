using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.AgoraAPI.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.AgoraAPI.Repository
{
    public class AgoraRepository : IAgoraRepository
    {
        private readonly string _connectionString;

        public AgoraRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<VideoCall>> GetCallsAllAsync()
        {
            var list = new List<VideoCall>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_video_calls_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapCall(reader));
            }

            return list;
        }

        public async Task<VideoCall?> GetCallByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_video_calls_select_details01(@id);";
            cmd.Parameters.AddWithValue("id", id);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapCall(reader);
        }

        public async Task<Guid> InsertCallAsync(VideoCall call)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_video_calls_insert(
    @channel_name,
    @call_name,
    @call_type,
    @group_room_id,
    @initiated_by_user_id,
    @status,
    @started_at,
    @ended_at,
    @duration_seconds,
    @max_participants,
    @recording_url,
    @is_recorded,
    @metadata::jsonb
);";

            cmd.Parameters.AddWithValue("channel_name", (object?)call.ChannelName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("call_name", (object?)call.CallName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("call_type", (object?)call.CallType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("group_room_id", (object?)call.GroupRoomId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("initiated_by_user_id", (object?)call.InitiatedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)call.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("started_at", call.StartedAt);
            cmd.Parameters.AddWithValue("ended_at", (object?)call.EndedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("duration_seconds", (object?)call.DurationSeconds ?? DBNull.Value);
            cmd.Parameters.AddWithValue("max_participants", call.MaxParticipants);
            cmd.Parameters.AddWithValue("recording_url", (object?)call.RecordingUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_recorded", call.IsRecorded);
            cmd.Parameters.AddWithValue("metadata", (object?)call.Metadata ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            if (res == null || res == DBNull.Value) return Guid.Empty;
            return res is Guid guid ? guid : Guid.Parse(res.ToString()!);
        }

        public async Task<int> UpdateCallAsync(VideoCall call)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_video_calls_update(
    @id,
    @channel_name,
    @call_name,
    @call_type,
    @group_room_id,
    @initiated_by_user_id,
    @status,
    @started_at,
    @ended_at,
    @duration_seconds,
    @max_participants,
    @recording_url,
    @is_recorded,
    @metadata::jsonb
);";

            cmd.Parameters.AddWithValue("id", call.Id);
            cmd.Parameters.AddWithValue("channel_name", (object?)call.ChannelName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("call_name", (object?)call.CallName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("call_type", (object?)call.CallType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("group_room_id", (object?)call.GroupRoomId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("initiated_by_user_id", (object?)call.InitiatedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)call.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("started_at", call.StartedAt);
            cmd.Parameters.AddWithValue("ended_at", (object?)call.EndedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("duration_seconds", (object?)call.DurationSeconds ?? DBNull.Value);
            cmd.Parameters.AddWithValue("max_participants", call.MaxParticipants);
            cmd.Parameters.AddWithValue("recording_url", (object?)call.RecordingUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_recorded", call.IsRecorded);
            cmd.Parameters.AddWithValue("metadata", (object?)call.Metadata ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteCallAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_video_calls_delete(@id);";
            cmd.Parameters.AddWithValue("id", id);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<VideoCallParticipant>> GetParticipantsAllAsync()
        {
            var list = new List<VideoCallParticipant>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_video_call_participants_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapParticipant(reader));
            }

            return list;
        }

        public async Task<VideoCallParticipant?> GetParticipantByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_video_call_participants_select_details01(@id);";
            cmd.Parameters.AddWithValue("id", id);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapParticipant(reader);
        }

        public async Task<Guid> InsertParticipantAsync(VideoCallParticipant participant)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_video_call_participants_insert(
    @call_id,
    @user_id,
    @role,
    @joined_at,
    @left_at,
    @duration_seconds,
    @avg_video_quality,
    @avg_audio_quality,
    @had_video,
    @had_audio,
    @had_screen_share,
    @device_type,
    @metadata::jsonb
);";

            cmd.Parameters.AddWithValue("call_id", participant.CallId);
            cmd.Parameters.AddWithValue("user_id", participant.UserId);
            cmd.Parameters.AddWithValue("role", (object?)participant.Role ?? DBNull.Value);
            cmd.Parameters.AddWithValue("joined_at", participant.JoinedAt);
            cmd.Parameters.AddWithValue("left_at", (object?)participant.LeftAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("duration_seconds", (object?)participant.DurationSeconds ?? DBNull.Value);
            cmd.Parameters.AddWithValue("avg_video_quality", (object?)participant.AvgVideoQuality ?? DBNull.Value);
            cmd.Parameters.AddWithValue("avg_audio_quality", (object?)participant.AvgAudioQuality ?? DBNull.Value);
            cmd.Parameters.AddWithValue("had_video", participant.HadVideo);
            cmd.Parameters.AddWithValue("had_audio", participant.HadAudio);
            cmd.Parameters.AddWithValue("had_screen_share", participant.HadScreenShare);
            cmd.Parameters.AddWithValue("device_type", (object?)participant.DeviceType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("metadata", (object?)participant.Metadata ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            if (res == null || res == DBNull.Value) return Guid.Empty;
            return res is Guid guid ? guid : Guid.Parse(res.ToString()!);
        }

        public async Task<int> UpdateParticipantAsync(VideoCallParticipant participant)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_video_call_participants_update(
    @id,
    @call_id,
    @user_id,
    @role,
    @joined_at,
    @left_at,
    @duration_seconds,
    @avg_video_quality,
    @avg_audio_quality,
    @had_video,
    @had_audio,
    @had_screen_share,
    @device_type,
    @metadata::jsonb
);";

            cmd.Parameters.AddWithValue("id", participant.Id);
            cmd.Parameters.AddWithValue("call_id", participant.CallId);
            cmd.Parameters.AddWithValue("user_id", participant.UserId);
            cmd.Parameters.AddWithValue("role", (object?)participant.Role ?? DBNull.Value);
            cmd.Parameters.AddWithValue("joined_at", participant.JoinedAt);
            cmd.Parameters.AddWithValue("left_at", (object?)participant.LeftAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("duration_seconds", (object?)participant.DurationSeconds ?? DBNull.Value);
            cmd.Parameters.AddWithValue("avg_video_quality", (object?)participant.AvgVideoQuality ?? DBNull.Value);
            cmd.Parameters.AddWithValue("avg_audio_quality", (object?)participant.AvgAudioQuality ?? DBNull.Value);
            cmd.Parameters.AddWithValue("had_video", participant.HadVideo);
            cmd.Parameters.AddWithValue("had_audio", participant.HadAudio);
            cmd.Parameters.AddWithValue("had_screen_share", participant.HadScreenShare);
            cmd.Parameters.AddWithValue("device_type", (object?)participant.DeviceType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("metadata", (object?)participant.Metadata ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteParticipantAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_video_call_participants_delete(@id);";
            cmd.Parameters.AddWithValue("id", id);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static VideoCall MapCall(NpgsqlDataReader reader)
        {
            return new VideoCall
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                ChannelName = reader.GetString(reader.GetOrdinal("channel_name")),
                CallName = GetNullableString(reader, "call_name"),
                CallType = reader.GetString(reader.GetOrdinal("call_type")),
                GroupRoomId = GetNullableGuid(reader, "group_room_id"),
                InitiatedByUserId = GetNullableGuid(reader, "initiated_by_user_id"),
                Status = reader.GetString(reader.GetOrdinal("status")),
                StartedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("started_at")),
                EndedAt = GetNullableDateTimeOffset(reader, "ended_at"),
                DurationSeconds = GetNullableInt(reader, "duration_seconds"),
                MaxParticipants = reader.GetInt32(reader.GetOrdinal("max_participants")),
                RecordingUrl = GetNullableString(reader, "recording_url"),
                IsRecorded = reader.GetBoolean(reader.GetOrdinal("is_recorded")),
                Metadata = GetNullableString(reader, "metadata")
            };
        }

        private static VideoCallParticipant MapParticipant(NpgsqlDataReader reader)
        {
            return new VideoCallParticipant
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                CallId = reader.GetGuid(reader.GetOrdinal("call_id")),
                UserId = reader.GetGuid(reader.GetOrdinal("user_id")),
                Role = reader.GetString(reader.GetOrdinal("role")),
                JoinedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("joined_at")),
                LeftAt = GetNullableDateTimeOffset(reader, "left_at"),
                DurationSeconds = GetNullableInt(reader, "duration_seconds"),
                AvgVideoQuality = GetNullableString(reader, "avg_video_quality"),
                AvgAudioQuality = GetNullableString(reader, "avg_audio_quality"),
                HadVideo = reader.GetBoolean(reader.GetOrdinal("had_video")),
                HadAudio = reader.GetBoolean(reader.GetOrdinal("had_audio")),
                HadScreenShare = reader.GetBoolean(reader.GetOrdinal("had_screen_share")),
                DeviceType = GetNullableString(reader, "device_type"),
                Metadata = GetNullableString(reader, "metadata")
            };
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetGuid(idx);
        }

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetInt32(idx);
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetString(idx);
        }

        private static DateTimeOffset? GetNullableDateTimeOffset(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetFieldValue<DateTimeOffset>(idx);
        }
    }
}
