using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;
using Npgsql;
using NpgsqlTypes;

namespace ConfidantPostgreSQL.Modules.Student.Repository
{
    public class StudentProfessorEvaluationsRepository : IStudentProfessorEvaluationsRepository
    {
        private readonly string _connectionString;

        public StudentProfessorEvaluationsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IReadOnlyList<SubmittedProfessorEvaluationDto>> GetSubmittedAsync(Guid studentUserId)
        {
            var list = new List<SubmittedProfessorEvaluationDto>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_student_professor_evaluations_submitted_select01(@p_student_user_id);";
            cmd.Parameters.AddWithValue("p_student_user_id", studentUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new SubmittedProfessorEvaluationDto
                {
                    ProfessorFeedbackId = reader.GetGuid(reader.GetOrdinal("id_professor_feedback")),
                    ProfessorId = reader.GetGuid(reader.GetOrdinal("id_professor")),
                    ProfessorName = reader.GetString(reader.GetOrdinal("professor_name")),
                    Rating = reader.IsDBNull(reader.GetOrdinal("rating")) ? null : reader.GetInt32(reader.GetOrdinal("rating")),
                    Comments = reader.IsDBNull(reader.GetOrdinal("comments")) ? null : reader.GetString(reader.GetOrdinal("comments")),
                    CreatedAt = reader.IsDBNull(reader.GetOrdinal("created_at")) ? null : reader.GetDateTime(reader.GetOrdinal("created_at"))
                });
            }

            return list;
        }

        public async Task<IReadOnlyList<PendingProfessorEvaluationDto>> GetPendingAsync(Guid studentUserId)
        {
            var list = new List<PendingProfessorEvaluationDto>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_student_professor_evaluations_pending_select01(@p_student_user_id);";
            cmd.Parameters.AddWithValue("p_student_user_id", studentUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new PendingProfessorEvaluationDto
                {
                    ProfessorId = reader.GetGuid(reader.GetOrdinal("id_professor")),
                    ProfessorName = reader.GetString(reader.GetOrdinal("professor_name")),
                    LastLessonStart = reader.IsDBNull(reader.GetOrdinal("last_lesson_start")) ? null : reader.GetDateTime(reader.GetOrdinal("last_lesson_start")),
                    LastLessonEnd = reader.IsDBNull(reader.GetOrdinal("last_lesson_end")) ? null : reader.GetDateTime(reader.GetOrdinal("last_lesson_end"))
                });
            }

            return list;
        }

        public async Task<PendingProfessorEvaluationDto?> GetPendingByProfessorIdAsync(Guid studentUserId, Guid professorId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_student_professor_evaluations_pending_by_professor_select01(@p_student_user_id, @p_professor_id);";
            cmd.Parameters.AddWithValue("p_student_user_id", studentUserId);
            cmd.Parameters.AddWithValue("p_professor_id", professorId);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new PendingProfessorEvaluationDto
            {
                ProfessorId = reader.GetGuid(reader.GetOrdinal("id_professor")),
                ProfessorName = reader.GetString(reader.GetOrdinal("professor_name")),
                LastLessonStart = reader.IsDBNull(reader.GetOrdinal("last_lesson_start")) ? null : reader.GetDateTime(reader.GetOrdinal("last_lesson_start")),
                LastLessonEnd = reader.IsDBNull(reader.GetOrdinal("last_lesson_end")) ? null : reader.GetDateTime(reader.GetOrdinal("last_lesson_end"))
            };
        }

        public async Task<Guid> InsertProfessorFeedbackAsync(Guid studentUserId, Guid professorId, int rating, string? comments)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_feedback_insert(@id_professor, @id_user, @is_valid, @rating, @comments, @created_at);";

            cmd.Parameters.AddWithValue("id_professor", professorId);
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
                // Unique constraint: already evaluated this professor.
                return Guid.Empty;
            }
        }
    }
}
