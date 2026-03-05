using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Professors.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Professors.Repository
{
    public class ProfessorsRepository : IProfessorsRepository
    {
        private readonly string _connectionString;

        public ProfessorsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Professor>> GetProfessorsAllAsync()
        {
            var list = new List<Professor>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professors_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessor(reader));
            }
            return list;
        }

        public async Task<Professor?> GetProfessorByIdAsync(Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professors_select_details01(@id_professor);";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessor(reader);
        }

        public async Task<Professor?> GetProfessorByUserIdAsync(Guid idUser)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professors_select_by_user01(@id_user);";
            cmd.Parameters.AddWithValue("id_user", idUser);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessor(reader);
        }

        public async Task<Guid> InsertProfessorAsync(Professor professor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_professors_insert(@id_user, @current_school, @years_experience, @photo, @biography, @presentation_video_url, @vat, @iban, @iban_document_url, @is_verified_iban, @is_active, @is_verified, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("id_user", professor.IdUser);
            cmd.Parameters.AddWithValue("current_school", (object?)professor.CurrentSchool ?? DBNull.Value);
            cmd.Parameters.AddWithValue("years_experience", (object?)professor.YearsExperience ?? DBNull.Value);
            cmd.Parameters.AddWithValue("photo", (object?)professor.Photo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("biography", (object?)professor.Biography ?? DBNull.Value);
            cmd.Parameters.AddWithValue("presentation_video_url", (object?)professor.PresentationVideoUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("vat", (object?)professor.Vat ?? DBNull.Value);
            cmd.Parameters.AddWithValue("iban", (object?)professor.Iban ?? DBNull.Value);
            cmd.Parameters.AddWithValue("iban_document_url", (object?)professor.IbanDocumentUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_verified_iban", (object?)professor.IsVerifiedIban ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", (object?)professor.IsActive ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_verified", (object?)professor.IsVerified ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)professor.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)professor.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateProfessorAsync(Professor professor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professors_update(@id_professor, @id_user, @current_school, @years_experience, @photo, @biography, @presentation_video_url, @vat, @iban, @iban_document_url, @is_verified_iban, @is_active, @is_verified);";
            cmd.Parameters.AddWithValue("id_professor", professor.IdProfessor);
            cmd.Parameters.AddWithValue("id_user", professor.IdUser);
            cmd.Parameters.AddWithValue("current_school", (object?)professor.CurrentSchool ?? DBNull.Value);
            cmd.Parameters.AddWithValue("years_experience", (object?)professor.YearsExperience ?? DBNull.Value);
            cmd.Parameters.AddWithValue("photo", (object?)professor.Photo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("biography", (object?)professor.Biography ?? DBNull.Value);
            cmd.Parameters.AddWithValue("presentation_video_url", (object?)professor.PresentationVideoUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("vat", (object?)professor.Vat ?? DBNull.Value);
            cmd.Parameters.AddWithValue("iban", (object?)professor.Iban ?? DBNull.Value);
            cmd.Parameters.AddWithValue("iban_document_url", (object?)professor.IbanDocumentUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_verified_iban", (object?)professor.IsVerifiedIban ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", (object?)professor.IsActive ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_verified", (object?)professor.IsVerified ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteProfessorAsync(Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professors_delete(@id_professor);";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ProfessorFeedback>> GetProfessorFeedbackAllAsync()
        {
            var list = new List<ProfessorFeedback>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professor_feedback_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessorFeedback(reader));
            }
            return list;
        }

        public async Task<ProfessorFeedback?> GetProfessorFeedbackByIdAsync(Guid idProfessorFeedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professor_feedback_select_details01(@id_professor_feedback);";
            cmd.Parameters.AddWithValue("id_professor_feedback", idProfessorFeedback);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessorFeedback(reader);
        }

        public async Task<Guid> InsertProfessorFeedbackAsync(ProfessorFeedback feedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_professor_feedback_insert(@id_professor, @id_user, @is_valid, @rating, @comments, @created_at);";
            cmd.Parameters.AddWithValue("id_professor", feedback.IdProfessor);
            cmd.Parameters.AddWithValue("id_user", feedback.IdUser);
            cmd.Parameters.AddWithValue("is_valid", (object?)feedback.IsValid ?? DBNull.Value);
            cmd.Parameters.AddWithValue("rating", (object?)feedback.Rating ?? DBNull.Value);
            cmd.Parameters.AddWithValue("comments", (object?)feedback.Comments ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)feedback.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateProfessorFeedbackAsync(ProfessorFeedback feedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_feedback_update(@id_professor_feedback, @id_professor, @id_user, @is_valid, @rating, @comments, @created_at);";
            cmd.Parameters.AddWithValue("id_professor_feedback", feedback.IdProfessorFeedback);
            cmd.Parameters.AddWithValue("id_professor", feedback.IdProfessor);
            cmd.Parameters.AddWithValue("id_user", feedback.IdUser);
            cmd.Parameters.AddWithValue("is_valid", (object?)feedback.IsValid ?? DBNull.Value);
            cmd.Parameters.AddWithValue("rating", (object?)feedback.Rating ?? DBNull.Value);
            cmd.Parameters.AddWithValue("comments", (object?)feedback.Comments ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)feedback.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteProfessorFeedbackAsync(Guid idProfessorFeedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_feedback_delete(@id_professor_feedback);";
            cmd.Parameters.AddWithValue("id_professor_feedback", idProfessorFeedback);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Certificate>> GetCertificatesAllAsync()
        {
            var list = new List<Certificate>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_certificates_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapCertificate(reader));
            }
            return list;
        }

        public async Task<Certificate?> GetCertificateByIdAsync(Guid idCertificate)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_certificates_select_details01(@id_certificate);";
            cmd.Parameters.AddWithValue("id_certificate", idCertificate);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapCertificate(reader);
        }

        public async Task<Guid> InsertCertificateAsync(Certificate cert)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_certificates_insert(@id_professor, @name, @file_url, @verified, @verified_by_user_id, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("id_professor", cert.IdProfessor);
            cmd.Parameters.AddWithValue("name", (object?)cert.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("file_url", (object?)cert.FileUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("verified", (object?)cert.Verified ?? DBNull.Value);
            cmd.Parameters.AddWithValue("verified_by_user_id", (object?)cert.VerifiedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)cert.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)cert.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateCertificateAsync(Certificate cert)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_certificates_update(@id_certificate, @id_professor, @name, @file_url, @verified, @verified_by_user_id);";
            cmd.Parameters.AddWithValue("id_certificate", cert.IdCertificate);
            cmd.Parameters.AddWithValue("id_professor", cert.IdProfessor);
            cmd.Parameters.AddWithValue("name", (object?)cert.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("file_url", (object?)cert.FileUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("verified", (object?)cert.Verified ?? DBNull.Value);
            cmd.Parameters.AddWithValue("verified_by_user_id", (object?)cert.VerifiedByUserId ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteCertificateAsync(Guid idCertificate)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_certificates_delete(@id_certificate);";
            cmd.Parameters.AddWithValue("id_certificate", idCertificate);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteCertificatesByProfessorIdAsync(Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "DELETE FROM public.certificates WHERE id_professor = @id_professor;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            return await cmd.ExecuteNonQueryAsync();
        }

        public async Task<IEnumerable<ProfessorRoom>> GetProfessorRoomsAllAsync()
        {
            var list = new List<ProfessorRoom>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professor_rooms_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessorRoom(reader));
            }
            return list;
        }

        public async Task<ProfessorRoom?> GetProfessorRoomByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professor_rooms_select_details01(@id);";
            cmd.Parameters.AddWithValue("id", id);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessorRoom(reader);
        }

        public async Task<Guid> InsertProfessorRoomAsync(ProfessorRoom room)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_professor_rooms_insert(@professor_id, @professor_name, @room_name, @description, @is_active);";
            cmd.Parameters.AddWithValue("professor_id", room.ProfessorId);
            cmd.Parameters.AddWithValue("professor_name", room.ProfessorName);
            cmd.Parameters.AddWithValue("room_name", room.RoomName);
            cmd.Parameters.AddWithValue("description", (object?)room.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", room.IsActive);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateProfessorRoomAsync(ProfessorRoom room)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_rooms_update(@id, @professor_id, @professor_name, @room_name, @description, @is_active);";
            cmd.Parameters.AddWithValue("id", room.Id);
            cmd.Parameters.AddWithValue("professor_id", room.ProfessorId);
            cmd.Parameters.AddWithValue("professor_name", room.ProfessorName);
            cmd.Parameters.AddWithValue("room_name", room.RoomName);
            cmd.Parameters.AddWithValue("description", (object?)room.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", room.IsActive);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteProfessorRoomAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_rooms_delete(@id);";
            cmd.Parameters.AddWithValue("id", id);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static Professor MapProfessor(NpgsqlDataReader reader)
        {
            return new Professor
            {
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                CurrentSchool = GetNullableString(reader, "current_school"),
                YearsExperience = GetNullableInt(reader, "years_experience"),
                Photo = GetNullableString(reader, "photo"),
                Biography = GetNullableString(reader, "biography"),
                PresentationVideoUrl = GetNullableString(reader, "presentation_video_url"),
                Vat = GetNullableString(reader, "vat"),
                Iban = GetNullableString(reader, "iban"),
                IbanDocumentUrl = GetNullableString(reader, "iban_document_url"),
                IsVerifiedIban = GetNullableBool(reader, "is_verified_iban"),
                IsActive = GetNullableBool(reader, "is_active"),
                IsVerified = GetNullableBool(reader, "is_verified"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        private static ProfessorFeedback MapProfessorFeedback(NpgsqlDataReader reader)
        {
            return new ProfessorFeedback
            {
                IdProfessorFeedback = reader.GetGuid(reader.GetOrdinal("id_professor_feedback")),
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                IsValid = GetNullableBool(reader, "is_valid"),
                Rating = GetNullableInt(reader, "rating"),
                Comments = GetNullableString(reader, "comments"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static Certificate MapCertificate(NpgsqlDataReader reader)
        {
            return new Certificate
            {
                IdCertificate = reader.GetGuid(reader.GetOrdinal("id_certificate")),
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                Name = GetNullableString(reader, "name"),
                FileUrl = GetNullableString(reader, "file_url"),
                Verified = GetNullableBool(reader, "verified"),
                VerifiedByUserId = GetNullableGuid(reader, "verified_by_user_id"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        private static ProfessorRoom MapProfessorRoom(NpgsqlDataReader reader)
        {
            return new ProfessorRoom
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                ProfessorId = reader.GetGuid(reader.GetOrdinal("professor_id")),
                ProfessorName = reader.GetString(reader.GetOrdinal("professor_name")),
                RoomName = reader.GetString(reader.GetOrdinal("room_name")),
                Description = GetNullableString(reader, "description"),
                IsActive = reader.GetBoolean(reader.GetOrdinal("is_active")),
                CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
            };
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

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetInt32(idx);
        }

        private static bool? GetNullableBool(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetBoolean(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try { return reader.GetFieldValue<DateTime>(idx); } catch { return null; }
        }
    }
}
