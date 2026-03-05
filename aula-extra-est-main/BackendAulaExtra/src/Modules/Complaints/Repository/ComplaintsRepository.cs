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
                    ComplaintMessage = GetNullableString(reader, "complaint_message"),
                    Status = GetNullableString(reader, "status"),
                    IsRead = GetBoolDefaultFalse(reader, "is_read"),
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
                ComplaintMessage = GetNullableString(reader, "complaint_message"),
                Status = GetNullableString(reader, "status"),
                IsRead = GetBoolDefaultFalse(reader, "is_read"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at"),
            };
        }

        public async Task<Guid> InsertComplaintAsync(Complaint complaint)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_complaints_insert(@sender_user_id, @receiver_user_id, @complaint_type, @complaint_message, @status, @is_read, @created_at, @updated_at);";

            cmd.Parameters.AddWithValue("sender_user_id", complaint.SenderUserId);
            cmd.Parameters.AddWithValue("receiver_user_id", (object?)complaint.ReceiverUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_type", (object?)complaint.ComplaintType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_message", (object?)complaint.ComplaintMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)complaint.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_read", complaint.IsRead);
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
            cmd.CommandText = "SELECT public.usp_complaints_update(@id_complaint, @sender_user_id, @receiver_user_id, @complaint_type, @complaint_message, @status, @is_read);";

            cmd.Parameters.AddWithValue("id_complaint", complaint.IdComplaint);
            cmd.Parameters.AddWithValue("sender_user_id", complaint.SenderUserId);
            cmd.Parameters.AddWithValue("receiver_user_id", (object?)complaint.ReceiverUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_type", (object?)complaint.ComplaintType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("complaint_message", (object?)complaint.ComplaintMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)complaint.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_read", complaint.IsRead);

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
