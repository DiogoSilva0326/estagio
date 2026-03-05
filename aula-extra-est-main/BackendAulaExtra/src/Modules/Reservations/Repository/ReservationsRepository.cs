using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Reservations.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Reservations.Repository
{
    public class ReservationsRepository : IReservationsRepository
    {
        private readonly string _connectionString;

        public ReservationsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Reservation>> GetReservationsAllAsync()
        {
            var list = new List<Reservation>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_reservations_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapReservation(reader));
            }

            return list;
        }

        public async Task<Reservation?> GetReservationByIdAsync(Guid idReservation)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_reservations_select_details01(@id_reservation);";
            cmd.Parameters.AddWithValue("id_reservation", idReservation);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapReservation(reader);
        }

        public async Task<Guid> InsertReservationAsync(Reservation reservation)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_reservations_insert(
    @id_user,
    @id_lesson,
    @id_lesson_schedule_block,
    @id_schedule_block,
    @id_block_part,
    @min_students_at_booking,
    @start_time,
    @end_time,
    @status
);";

            cmd.Parameters.AddWithValue("id_user", reservation.IdUser);
            cmd.Parameters.AddWithValue("id_lesson", reservation.IdLesson);
            cmd.Parameters.AddWithValue("id_lesson_schedule_block", (object?)reservation.IdLessonScheduleBlock ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_schedule_block", (object?)reservation.IdScheduleBlock ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_block_part", (object?)reservation.IdBlockPart ?? DBNull.Value);
            cmd.Parameters.AddWithValue("min_students_at_booking", (object?)reservation.MinStudentsAtBooking ?? DBNull.Value);
            cmd.Parameters.AddWithValue("start_time", (object?)reservation.StartTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("end_time", (object?)reservation.EndTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)reservation.Status ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateReservationAsync(Reservation reservation)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_reservations_update(
    @id_reservation,
    @id_user,
    @id_lesson,
    @id_lesson_schedule_block,
    @id_schedule_block,
    @id_block_part,
    @min_students_at_booking,
    @start_time,
    @end_time,
    @status
);";

            cmd.Parameters.AddWithValue("id_reservation", reservation.IdReservation);
            cmd.Parameters.AddWithValue("id_user", reservation.IdUser);
            cmd.Parameters.AddWithValue("id_lesson", reservation.IdLesson);
            cmd.Parameters.AddWithValue("id_lesson_schedule_block", (object?)reservation.IdLessonScheduleBlock ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_schedule_block", (object?)reservation.IdScheduleBlock ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_block_part", (object?)reservation.IdBlockPart ?? DBNull.Value);
            cmd.Parameters.AddWithValue("min_students_at_booking", (object?)reservation.MinStudentsAtBooking ?? DBNull.Value);
            cmd.Parameters.AddWithValue("start_time", (object?)reservation.StartTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("end_time", (object?)reservation.EndTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)reservation.Status ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteReservationAsync(Guid idReservation)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_reservations_delete(@id_reservation);";
            cmd.Parameters.AddWithValue("id_reservation", idReservation);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ExceptionRule>> GetExceptionRulesAllAsync()
        {
            var list = new List<ExceptionRule>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_exception_rules_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapExceptionRule(reader));
            }

            return list;
        }

        public async Task<ExceptionRule?> GetExceptionRuleByIdAsync(Guid idExceptionRule)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_exception_rules_select_details01(@id_exception_rule);";
            cmd.Parameters.AddWithValue("id_exception_rule", idExceptionRule);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapExceptionRule(reader);
        }

        public async Task<Guid> InsertExceptionRuleAsync(ExceptionRule rule)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_exception_rules_insert(
    @id_professor,
    @id_schedule_block,
    @rule_type,
    @custom_duration_minutes,
    @part_start_offset_minutes,
    @part_end_offset_minutes,
    @originating_request_id,
    @effective_from,
    @effective_to,
    @note
);";

            cmd.Parameters.AddWithValue("id_professor", rule.IdProfessor);
            cmd.Parameters.AddWithValue("id_schedule_block", (object?)rule.IdScheduleBlock ?? DBNull.Value);
            cmd.Parameters.AddWithValue("rule_type", (object?)rule.RuleType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("custom_duration_minutes", (object?)rule.CustomDurationMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("part_start_offset_minutes", (object?)rule.PartStartOffsetMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("part_end_offset_minutes", (object?)rule.PartEndOffsetMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("originating_request_id", (object?)rule.OriginatingRequestId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_from", (object?)rule.EffectiveFrom ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_to", (object?)rule.EffectiveTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("note", (object?)rule.Note ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateExceptionRuleAsync(ExceptionRule rule)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_exception_rules_update(
    @id_exception_rule,
    @id_professor,
    @id_schedule_block,
    @rule_type,
    @custom_duration_minutes,
    @part_start_offset_minutes,
    @part_end_offset_minutes,
    @originating_request_id,
    @effective_from,
    @effective_to,
    @note
);";

            cmd.Parameters.AddWithValue("id_exception_rule", rule.IdExceptionRule);
            cmd.Parameters.AddWithValue("id_professor", rule.IdProfessor);
            cmd.Parameters.AddWithValue("id_schedule_block", (object?)rule.IdScheduleBlock ?? DBNull.Value);
            cmd.Parameters.AddWithValue("rule_type", (object?)rule.RuleType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("custom_duration_minutes", (object?)rule.CustomDurationMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("part_start_offset_minutes", (object?)rule.PartStartOffsetMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("part_end_offset_minutes", (object?)rule.PartEndOffsetMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("originating_request_id", (object?)rule.OriginatingRequestId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_from", (object?)rule.EffectiveFrom ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_to", (object?)rule.EffectiveTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("note", (object?)rule.Note ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteExceptionRuleAsync(Guid idExceptionRule)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_exception_rules_delete(@id_exception_rule);";
            cmd.Parameters.AddWithValue("id_exception_rule", idExceptionRule);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ExceptionRequest>> GetExceptionRequestsAllAsync()
        {
            var list = new List<ExceptionRequest>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_exception_requests_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapExceptionRequest(reader));
            }

            return list;
        }

        public async Task<ExceptionRequest?> GetExceptionRequestByIdAsync(Guid idExceptionRequest)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_exception_requests_select_details01(@id_exception_request);";
            cmd.Parameters.AddWithValue("id_exception_request", idExceptionRequest);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapExceptionRequest(reader);
        }

        public async Task<Guid> InsertExceptionRequestAsync(ExceptionRequest request)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_exception_requests_insert(
    @id_user,
    @id_reservation,
    @id_professor,
    @request_type,
    @id_exception_rule,
    @requested_duration_minutes,
    @requested_start,
    @requested_end,
    @status,
    @reason
);";

            cmd.Parameters.AddWithValue("id_user", (object?)request.IdUser ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_reservation", (object?)request.IdReservation ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_professor", (object?)request.IdProfessor ?? DBNull.Value);
            cmd.Parameters.AddWithValue("request_type", (object?)request.RequestType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_exception_rule", (object?)request.IdExceptionRule ?? DBNull.Value);
            cmd.Parameters.AddWithValue("requested_duration_minutes", (object?)request.RequestedDurationMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("requested_start", (object?)request.RequestedStart ?? DBNull.Value);
            cmd.Parameters.AddWithValue("requested_end", (object?)request.RequestedEnd ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)request.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reason", (object?)request.Reason ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateExceptionRequestAsync(ExceptionRequest request)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"
SELECT public.usp_exception_requests_update(
    @id_exception_request,
    @id_user,
    @id_reservation,
    @id_professor,
    @request_type,
    @id_exception_rule,
    @requested_duration_minutes,
    @requested_start,
    @requested_end,
    @status,
    @reason
);";

            cmd.Parameters.AddWithValue("id_exception_request", request.IdExceptionRequest);
            cmd.Parameters.AddWithValue("id_user", (object?)request.IdUser ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_reservation", (object?)request.IdReservation ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_professor", (object?)request.IdProfessor ?? DBNull.Value);
            cmd.Parameters.AddWithValue("request_type", (object?)request.RequestType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_exception_rule", (object?)request.IdExceptionRule ?? DBNull.Value);
            cmd.Parameters.AddWithValue("requested_duration_minutes", (object?)request.RequestedDurationMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("requested_start", (object?)request.RequestedStart ?? DBNull.Value);
            cmd.Parameters.AddWithValue("requested_end", (object?)request.RequestedEnd ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)request.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reason", (object?)request.Reason ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteExceptionRequestAsync(Guid idExceptionRequest)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_exception_requests_delete(@id_exception_request);";
            cmd.Parameters.AddWithValue("id_exception_request", idExceptionRequest);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static Reservation MapReservation(NpgsqlDataReader reader)
        {
            return new Reservation
            {
                IdReservation = reader.GetGuid(reader.GetOrdinal("id_reservation")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                IdLesson = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                IdLessonScheduleBlock = GetNullableGuid(reader, "id_lesson_schedule_block"),
                IdScheduleBlock = GetNullableGuid(reader, "id_schedule_block"),
                IdBlockPart = GetNullableGuid(reader, "id_block_part"),
                MinStudentsAtBooking = GetNullableInt(reader, "min_students_at_booking"),
                StartTime = GetNullableDateTime(reader, "start_time"),
                EndTime = GetNullableDateTime(reader, "end_time"),
                Status = GetNullableString(reader, "status"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static ExceptionRule MapExceptionRule(NpgsqlDataReader reader)
        {
            return new ExceptionRule
            {
                IdExceptionRule = reader.GetGuid(reader.GetOrdinal("id_exception_rule")),
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                IdScheduleBlock = GetNullableGuid(reader, "id_schedule_block"),
                RuleType = GetNullableString(reader, "rule_type"),
                CustomDurationMinutes = GetNullableInt(reader, "custom_duration_minutes"),
                PartStartOffsetMinutes = GetNullableInt(reader, "part_start_offset_minutes"),
                PartEndOffsetMinutes = GetNullableInt(reader, "part_end_offset_minutes"),
                OriginatingRequestId = GetNullableInt(reader, "originating_request_id"),
                EffectiveFrom = GetNullableDateTime(reader, "effective_from"),
                EffectiveTo = GetNullableDateTime(reader, "effective_to"),
                Note = GetNullableString(reader, "note")
            };
        }

        private static ExceptionRequest MapExceptionRequest(NpgsqlDataReader reader)
        {
            return new ExceptionRequest
            {
                IdExceptionRequest = reader.GetGuid(reader.GetOrdinal("id_exception_request")),
                IdUser = GetNullableGuid(reader, "id_user"),
                IdReservation = GetNullableGuid(reader, "id_reservation"),
                IdProfessor = GetNullableGuid(reader, "id_professor"),
                RequestType = GetNullableString(reader, "request_type"),
                IdExceptionRule = GetNullableGuid(reader, "id_exception_rule"),
                RequestedDurationMinutes = GetNullableInt(reader, "requested_duration_minutes"),
                RequestedStart = GetNullableDateTime(reader, "requested_start"),
                RequestedEnd = GetNullableDateTime(reader, "requested_end"),
                Status = GetNullableString(reader, "status"),
                Reason = GetNullableString(reader, "reason"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetInt32(idx);
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetGuid(idx);
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetString(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try
            {
                return reader.GetFieldValue<DateTime>(idx);
            }
            catch
            {
                return null;
            }
        }
    }
}
