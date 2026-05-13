using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.SystemSettings.Models;
using Microsoft.Extensions.Logging;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.SystemSettings.Repository;

public class SystemSettingsRepository : ISystemSettingsRepository
{
    private readonly string _connectionString;
    private readonly ILogger<SystemSettingsRepository>? _logger;

    public SystemSettingsRepository(string connectionString, ILogger<SystemSettingsRepository>? logger = null)
    {
        _connectionString = connectionString;
        _logger = logger;
    }

    public async Task<Guid> InsertAsync(SystemSetting setting, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);

        var id = setting.Id == Guid.Empty ? Guid.NewGuid() : setting.Id;

        await using var cmd = new NpgsqlCommand(@"
            INSERT INTO public.system_settings (id, settings_key, settings_value, data_type, description)
            VALUES (@id, @settings_key, @settings_value, @data_type, @description)
        ", conn);

        cmd.Parameters.AddWithValue("id", id);
        cmd.Parameters.AddWithValue("settings_key", setting.SettingsKey.Trim());
        cmd.Parameters.AddWithValue("settings_value", (object?)setting.SettingsValue ?? DBNull.Value);
        cmd.Parameters.AddWithValue("data_type", (object?)setting.DataType ?? DBNull.Value);
        cmd.Parameters.AddWithValue("description", (object?)setting.Description ?? DBNull.Value);

        await cmd.ExecuteNonQueryAsync(cancellationToken);
        return id;
    }

    public async Task<int> UpdateAsync(SystemSetting setting, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);

        await using var cmd = new NpgsqlCommand(@"
            UPDATE public.system_settings
               SET settings_key = @settings_key,
                   settings_value = @settings_value,
                   data_type = @data_type,
                   description = @description
             WHERE id = @id
        ", conn);

        cmd.Parameters.AddWithValue("id", setting.Id);
        cmd.Parameters.AddWithValue("settings_key", setting.SettingsKey.Trim());
        cmd.Parameters.AddWithValue("settings_value", (object?)setting.SettingsValue ?? DBNull.Value);
        cmd.Parameters.AddWithValue("data_type", (object?)setting.DataType ?? DBNull.Value);
        cmd.Parameters.AddWithValue("description", (object?)setting.Description ?? DBNull.Value);

        return await cmd.ExecuteNonQueryAsync(cancellationToken);
    }

    public async Task<int> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);

        await using var cmd = new NpgsqlCommand("DELETE FROM public.system_settings WHERE id = @id", conn);
        cmd.Parameters.AddWithValue("id", id);
        return await cmd.ExecuteNonQueryAsync(cancellationToken);
    }

    public async Task<SystemSetting?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);

        await using var cmd = new NpgsqlCommand(@"
            SELECT id, settings_key, settings_value, data_type, description
              FROM public.system_settings
             WHERE id = @id
             LIMIT 1
        ", conn);
        cmd.Parameters.AddWithValue("id", id);

        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken) ? Map(reader) : null;
    }

    public async Task<SystemSetting?> GetByKeyAsync(string settingsKey, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(settingsKey))
        {
            return null;
        }

        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);

        await using var cmd = new NpgsqlCommand(@"
            SELECT id, settings_key, settings_value, data_type, description
              FROM public.system_settings
             WHERE LOWER(settings_key) = LOWER(@settings_key)
             LIMIT 1
        ", conn);
        cmd.Parameters.AddWithValue("settings_key", settingsKey.Trim());

        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        return await reader.ReadAsync(cancellationToken) ? Map(reader) : null;
    }

    public async Task<List<SystemSetting>> GetSummaryAsync(string orderColumns, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var safePageNumber = pageNumber < 1 ? 1 : pageNumber;
        var safePageSize = pageSize is < 1 or > 200 ? 50 : pageSize;
        var orderBy = string.Equals(orderColumns?.Trim(), "settings_key", StringComparison.OrdinalIgnoreCase)
            ? "settings_key"
            : "id";

        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);

        await using var cmd = new NpgsqlCommand($@"
            SELECT id, settings_key, settings_value, data_type, description
              FROM public.system_settings
             ORDER BY {orderBy}, id
             LIMIT @page_size OFFSET (@page_number - 1) * @page_size
        ", conn);
        cmd.Parameters.AddWithValue("page_number", safePageNumber);
        cmd.Parameters.AddWithValue("page_size", safePageSize);

        var list = new List<SystemSetting>();
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            list.Add(Map(reader));
        }

        return list;
    }

    public async Task<List<SystemSetting>> SearchAsync(string search, string orderColumns, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        var safePageNumber = pageNumber < 1 ? 1 : pageNumber;
        var safePageSize = pageSize is < 1 or > 200 ? 50 : pageSize;
        var orderBy = string.Equals(orderColumns?.Trim(), "settings_key", StringComparison.OrdinalIgnoreCase)
            ? "settings_key"
            : "id";

        await using var conn = new NpgsqlConnection(_connectionString);
        await conn.OpenAsync(cancellationToken);
        await EnsureSchemaAsync(conn, cancellationToken);

        await using var cmd = new NpgsqlCommand($@"
            SELECT id, settings_key, settings_value, data_type, description
              FROM public.system_settings
             WHERE @search = ''
                OR settings_key ILIKE '%' || @search || '%'
                OR COALESCE(description, '') ILIKE '%' || @search || '%'
             ORDER BY {orderBy}, id
             LIMIT @page_size OFFSET (@page_number - 1) * @page_size
        ", conn);
        cmd.Parameters.AddWithValue("search", search?.Trim() ?? string.Empty);
        cmd.Parameters.AddWithValue("page_number", safePageNumber);
        cmd.Parameters.AddWithValue("page_size", safePageSize);

        var list = new List<SystemSetting>();
        await using var reader = await cmd.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            list.Add(Map(reader));
        }

        return list;
    }

    private async Task EnsureSchemaAsync(NpgsqlConnection conn, CancellationToken cancellationToken)
    {
        await using var cmd = new NpgsqlCommand(@"
            CREATE TABLE IF NOT EXISTS public.system_settings
            (
                id UUID NOT NULL DEFAULT gen_random_uuid(),
                settings_key VARCHAR(100) NOT NULL UNIQUE,
                settings_value TEXT,
                data_type VARCHAR(50),
                description VARCHAR(500),
                PRIMARY KEY (id)
            );
        ", conn);

        await cmd.ExecuteNonQueryAsync(cancellationToken);
    }

    private static SystemSetting Map(NpgsqlDataReader reader)
    {
        return new SystemSetting
        {
            Id = reader.GetFieldValue<Guid>(reader.GetOrdinal("id")),
            SettingsKey = reader.GetString(reader.GetOrdinal("settings_key")),
            SettingsValue = reader.IsDBNull(reader.GetOrdinal("settings_value")) ? null : reader.GetString(reader.GetOrdinal("settings_value")),
            DataType = reader.IsDBNull(reader.GetOrdinal("data_type")) ? null : reader.GetString(reader.GetOrdinal("data_type")),
            Description = reader.IsDBNull(reader.GetOrdinal("description")) ? null : reader.GetString(reader.GetOrdinal("description")),
        };
    }
}