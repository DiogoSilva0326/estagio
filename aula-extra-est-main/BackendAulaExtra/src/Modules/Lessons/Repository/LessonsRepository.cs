using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Lessons.Models;
using Npgsql;
using NpgsqlTypes;

namespace ConfidantPostgreSQL.Modules.Lessons.Repository
{
    public class LessonsRepository : ILessonsRepository
    {
        private readonly string _connectionString;

        public LessonsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Lesson>> GetLessonsAllAsync()
        {
            var list = new List<Lesson>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_lessons_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Lesson
                {
                    IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                    IdCourse = GetNullableGuid(reader, "id_course"),
                    IdProfessor = GetNullableGuid(reader, "id_professor"),
                    Title = GetNullableString(reader, "title"),
                    Students = GetNullableInt(reader, "students"),
                    DurationMinutes = GetNullableInt(reader, "duration_minutes"),
                    ScheduledStart = GetNullableDateTime(reader, "scheduled_start"),
                    ScheduledEnd = GetNullableDateTime(reader, "scheduled_end"),
                    UsesCustomBlocks = GetNullableBool(reader, "uses_custom_blocks"),
                    MaxStudents = GetNullableInt(reader, "max_students"),
                    BasePrice = GetNullableDecimal(reader, "base_price")
                });
            }
            return list;
        }

        public async Task<Lesson?> GetLessonByIdAsync(Guid idLesson)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_lessons_select_details01(@id_lesson);";
            cmd.Parameters.AddWithValue("id_lesson", idLesson);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new Lesson
            {
                IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                IdCourse = GetNullableGuid(reader, "id_course"),
                IdProfessor = GetNullableGuid(reader, "id_professor"),
                Title = GetNullableString(reader, "title"),
                Students = GetNullableInt(reader, "students"),
                DurationMinutes = GetNullableInt(reader, "duration_minutes"),
                ScheduledStart = GetNullableDateTime(reader, "scheduled_start"),
                ScheduledEnd = GetNullableDateTime(reader, "scheduled_end"),
                UsesCustomBlocks = GetNullableBool(reader, "uses_custom_blocks"),
                MaxStudents = GetNullableInt(reader, "max_students"),
                BasePrice = GetNullableDecimal(reader, "base_price")
            };
        }

        public async Task<Guid> InsertLessonAsync(Lesson lesson)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_lessons_insert(@id_course, @id_professor, @title, @students, @duration_minutes, @scheduled_start, @scheduled_end, @uses_custom_blocks, @max_students, @base_price);";
            cmd.Parameters.AddWithValue("id_course", (object?)lesson.IdCourse ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_professor", (object?)lesson.IdProfessor ?? DBNull.Value);
            cmd.Parameters.AddWithValue("title", (object?)lesson.Title ?? DBNull.Value);
            cmd.Parameters.AddWithValue("students", (object?)lesson.Students ?? DBNull.Value);
            cmd.Parameters.AddWithValue("duration_minutes", (object?)lesson.DurationMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("scheduled_start", (object?)lesson.ScheduledStart ?? DBNull.Value);
            cmd.Parameters.AddWithValue("scheduled_end", (object?)lesson.ScheduledEnd ?? DBNull.Value);
            cmd.Parameters.AddWithValue("uses_custom_blocks", (object?)lesson.UsesCustomBlocks ?? DBNull.Value);
            cmd.Parameters.AddWithValue("max_students", (object?)lesson.MaxStudents ?? DBNull.Value);
            cmd.Parameters.AddWithValue("base_price", (object?)lesson.BasePrice ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateLessonAsync(Lesson lesson)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lessons_update(@id_lesson, @id_course, @id_professor, @title, @students, @duration_minutes, @scheduled_start, @scheduled_end, @uses_custom_blocks, @max_students, @base_price);";
            cmd.Parameters.AddWithValue("id_lesson", lesson.IdLesson);
            cmd.Parameters.AddWithValue("id_course", (object?)lesson.IdCourse ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_professor", (object?)lesson.IdProfessor ?? DBNull.Value);
            cmd.Parameters.AddWithValue("title", (object?)lesson.Title ?? DBNull.Value);
            cmd.Parameters.AddWithValue("students", (object?)lesson.Students ?? DBNull.Value);
            cmd.Parameters.AddWithValue("duration_minutes", (object?)lesson.DurationMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("scheduled_start", (object?)lesson.ScheduledStart ?? DBNull.Value);
            cmd.Parameters.AddWithValue("scheduled_end", (object?)lesson.ScheduledEnd ?? DBNull.Value);
            cmd.Parameters.AddWithValue("uses_custom_blocks", (object?)lesson.UsesCustomBlocks ?? DBNull.Value);
            cmd.Parameters.AddWithValue("max_students", (object?)lesson.MaxStudents ?? DBNull.Value);
            cmd.Parameters.AddWithValue("base_price", (object?)lesson.BasePrice ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteLessonAsync(Guid idLesson)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lessons_delete(@id_lesson);";
            cmd.Parameters.AddWithValue("id_lesson", idLesson);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<LessonFeedback>> GetLessonFeedbackAllAsync()
        {
            var list = new List<LessonFeedback>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_lesson_feedback_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new LessonFeedback
                {
                    IdLessonFeedback = reader.GetGuid(reader.GetOrdinal("id_lesson_feedback")),
                    IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                    IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                    IsValid = GetBoolDefaultFalse(reader, "is_valid"),
                    Rating = GetNullableInt(reader, "rating"),
                    Comments = GetNullableString(reader, "comments"),
                    CreatedAt = GetNullableDateTime(reader, "created_at")
                });
            }
            return list;
        }

        public async Task<LessonFeedback?> GetLessonFeedbackByIdAsync(Guid idLessonFeedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_lesson_feedback_select_details01(@id_lesson_feedback);";
            cmd.Parameters.AddWithValue("id_lesson_feedback", idLessonFeedback);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new LessonFeedback
            {
                IdLessonFeedback = reader.GetGuid(reader.GetOrdinal("id_lesson_feedback")),
                IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                IsValid = GetBoolDefaultFalse(reader, "is_valid"),
                Rating = GetNullableInt(reader, "rating"),
                Comments = GetNullableString(reader, "comments"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        public async Task<Guid> InsertLessonFeedbackAsync(LessonFeedback feedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_lesson_feedback_insert(@id_lesson, @id_user, @is_valid, @rating, @comments, @created_at);";
            cmd.Parameters.AddWithValue("id_lesson", feedback.IdLesson);
            cmd.Parameters.AddWithValue("id_user", feedback.IdUser);
            cmd.Parameters.AddWithValue("is_valid", feedback.IsValid);
            cmd.Parameters.AddWithValue("rating", (object?)feedback.Rating ?? DBNull.Value);
            cmd.Parameters.AddWithValue("comments", (object?)feedback.Comments ?? DBNull.Value);
            if (feedback.CreatedAt == null)
            {
                cmd.Parameters.AddWithValue("created_at", DBNull.Value);
            }
            else
            {
                cmd.Parameters.Add("created_at", NpgsqlDbType.Timestamp).Value = DateTime.SpecifyKind(feedback.CreatedAt.Value, DateTimeKind.Unspecified);
            }
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateLessonFeedbackAsync(LessonFeedback feedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lesson_feedback_update(@id_lesson_feedback, @id_lesson, @id_user, @is_valid, @rating, @comments, @created_at);";
            cmd.Parameters.AddWithValue("id_lesson_feedback", feedback.IdLessonFeedback);
            cmd.Parameters.AddWithValue("id_lesson", feedback.IdLesson);
            cmd.Parameters.AddWithValue("id_user", feedback.IdUser);
            cmd.Parameters.AddWithValue("is_valid", feedback.IsValid);
            cmd.Parameters.AddWithValue("rating", (object?)feedback.Rating ?? DBNull.Value);
            cmd.Parameters.AddWithValue("comments", (object?)feedback.Comments ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)feedback.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteLessonFeedbackAsync(Guid idLessonFeedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lesson_feedback_delete(@id_lesson_feedback);";
            cmd.Parameters.AddWithValue("id_lesson_feedback", idLessonFeedback);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<LessonPrice>> GetLessonPricesAllAsync()
        {
            var list = new List<LessonPrice>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_lesson_prices_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new LessonPrice
                {
                    IdLessonPrice = reader.GetGuid(reader.GetOrdinal("id_lesson_price")),
                    IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                    SessionPrice = GetNullableDecimal(reader, "session_price"),
                    PricePerStudent = GetNullableDecimal(reader, "price_per_student"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<LessonPrice?> GetLessonPriceByIdAsync(Guid idLessonPrice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_lesson_prices_select_details01(@id_lesson_price);";
            cmd.Parameters.AddWithValue("id_lesson_price", idLessonPrice);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new LessonPrice
            {
                IdLessonPrice = reader.GetGuid(reader.GetOrdinal("id_lesson_price")),
                IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                SessionPrice = GetNullableDecimal(reader, "session_price"),
                PricePerStudent = GetNullableDecimal(reader, "price_per_student"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertLessonPriceAsync(LessonPrice price)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_lesson_prices_insert(@id_lesson, @session_price, @price_per_student, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("id_lesson", price.IdLesson);
            cmd.Parameters.AddWithValue("session_price", (object?)price.SessionPrice ?? DBNull.Value);
            cmd.Parameters.AddWithValue("price_per_student", (object?)price.PricePerStudent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)price.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)price.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateLessonPriceAsync(LessonPrice price)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lesson_prices_update(@id_lesson_price, @id_lesson, @session_price, @price_per_student);";
            cmd.Parameters.AddWithValue("id_lesson_price", price.IdLessonPrice);
            cmd.Parameters.AddWithValue("id_lesson", price.IdLesson);
            cmd.Parameters.AddWithValue("session_price", (object?)price.SessionPrice ?? DBNull.Value);
            cmd.Parameters.AddWithValue("price_per_student", (object?)price.PricePerStudent ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteLessonPriceAsync(Guid idLessonPrice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lesson_prices_delete(@id_lesson_price);";
            cmd.Parameters.AddWithValue("id_lesson_price", idLessonPrice);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<LessonScheduleBlock>> GetLessonScheduleBlocksAllAsync()
        {
            var list = new List<LessonScheduleBlock>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_lesson_schedule_blocks_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new LessonScheduleBlock
                {
                    IdLessonScheduleBlock = reader.GetGuid(reader.GetOrdinal("id_lesson_schedule_block")),
                    IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                    IdScheduleBlock = reader.GetGuid(reader.GetOrdinal("id_schedule_block")),
                    IdBlockPart = GetNullableGuid(reader, "id_block_part"),
                    StartTime = GetNullableDateTime(reader, "start_time"),
                    EndTime = GetNullableDateTime(reader, "end_time")
                });
            }
            return list;
        }

        public async Task<LessonScheduleBlock?> GetLessonScheduleBlockByIdAsync(Guid idLessonScheduleBlock)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_lesson_schedule_blocks_select_details01(@id_lesson_schedule_block);";
            cmd.Parameters.AddWithValue("id_lesson_schedule_block", idLessonScheduleBlock);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new LessonScheduleBlock
            {
                IdLessonScheduleBlock = reader.GetGuid(reader.GetOrdinal("id_lesson_schedule_block")),
                IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                IdScheduleBlock = reader.GetGuid(reader.GetOrdinal("id_schedule_block")),
                IdBlockPart = GetNullableGuid(reader, "id_block_part"),
                StartTime = GetNullableDateTime(reader, "start_time"),
                EndTime = GetNullableDateTime(reader, "end_time")
            };
        }

        public async Task<Guid> InsertLessonScheduleBlockAsync(LessonScheduleBlock block)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_lesson_schedule_blocks_insert(@id_lesson, @id_schedule_block, @id_block_part, @start_time, @end_time);";
            cmd.Parameters.AddWithValue("id_lesson", block.IdLesson);
            cmd.Parameters.AddWithValue("id_schedule_block", block.IdScheduleBlock);
            cmd.Parameters.AddWithValue("id_block_part", (object?)block.IdBlockPart ?? DBNull.Value);
            cmd.Parameters.AddWithValue("start_time", (object?)block.StartTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("end_time", (object?)block.EndTime ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateLessonScheduleBlockAsync(LessonScheduleBlock block)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lesson_schedule_blocks_update(@id_lesson_schedule_block, @id_lesson, @id_schedule_block, @id_block_part, @start_time, @end_time);";
            cmd.Parameters.AddWithValue("id_lesson_schedule_block", block.IdLessonScheduleBlock);
            cmd.Parameters.AddWithValue("id_lesson", block.IdLesson);
            cmd.Parameters.AddWithValue("id_schedule_block", block.IdScheduleBlock);
            cmd.Parameters.AddWithValue("id_block_part", (object?)block.IdBlockPart ?? DBNull.Value);
            cmd.Parameters.AddWithValue("start_time", (object?)block.StartTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("end_time", (object?)block.EndTime ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteLessonScheduleBlockAsync(Guid idLessonScheduleBlock)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_lesson_schedule_blocks_delete(@id_lesson_schedule_block);";
            cmd.Parameters.AddWithValue("id_lesson_schedule_block", idLessonScheduleBlock);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Enrollment>> GetEnrollmentsAllAsync()
        {
            var list = new List<Enrollment>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_enrollments_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Enrollment
                {
                    IdEnrollment = reader.GetGuid(reader.GetOrdinal("id_enrollment")),
                    IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                    IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                    Status = GetNullableString(reader, "status"),
                    PricePaid = GetNullableDecimal(reader, "price_paid"),
                    CreatedAt = GetNullableDateTime(reader, "created_at")
                });
            }
            return list;
        }

        public async Task<Enrollment?> GetEnrollmentByIdAsync(Guid idEnrollment)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_enrollments_select_details01(@id_enrollment);";
            cmd.Parameters.AddWithValue("id_enrollment", idEnrollment);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new Enrollment
            {
                IdEnrollment = reader.GetGuid(reader.GetOrdinal("id_enrollment")),
                IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                Status = GetNullableString(reader, "status"),
                PricePaid = GetNullableDecimal(reader, "price_paid"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        public async Task<Guid> InsertEnrollmentAsync(Enrollment enrollment)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_enrollments_insert(@id_lesson, @id_user, @status, @price_paid, @created_at);";
            cmd.Parameters.AddWithValue("id_lesson", enrollment.IdLesson);
            cmd.Parameters.AddWithValue("id_user", enrollment.IdUser);
            cmd.Parameters.AddWithValue("status", (object?)enrollment.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("price_paid", (object?)enrollment.PricePaid ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)enrollment.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateEnrollmentAsync(Enrollment enrollment)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_enrollments_update(@id_enrollment, @id_lesson, @id_user, @status, @price_paid, @created_at);";
            cmd.Parameters.AddWithValue("id_enrollment", enrollment.IdEnrollment);
            cmd.Parameters.AddWithValue("id_lesson", enrollment.IdLesson);
            cmd.Parameters.AddWithValue("id_user", enrollment.IdUser);
            cmd.Parameters.AddWithValue("status", (object?)enrollment.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("price_paid", (object?)enrollment.PricePaid ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)enrollment.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteEnrollmentAsync(Guid idEnrollment)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_enrollments_delete(@id_enrollment);";
            cmd.Parameters.AddWithValue("id_enrollment", idEnrollment);
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

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetInt32(idx);
        }

        private static decimal? GetNullableDecimal(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetFieldValue<decimal>(idx);
        }

        private static bool? GetNullableBool(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetBoolean(idx);
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
