using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Complaints.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Complaints.Repository
{
    public class ComplaintsRepository : IComplaintsRepository
    {
        private readonly string _connectionString;

        public ComplaintsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Complaint>> GetComplaintsAllAsync()
        {
            var list = new List<Complaint>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_complaints_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Complaint
                {
                    IdComplaint = reader.GetGuid(reader.GetOrdinal("id_complaint")),
                    SenderUserId = reader.GetGuid(reader.GetOrdinal("sender_user_id")),
                    ReceiverUserId = GetNullableGuid(reader, "receiver_user_id"),
                    ComplaintType = GetNullableString(reader, "complaint_type"),
                    ComplaintSubject = GetNullableStringIfExists(reader, "complaint_subject"),
                    ComplaintMessage = GetNullableString(reader, "complaint_message"),
                    Status = GetNullableString(reader, "status"),
                    IsRead = GetBoolDefaultFalse(reader, "is_read"),
                    SenderDisplayName = GetNullableStringIfExists(reader, "sender_display_name"),
                    ReceiverDisplayName = GetNullableStringIfExists(reader, "receiver_display_name"),
                    SenderRole = GetNullableStringIfExists(reader, "sender_role"),
                    ReceiverRole = GetNullableStringIfExists(reader, "receiver_role"),
                    RelationshipContext = GetNullableStringIfExists(reader, "relationship_context"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at"),
                });
            }

            return list;
        }

        public async Task<Complaint?> GetComplaintByIdAsync(Guid idComplaint)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_complaints_select_details01(@id_complaint);";
            cmd.Parameters.AddWithValue("id_complaint", idComplaint);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new Complaint
            {
                IdComplaint = reader.GetGuid(reader.GetOrdinal("id_complaint")),
                SenderUserId = reader.GetGuid(reader.GetOrdinal("sender_user_id")),
                ReceiverUserId = GetNullableGuid(reader, "receiver_user_id"),
                ComplaintType = GetNullableString(reader, "complaint_type"),
                ComplaintSubject = GetNullableStringIfExists(reader, "complaint_subject"),
                ComplaintMessage = GetNullableString(reader, "complaint_message"),
                Status = GetNullableString(reader, "status"),
                IsRead = GetBoolDefaultFalse(reader, "is_read"),
                SenderDisplayName = GetNullableStringIfExists(reader, "sender_display_name"),
                ReceiverDisplayName = GetNullableStringIfExists(reader, "receiver_display_name"),
                SenderRole = GetNullableStringIfExists(reader, "sender_role"),
                ReceiverRole = GetNullableStringIfExists(reader, "receiver_role"),
                RelationshipContext = GetNullableStringIfExists(reader, "relationship_context"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at"),
            };
        }

        public async Task<Guid> InsertComplaintAsync(Complaint complaint)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_complaints_insert(
                CAST(@sender_user_id AS uuid),
                CAST(@receiver_user_id AS uuid),
                CAST(@complaint_type AS varchar(100)),
                CAST(@complaint_subject AS varchar(160)),
                CAST(@complaint_message AS varchar(1000)),
                CAST(@status AS varchar(30)),
                @is_read,
                CAST(@sender_display_name AS varchar(160)),
                CAST(@receiver_display_name AS varchar(160)),
                CAST(@sender_role AS varchar(30)),
                CAST(@receiver_role AS varchar(30)),
                CAST(@relationship_context AS varchar(30)),
                CAST(@created_at AS timestamp),
                CAST(@updated_at AS timestamp));";

            cmd.Parameters.AddWithValue("sender_user_id", complaint.SenderUserId);
            cmd.Parameters.AddWithValue("receiver_user_id", (object?)complaint.ReceiverUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_type", (object?)complaint.ComplaintType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_subject", (object?)complaint.ComplaintSubject ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_message", (object?)complaint.ComplaintMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)complaint.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_read", complaint.IsRead);
            cmd.Parameters.AddWithValue("sender_display_name", (object?)complaint.SenderDisplayName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("receiver_display_name", (object?)complaint.ReceiverDisplayName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("sender_role", (object?)complaint.SenderRole ?? DBNull.Value);
            cmd.Parameters.AddWithValue("receiver_role", (object?)complaint.ReceiverRole ?? DBNull.Value);
            cmd.Parameters.AddWithValue("relationship_context", (object?)complaint.RelationshipContext ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)complaint.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)complaint.UpdatedAt ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<Guid> InsertRelatedUserComplaintAsync(Complaint complaint)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                INSERT INTO public.complaints (
                    sender_user_id,
                    receiver_user_id,
                    complaint_type,
                    complaint_subject,
                    complaint_message,
                    status,
                    is_read,
                    sender_display_name,
                    receiver_display_name,
                    sender_role,
                    receiver_role,
                    relationship_context,
                    created_at,
                    updated_at
                )
                VALUES (
                    CAST(@sender_user_id AS uuid),
                    CAST(@receiver_user_id AS uuid),
                    CAST(@complaint_type AS varchar(100)),
                    CAST(@complaint_subject AS varchar(160)),
                    CAST(@complaint_message AS varchar(1000)),
                    CAST(@status AS varchar(30)),
                    @is_read,
                    CAST(@sender_display_name AS varchar(160)),
                    CAST(@receiver_display_name AS varchar(160)),
                    CAST(@sender_role AS varchar(30)),
                    CAST(@receiver_role AS varchar(30)),
                    CAST(@relationship_context AS varchar(30)),
                    CAST(@created_at AS timestamp),
                    CAST(@updated_at AS timestamp)
                )
                RETURNING id_complaint;";

            cmd.Parameters.AddWithValue("sender_user_id", complaint.SenderUserId);
            cmd.Parameters.AddWithValue("receiver_user_id", (object?)complaint.ReceiverUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_type", (object?)complaint.ComplaintType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_subject", (object?)complaint.ComplaintSubject ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_message", (object?)complaint.ComplaintMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)complaint.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_read", complaint.IsRead);
            cmd.Parameters.AddWithValue("sender_display_name", (object?)complaint.SenderDisplayName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("receiver_display_name", (object?)complaint.ReceiverDisplayName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("sender_role", (object?)complaint.SenderRole ?? DBNull.Value);
            cmd.Parameters.AddWithValue("receiver_role", (object?)complaint.ReceiverRole ?? DBNull.Value);
            cmd.Parameters.AddWithValue("relationship_context", (object?)complaint.RelationshipContext ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)complaint.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)complaint.UpdatedAt ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateComplaintAsync(Complaint complaint)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_complaints_update(
                CAST(@id_complaint AS uuid),
                CAST(@sender_user_id AS uuid),
                CAST(@receiver_user_id AS uuid),
                CAST(@complaint_type AS varchar(100)),
                CAST(@complaint_subject AS varchar(160)),
                CAST(@complaint_message AS varchar(1000)),
                CAST(@status AS varchar(30)),
                @is_read,
                CAST(@sender_display_name AS varchar(160)),
                CAST(@receiver_display_name AS varchar(160)),
                CAST(@sender_role AS varchar(30)),
                CAST(@receiver_role AS varchar(30)),
                CAST(@relationship_context AS varchar(30)));";

            cmd.Parameters.AddWithValue("id_complaint", complaint.IdComplaint);
            cmd.Parameters.AddWithValue("sender_user_id", complaint.SenderUserId);
            cmd.Parameters.AddWithValue("receiver_user_id", (object?)complaint.ReceiverUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_type", (object?)complaint.ComplaintType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_subject", (object?)complaint.ComplaintSubject ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_message", (object?)complaint.ComplaintMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)complaint.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_read", complaint.IsRead);
            cmd.Parameters.AddWithValue("sender_display_name", (object?)complaint.SenderDisplayName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("receiver_display_name", (object?)complaint.ReceiverDisplayName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("sender_role", (object?)complaint.SenderRole ?? DBNull.Value);
            cmd.Parameters.AddWithValue("receiver_role", (object?)complaint.ReceiverRole ?? DBNull.Value);
            cmd.Parameters.AddWithValue("relationship_context", (object?)complaint.RelationshipContext ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteComplaintAsync(Guid idComplaint)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_complaints_delete(@id_complaint);";
            cmd.Parameters.AddWithValue("id_complaint", idComplaint);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ComplaintResolution>> GetComplaintResolutionsAllAsync()
        {
            var list = new List<ComplaintResolution>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_complaint_resolutions_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new ComplaintResolution
                {
                    IdComplaintResolution = reader.GetGuid(reader.GetOrdinal("id_complaint_resolution")),
                    ComplaintId = reader.GetGuid(reader.GetOrdinal("complaint_id")),
                    AdminUserId = reader.GetGuid(reader.GetOrdinal("admin_user_id")),
                    ResolutionStatus = GetNullableString(reader, "resolution_status"),
                    ResolutionNotes = GetNullableString(reader, "resolution_notes"),
                    ResolvedAt = GetNullableDateTime(reader, "resolved_at"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }

            return list;
        }

        public async Task<ComplaintResolution?> GetComplaintResolutionByIdAsync(Guid idComplaintResolution)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_complaint_resolutions_select_details01(@id_complaint_resolution);";
            cmd.Parameters.AddWithValue("id_complaint_resolution", idComplaintResolution);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new ComplaintResolution
            {
                IdComplaintResolution = reader.GetGuid(reader.GetOrdinal("id_complaint_resolution")),
                ComplaintId = reader.GetGuid(reader.GetOrdinal("complaint_id")),
                AdminUserId = reader.GetGuid(reader.GetOrdinal("admin_user_id")),
                ResolutionStatus = GetNullableString(reader, "resolution_status"),
                ResolutionNotes = GetNullableString(reader, "resolution_notes"),
                ResolvedAt = GetNullableDateTime(reader, "resolved_at"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertComplaintResolutionAsync(ComplaintResolution resolution)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_complaint_resolutions_insert(@complaint_id, @admin_user_id, @resolution_status, @resolution_notes, @resolved_at, @created_at, @updated_at);";

            cmd.Parameters.AddWithValue("complaint_id", resolution.ComplaintId);
            cmd.Parameters.AddWithValue("admin_user_id", resolution.AdminUserId);
            cmd.Parameters.AddWithValue("resolution_status", (object?)resolution.ResolutionStatus ?? DBNull.Value);
            cmd.Parameters.AddWithValue("resolution_notes", (object?)resolution.ResolutionNotes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("resolved_at", (object?)resolution.ResolvedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)resolution.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)resolution.UpdatedAt ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateComplaintResolutionAsync(ComplaintResolution resolution)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_complaint_resolutions_update(@id_complaint_resolution, @complaint_id, @admin_user_id, @resolution_status, @resolution_notes, @resolved_at);";

            cmd.Parameters.AddWithValue("id_complaint_resolution", resolution.IdComplaintResolution);
            cmd.Parameters.AddWithValue("complaint_id", resolution.ComplaintId);
            cmd.Parameters.AddWithValue("admin_user_id", resolution.AdminUserId);
            cmd.Parameters.AddWithValue("resolution_status", (object?)resolution.ResolutionStatus ?? DBNull.Value);
            cmd.Parameters.AddWithValue("resolution_notes", (object?)resolution.ResolutionNotes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("resolved_at", (object?)resolution.ResolvedAt ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteComplaintResolutionAsync(Guid idComplaintResolution)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_complaint_resolutions_delete(@id_complaint_resolution);";
            cmd.Parameters.AddWithValue("id_complaint_resolution", idComplaintResolution);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetString(idx);
        }

        private static string? GetNullableStringIfExists(NpgsqlDataReader reader, string column)
        {
            for (var index = 0; index < reader.FieldCount; index++)
            {
                if (!string.Equals(reader.GetName(index), column, StringComparison.OrdinalIgnoreCase))
                {
                    continue;
                }

                return reader.IsDBNull(index) ? null : reader.GetString(index);
            }

            return null;
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetGuid(idx);
        }

        private static bool GetBoolDefaultFalse(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? false : reader.GetBoolean(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try { return reader.GetFieldValue<DateTime>(idx); } catch { return null; }
        }
    }
}
