using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Schedule.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Schedule.Repository
{
    public class ScheduleRepository : IScheduleRepository
    {
        private readonly string _connectionString;

        public ScheduleRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Day>> GetDaysAllAsync()
        {
            var list = new List<Day>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_days_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Day
                {
                    IdDay = reader.GetGuid(reader.GetOrdinal("id_day")),
                    Name = reader.GetString(reader.GetOrdinal("name")),
                    DayIndex = GetNullableInt(reader, "day_index")
                });
            }

            return list;
        }

        public async Task<Day?> GetDayByIdAsync(Guid idDay)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_days_select_details01(@id_day);";
            cmd.Parameters.AddWithValue("id_day", idDay);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new Day
            {
                IdDay = reader.GetGuid(reader.GetOrdinal("id_day")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                DayIndex = GetNullableInt(reader, "day_index")
            };
        }

        public async Task<Guid> InsertDayAsync(Day day)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_days_insert(@name, @day_index);";
            cmd.Parameters.AddWithValue("name", (object?)day.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("day_index", (object?)day.DayIndex ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateDayAsync(Day day)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_days_update(@id_day, @name, @day_index);";
            cmd.Parameters.AddWithValue("id_day", day.IdDay);
            cmd.Parameters.AddWithValue("name", (object?)day.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("day_index", (object?)day.DayIndex ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteDayAsync(Guid idDay)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_days_delete(@id_day);";
            cmd.Parameters.AddWithValue("id_day", idDay);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ScheduleBlock>> GetScheduleBlocksAllAsync()
        {
            var list = new List<ScheduleBlock>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_schedule_blocks_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapScheduleBlock(reader));
            }

            return list;
        }

        public async Task<ScheduleBlock?> GetScheduleBlockByIdAsync(Guid idScheduleBlock)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_schedule_blocks_select_details01(@id_schedule_block);";
            cmd.Parameters.AddWithValue("id_schedule_block", idScheduleBlock);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapScheduleBlock(reader);
        }

        public async Task<Guid> InsertScheduleBlockAsync(ScheduleBlock block)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"SELECT public.usp_schedule_blocks_insert(
    @id_professor,
    @id_day,
    @start_time,
    @end_time,
    @default_duration_minutes,
    @is_available,
    @recurrence_rule
);";

            cmd.Parameters.AddWithValue("id_professor", block.IdProfessor);
            cmd.Parameters.AddWithValue("id_day", (object?)block.IdDay ?? DBNull.Value);
            cmd.Parameters.AddWithValue("start_time", (object?)block.StartTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("end_time", (object?)block.EndTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("default_duration_minutes", (object?)block.DefaultDurationMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_available", (object?)block.IsAvailable ?? DBNull.Value);
            cmd.Parameters.AddWithValue("recurrence_rule", (object?)block.RecurrenceRule ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateScheduleBlockAsync(ScheduleBlock block)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"SELECT public.usp_schedule_blocks_update(
    @id_schedule_block,
    @id_professor,
    @id_day,
    @start_time,
    @end_time,
    @default_duration_minutes,
    @is_available,
    @recurrence_rule
);";

            cmd.Parameters.AddWithValue("id_schedule_block", block.IdScheduleBlock);
            cmd.Parameters.AddWithValue("id_professor", block.IdProfessor);
            cmd.Parameters.AddWithValue("id_day", (object?)block.IdDay ?? DBNull.Value);
            cmd.Parameters.AddWithValue("start_time", (object?)block.StartTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("end_time", (object?)block.EndTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("default_duration_minutes", (object?)block.DefaultDurationMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_available", (object?)block.IsAvailable ?? DBNull.Value);
            cmd.Parameters.AddWithValue("recurrence_rule", (object?)block.RecurrenceRule ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteScheduleBlockAsync(Guid idScheduleBlock)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_schedule_blocks_delete(@id_schedule_block);";
            cmd.Parameters.AddWithValue("id_schedule_block", idScheduleBlock);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<BlockPart>> GetBlockPartsAllAsync()
        {
            var list = new List<BlockPart>();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_block_parts_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new BlockPart
                {
                    IdBlockPart = reader.GetGuid(reader.GetOrdinal("id_block_part")),
                    IdScheduleBlock = reader.GetGuid(reader.GetOrdinal("id_schedule_block")),
                    StartOffsetMinutes = GetNullableInt(reader, "start_offset_minutes"),
                    EndOffsetMinutes = GetNullableInt(reader, "end_offset_minutes"),
                    IsAvailable = GetNullableBool(reader, "is_available")
                });
            }

            return list;
        }

        public async Task<BlockPart?> GetBlockPartByIdAsync(Guid idBlockPart)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_block_parts_select_details01(@id_block_part);";
            cmd.Parameters.AddWithValue("id_block_part", idBlockPart);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new BlockPart
            {
                IdBlockPart = reader.GetGuid(reader.GetOrdinal("id_block_part")),
                IdScheduleBlock = reader.GetGuid(reader.GetOrdinal("id_schedule_block")),
                StartOffsetMinutes = GetNullableInt(reader, "start_offset_minutes"),
                EndOffsetMinutes = GetNullableInt(reader, "end_offset_minutes"),
                IsAvailable = GetNullableBool(reader, "is_available")
            };
        }

        public async Task<Guid> InsertBlockPartAsync(BlockPart part)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"SELECT public.usp_block_parts_insert(
    @id_schedule_block,
    @start_offset_minutes,
    @end_offset_minutes,
    @is_available
);";

            cmd.Parameters.AddWithValue("id_schedule_block", part.IdScheduleBlock);
            cmd.Parameters.AddWithValue("start_offset_minutes", (object?)part.StartOffsetMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("end_offset_minutes", (object?)part.EndOffsetMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_available", (object?)part.IsAvailable ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateBlockPartAsync(BlockPart part)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"SELECT public.usp_block_parts_update(
    @id_block_part,
    @id_schedule_block,
    @start_offset_minutes,
    @end_offset_minutes,
    @is_available
);";

            cmd.Parameters.AddWithValue("id_block_part", part.IdBlockPart);
            cmd.Parameters.AddWithValue("id_schedule_block", part.IdScheduleBlock);
            cmd.Parameters.AddWithValue("start_offset_minutes", (object?)part.StartOffsetMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("end_offset_minutes", (object?)part.EndOffsetMinutes ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_available", (object?)part.IsAvailable ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteBlockPartAsync(Guid idBlockPart)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_block_parts_delete(@id_block_part);";
            cmd.Parameters.AddWithValue("id_block_part", idBlockPart);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static ScheduleBlock MapScheduleBlock(NpgsqlDataReader reader)
        {
            return new ScheduleBlock
            {
                IdScheduleBlock = reader.GetGuid(reader.GetOrdinal("id_schedule_block")),
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                IdDay = GetNullableGuid(reader, "id_day"),
                StartTime = GetNullableDateTime(reader, "start_time"),
                EndTime = GetNullableDateTime(reader, "end_time"),
                DefaultDurationMinutes = GetNullableInt(reader, "default_duration_minutes"),
                IsAvailable = GetNullableBool(reader, "is_available"),
                RecurrenceRule = GetNullableString(reader, "recurrence_rule"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
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

        private static bool? GetNullableBool(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetBoolean(idx);
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
