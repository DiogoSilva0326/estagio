using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Student.Repository
{
    public class MyTutorsRepository : IMyTutorsRepository
    {
        private readonly string _connectionString;

        public MyTutorsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IReadOnlyList<MyTutorDto>> GetMyTutorsAsync(Guid studentUserId, Guid? areaId = null)
        {
            var list = new List<MyTutorDto>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT * FROM public.usp_student_my_tutors_select01(@p_student_user_id, @p_area_id);";

            cmd.Parameters.AddWithValue("p_student_user_id", studentUserId);
            cmd.Parameters.AddWithValue("p_area_id", (object?)areaId ?? DBNull.Value);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var reviewCount = reader.IsDBNull(reader.GetOrdinal("review_count"))
                    ? 0
                    : reader.GetInt32(reader.GetOrdinal("review_count"));

                var dto = new MyTutorDto
                {
                    ProfessorId = reader.GetGuid(reader.GetOrdinal("id_professor")),
                    TutorUserId = reader.GetGuid(reader.GetOrdinal("tutor_user_id")),
                    TutorUsername = reader.IsDBNull(reader.GetOrdinal("tutor_username"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("tutor_username")),
                    TutorName = reader.GetString(reader.GetOrdinal("tutor_name")),
                    AvatarUrl = reader.IsDBNull(reader.GetOrdinal("avatar_url"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("avatar_url")),
                    Subjects = reader.IsDBNull(reader.GetOrdinal("subjects"))
                        ? new List<string>()
                        : new List<string>(((string[])reader.GetValue(reader.GetOrdinal("subjects")))
                            .Where(item => !string.IsNullOrWhiteSpace(item))
                            .Select(item => item.Trim())),
                    LastLessonSubject = reader.IsDBNull(reader.GetOrdinal("last_lesson_subject"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("last_lesson_subject")),
                    LastLessonStart = reader.IsDBNull(reader.GetOrdinal("last_lesson_start"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("last_lesson_start")),
                    Rating = reviewCount <= 0 || reader.IsDBNull(reader.GetOrdinal("avg_rating"))
                        ? null
                        : reader.GetDouble(reader.GetOrdinal("avg_rating")),
                    ReviewCount = reviewCount,
                    Progress = reader.IsDBNull(reader.GetOrdinal("progress"))
                        ? 0.0
                        : reader.GetDouble(reader.GetOrdinal("progress"))
                };

                list.Add(dto);
            }

            return list;
        }
    }
}
