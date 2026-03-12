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

        public async Task<IReadOnlyList<MyTutorDto>> GetMyTutorsAsync(Guid studentUserId)
        {
            var list = new List<MyTutorDto>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT * FROM public.usp_student_my_tutors_select01(@p_student_user_id);";

            cmd.Parameters.AddWithValue("p_student_user_id", studentUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var dto = new MyTutorDto
                {
                    ProfessorId = reader.GetGuid(reader.GetOrdinal("id_professor")),
                    TutorUserId = reader.GetGuid(reader.GetOrdinal("tutor_user_id")),
                    TutorName = reader.GetString(reader.GetOrdinal("tutor_name")),
                    LastLessonSubject = reader.IsDBNull(reader.GetOrdinal("last_lesson_subject"))
                        ? null
                        : reader.GetString(reader.GetOrdinal("last_lesson_subject")),
                    LastLessonStart = reader.IsDBNull(reader.GetOrdinal("last_lesson_start"))
                        ? null
                        : reader.GetDateTime(reader.GetOrdinal("last_lesson_start")),
                    Rating = reader.IsDBNull(reader.GetOrdinal("last_lesson_rating"))
                        ? null
                        : reader.GetDouble(reader.GetOrdinal("last_lesson_rating")),
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
