using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.AdminDashboard.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.AdminDashboard.Repository
{
    public class AdminDashboardRepository : IAdminDashboardRepository
    {
        private readonly string _connectionString;

        public AdminDashboardRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<AdminDashboardResponse> GetAsync()
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_admin_dashboard_overview();";

            var payload = await cmd.ExecuteScalarAsync();
            if (payload == null || payload == DBNull.Value)
            {
                return new AdminDashboardResponse();
            }

            var json = payload switch
            {
                string text => text,
                JsonDocument document => document.RootElement.GetRawText(),
                _ => payload.ToString() ?? "{}"
            };

            return JsonSerializer.Deserialize<AdminDashboardResponse>(
                       json,
                       new JsonSerializerOptions
                       {
                           PropertyNameCaseInsensitive = true,
                       })
                   ?? new AdminDashboardResponse();
        }

        public async Task<IReadOnlyList<AdminSessionLogItem>> GetSessionLogsAsync()
        {
            var items = new List<AdminSessionLogItem>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    r.id_reservation,
    l.id_lesson,
    vc.id AS video_call_id,
    COALESCE(student.display_name, CONCAT_WS(' ', student.first_name, student.last_name), student.username, student.email) AS student_name,
    COALESCE(tutor.display_name, CONCAT_WS(' ', tutor.first_name, tutor.last_name), tutor.username, tutor.email) AS tutor_name,
    COALESCE(d.nome, c.name, NULLIF(TRIM(l.title), ''), 'Sessão') AS subject_name,
    COALESCE(r.start_time, l.scheduled_start) AS starts_at,
    COALESCE(r.end_time, l.scheduled_end) AS ends_at,
    COALESCE(
        l.duration_minutes,
        EXTRACT(EPOCH FROM (COALESCE(r.end_time, l.scheduled_end) - COALESCE(r.start_time, l.scheduled_start))) / 60,
        0
    )::int AS duration_minutes,
    COALESCE(r.status, 'scheduled') AS reservation_status,
    room.room_name AS channel_name,
    vc.status AS video_call_status,
    vc.started_at AS call_started_at,
    vc.ended_at AS call_ended_at,
    vc.duration_seconds AS call_duration_seconds,
    vc.recording_url
FROM public.reservations r
JOIN public.lessons l ON l.id_lesson = r.id_lesson
JOIN public.users student ON student.id_user = r.id_user
LEFT JOIN public.professors p ON p.id_professor = l.id_professor
LEFT JOIN public.users tutor ON tutor.id_user = p.id_user
LEFT JOIN public.professor_rooms room ON room.professor_id = tutor.id_user
LEFT JOIN public.courses c ON c.id_course = l.id_course
LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
LEFT JOIN LATERAL (
    SELECT
        calls.id,
        calls.status,
        calls.started_at,
        calls.ended_at,
        calls.duration_seconds,
        calls.recording_url
    FROM public.video_calls calls
    WHERE room.room_name IS NOT NULL
      AND calls.channel_name = room.room_name
    ORDER BY ABS(EXTRACT(EPOCH FROM (calls.started_at - COALESCE(r.start_time, l.scheduled_start, calls.started_at)))) ASC,
             calls.started_at DESC
    LIMIT 1
) vc ON true
ORDER BY COALESCE(r.start_time, l.scheduled_start, vc.started_at::timestamp) DESC, r.created_at DESC;";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                items.Add(new AdminSessionLogItem
                {
                    ReservationId = reader.GetGuid(reader.GetOrdinal("id_reservation")),
                    LessonId = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                    VideoCallId = GetNullableGuid(reader, "video_call_id"),
                    StudentName = GetNullableString(reader, "student_name") ?? string.Empty,
                    TutorName = GetNullableString(reader, "tutor_name") ?? string.Empty,
                    SubjectName = GetNullableString(reader, "subject_name") ?? string.Empty,
                    StartsAt = GetNullableDateTime(reader, "starts_at"),
                    EndsAt = GetNullableDateTime(reader, "ends_at"),
                    DurationMinutes = GetNullableInt(reader, "duration_minutes") ?? 0,
                    ReservationStatus = GetNullableString(reader, "reservation_status") ?? string.Empty,
                    ChannelName = GetNullableString(reader, "channel_name"),
                    VideoCallStatus = GetNullableString(reader, "video_call_status"),
                    CallStartedAt = GetNullableDateTimeOffset(reader, "call_started_at"),
                    CallEndedAt = GetNullableDateTimeOffset(reader, "call_ended_at"),
                    CallDurationSeconds = GetNullableInt(reader, "call_duration_seconds"),
                    RecordingUrl = GetNullableString(reader, "recording_url"),
                });
            }

            return items;
        }

        public async Task<AdminEvaluationsResponse> GetEvaluationsAsync()
        {
            var lessonEvaluations = new List<AdminEvaluationItem>();
            var professorEvaluations = new List<AdminEvaluationItem>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using (var lessonCmd = conn.CreateCommand())
            {
                lessonCmd.CommandText = @"
SELECT
    lf.id_lesson_feedback AS evaluation_id,
    lf.id_lesson,
    l.id_professor,
    lf.id_user AS student_user_id,
    COALESCE(student.display_name, CONCAT_WS(' ', student.first_name, student.last_name), student.username, student.email) AS student_name,
    COALESCE(professor_user.display_name, CONCAT_WS(' ', professor_user.first_name, professor_user.last_name), professor_user.username, professor_user.email) AS target_name,
    COALESCE(d.nome, c.name, NULLIF(TRIM(l.title), ''), 'Aula') AS subject_name,
    lf.rating,
    lf.comments,
    lf.created_at,
    lf.is_valid
FROM public.lesson_feedback lf
JOIN public.lessons l ON l.id_lesson = lf.id_lesson
JOIN public.users student ON student.id_user = lf.id_user
LEFT JOIN public.professors p ON p.id_professor = l.id_professor
LEFT JOIN public.users professor_user ON professor_user.id_user = p.id_user
LEFT JOIN public.courses c ON c.id_course = l.id_course
LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
ORDER BY lf.created_at DESC NULLS LAST, lf.id_lesson_feedback DESC;";

                await using var reader = await lessonCmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    lessonEvaluations.Add(new AdminEvaluationItem
                    {
                        EvaluationId = reader.GetGuid(reader.GetOrdinal("evaluation_id")),
                        Kind = "lesson",
                        LessonId = GetNullableGuid(reader, "id_lesson"),
                        ProfessorId = GetNullableGuid(reader, "id_professor"),
                        StudentUserId = reader.GetGuid(reader.GetOrdinal("student_user_id")),
                        StudentName = GetNullableString(reader, "student_name") ?? string.Empty,
                        TargetName = GetNullableString(reader, "target_name") ?? string.Empty,
                        SubjectName = GetNullableString(reader, "subject_name"),
                        Rating = GetNullableInt(reader, "rating"),
                        Comment = GetNullableString(reader, "comments"),
                        CreatedAt = GetNullableDateTime(reader, "created_at"),
                        IsValid = GetNullableBool(reader, "is_valid"),
                    });
                }
            }

            await using (var professorCmd = conn.CreateCommand())
            {
                professorCmd.CommandText = @"
SELECT
    pf.id_professor_feedback AS evaluation_id,
    pf.id_professor,
    pf.id_user AS student_user_id,
    COALESCE(student.display_name, CONCAT_WS(' ', student.first_name, student.last_name), student.username, student.email) AS student_name,
    COALESCE(professor_user.display_name, CONCAT_WS(' ', professor_user.first_name, professor_user.last_name), professor_user.username, professor_user.email) AS target_name,
    pf.rating,
    pf.comments,
    pf.created_at,
    pf.is_valid
FROM public.professor_feedback pf
JOIN public.professors p ON p.id_professor = pf.id_professor
JOIN public.users student ON student.id_user = pf.id_user
LEFT JOIN public.users professor_user ON professor_user.id_user = p.id_user
ORDER BY pf.created_at DESC NULLS LAST, pf.id_professor_feedback DESC;";

                await using var reader = await professorCmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    professorEvaluations.Add(new AdminEvaluationItem
                    {
                        EvaluationId = reader.GetGuid(reader.GetOrdinal("evaluation_id")),
                        Kind = "professor",
                        ProfessorId = GetNullableGuid(reader, "id_professor"),
                        StudentUserId = reader.GetGuid(reader.GetOrdinal("student_user_id")),
                        StudentName = GetNullableString(reader, "student_name") ?? string.Empty,
                        TargetName = GetNullableString(reader, "target_name") ?? string.Empty,
                        SubjectName = "Professor",
                        Rating = GetNullableInt(reader, "rating"),
                        Comment = GetNullableString(reader, "comments"),
                        CreatedAt = GetNullableDateTime(reader, "created_at"),
                        IsValid = GetNullableBool(reader, "is_valid"),
                    });
                }
            }

            var allEvaluations = lessonEvaluations.Concat(professorEvaluations).ToList();
            var approvedRatings = allEvaluations
                .Where(item => item.IsValid == true && item.Rating.HasValue)
                .Select(item => item.Rating!.Value)
                .ToList();

            return new AdminEvaluationsResponse
            {
                Summary = new AdminEvaluationsSummary
                {
                    AverageRating = approvedRatings.Count == 0
                        ? 0
                        : Math.Round(approvedRatings.Average(), 1),
                    TotalEvaluations = allEvaluations.Count,
                    PendingModeration = allEvaluations.Count(item => item.IsValid == null),
                    LessonEvaluations = lessonEvaluations.Count,
                    ProfessorEvaluations = professorEvaluations.Count,
                },
                LessonEvaluations = lessonEvaluations,
                ProfessorEvaluations = professorEvaluations,
            };
        }

        public async Task<int> ModerateEvaluationAsync(string kind, Guid evaluationId, bool isValid)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = kind switch
            {
                "lesson" => @"
UPDATE public.lesson_feedback
SET is_valid = @is_valid
WHERE id_lesson_feedback = @evaluation_id;",
                "professor" => @"
UPDATE public.professor_feedback
SET is_valid = @is_valid
WHERE id_professor_feedback = @evaluation_id;",
                _ => throw new ArgumentOutOfRangeException(nameof(kind), kind, "Unsupported evaluation kind."),
            };

            cmd.Parameters.AddWithValue("is_valid", isValid);
            cmd.Parameters.AddWithValue("evaluation_id", evaluationId);

            return await cmd.ExecuteNonQueryAsync();
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetGuid(ordinal);
        }

        private static bool? GetNullableBool(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetBoolean(ordinal);
        }

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetInt32(ordinal);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetDateTime(ordinal);
        }

        private static DateTimeOffset? GetNullableDateTimeOffset(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetFieldValue<DateTimeOffset>(ordinal);
        }
    }
}