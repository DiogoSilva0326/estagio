using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;
using Npgsql;
using NpgsqlTypes;

namespace ConfidantPostgreSQL.Modules.Student.Repository
{
    public class StudentEvaluationsRepository : IStudentEvaluationsRepository
    {
        private readonly string _connectionString;

        public StudentEvaluationsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IReadOnlyList<SubmittedEvaluationDto>> GetSubmittedAsync(Guid studentUserId)
        {
            var list = new List<SubmittedEvaluationDto>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT * FROM public.usp_student_evaluations_submitted_select01(@p_student_user_id);";

            cmd.Parameters.AddWithValue("p_student_user_id", studentUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new SubmittedEvaluationDto
                {
                    LessonFeedbackId = reader.GetGuid(reader.GetOrdinal("id_lesson_feedback")),
                    LessonId = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                    ProfessorId = reader.IsDBNull(reader.GetOrdinal("id_professor"))
                        ? null
                        : reader.GetGuid(reader.GetOrdinal("id_professor")),
                    ProfessorName = reader.IsDBNull(reader.GetOrdinal("professor_name"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("professor_name")),
                    Subject = reader.IsDBNull(reader.GetOrdinal("subject"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("subject")),
                    LessonStart = reader.IsDBNull(reader.GetOrdinal("scheduled_start"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("scheduled_start")),
                    LessonEnd = reader.IsDBNull(reader.GetOrdinal("scheduled_end"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("scheduled_end")),
                    Rating = reader.IsDBNull(reader.GetOrdinal("rating"))
                        ? null
                        : reader.GetInt32(reader.GetOrdinal("rating")),
                    Comments = reader.IsDBNull(reader.GetOrdinal("comments"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("comments")),
                    CreatedAt = reader.IsDBNull(reader.GetOrdinal("created_at"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("created_at"))
                });
            }

            return list;
        }

        public async Task<IReadOnlyList<PendingEvaluationDto>> GetPendingLatestPerProfessorAsync(Guid studentUserId)
        {
            var list = new List<PendingEvaluationDto>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT * FROM public.usp_student_evaluations_pending_latest_select01(@p_student_user_id);";

            cmd.Parameters.AddWithValue("p_student_user_id", studentUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new PendingEvaluationDto
                {
                    LessonId = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                    ProfessorId = reader.GetGuid(reader.GetOrdinal("id_professor")),
                    ProfessorName = reader.GetString(reader.GetOrdinal("professor_name")),
                    Subject = reader.IsDBNull(reader.GetOrdinal("subject"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("subject")),
                    LessonStart = reader.IsDBNull(reader.GetOrdinal("scheduled_start"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("scheduled_start")),
                    LessonEnd = reader.IsDBNull(reader.GetOrdinal("scheduled_end"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("scheduled_end"))
                });
            }

            return list;
        }

        public async Task<PendingEvaluationDto?> GetPendingByLessonIdAsync(Guid studentUserId, Guid lessonId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT * FROM public.usp_student_evaluations_pending_by_lesson_select01(@p_student_user_id, @p_lesson_id);";

            cmd.Parameters.AddWithValue("p_student_user_id", studentUserId);
            cmd.Parameters.AddWithValue("p_lesson_id", lessonId);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new PendingEvaluationDto
            {
                LessonId = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                ProfessorId = reader.GetGuid(reader.GetOrdinal("id_professor")),
                ProfessorName = reader.GetString(reader.GetOrdinal("professor_name")),
                Subject = reader.IsDBNull(reader.GetOrdinal("subject"))
                    ? null
                    : reader.GetString(reader.GetOrdinal("subject")),
                LessonStart = reader.IsDBNull(reader.GetOrdinal("scheduled_start"))
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("scheduled_start")),
                LessonEnd = reader.IsDBNull(reader.GetOrdinal("scheduled_end"))
                    ? null
                    : reader.GetDateTime(reader.GetOrdinal("scheduled_end"))
            };
        }

        public async Task<Guid> InsertLessonFeedbackAsync(Guid studentUserId, Guid lessonId, int rating, string? comments)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lesson_feedback_insert(@id_lesson, @id_user, @is_valid, @rating, @comments, @created_at);";

            cmd.Parameters.AddWithValue("id_lesson", lessonId);
            cmd.Parameters.AddWithValue("id_user", studentUserId);
            cmd.Parameters.AddWithValue("is_valid", true);
            cmd.Parameters.AddWithValue("rating", rating);
            cmd.Parameters.AddWithValue("comments", (object?)comments ?? DBNull.Value);
            cmd.Parameters.Add("created_at", NpgsqlDbType.Timestamp).Value = DateTime.SpecifyKind(DateTime.UtcNow, DateTimeKind.Unspecified);

            try
            {
                var res = await cmd.ExecuteScalarAsync();
                return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
            }
            catch (PostgresException ex) when (ex.SqlState == "23505")
            {
                return Guid.Empty;
            }
        }
    }
}
