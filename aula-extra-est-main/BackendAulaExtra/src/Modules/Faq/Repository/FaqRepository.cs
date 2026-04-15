using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Faq.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Faq.Repository
{
    public class FaqRepository : IFaqRepository
    {
        private readonly string _connectionString;

        public FaqRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<FaqEntry>> GetPublicFaqsAsync(Guid? idFaqCategory = null, string? query = null)
        {
            var list = new List<FaqEntry>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_faq_select_public01(@p_id_faq_category, @p_query);";
            cmd.Parameters.AddWithValue("p_id_faq_category", (object?)idFaqCategory ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_query", (object?)query ?? DBNull.Value);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new FaqEntry
                {
                    IdFaq = reader.GetGuid(reader.GetOrdinal("id_faq")),
                    IdFaqCategory = reader.GetGuid(reader.GetOrdinal("id_faq_category")),
                    Question = reader.GetString(reader.GetOrdinal("question")),
                    Description = reader.GetString(reader.GetOrdinal("description")),
                    CategoryName = reader.GetString(reader.GetOrdinal("category")),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at"),
                    UserId = GetNullableGuid(reader, "user_id")
                });
            }

            return list;
        }

        public async Task<IEnumerable<FaqCategorySummary>> GetPublicCategoriesAsync()
        {
            var list = new List<FaqCategorySummary>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_faq_categories_select_public01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new FaqCategorySummary
                {
                    IdFaqCategory = reader.GetGuid(reader.GetOrdinal("id_faq_category")),
                    Category = reader.GetString(reader.GetOrdinal("category")),
                    Description = GetNullableString(reader, "description"),
                    FaqCount = reader.GetInt32(reader.GetOrdinal("faq_count"))
                });
            }

            return list;
        }

        public async Task<IEnumerable<FaqEntry>> GetFaqsAllAsync()
        {
            var list = new List<FaqEntry>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    f.id_faq,
    f.id_faq_category,
    c.name AS category,
    f.question,
    f.description,
    f.created_at,
    f.updated_at,
    f.user_id
FROM public.faqs f
JOIN public.faq_categories c ON c.id_faq_category = f.id_faq_category
ORDER BY c.name ASC, f.question ASC;";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new FaqEntry
                {
                    IdFaq = reader.GetGuid(reader.GetOrdinal("id_faq")),
                    IdFaqCategory = reader.GetGuid(reader.GetOrdinal("id_faq_category")),
                    CategoryName = reader.GetString(reader.GetOrdinal("category")),
                    Question = reader.GetString(reader.GetOrdinal("question")),
                    Description = reader.GetString(reader.GetOrdinal("description")),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at"),
                    UserId = GetNullableGuid(reader, "user_id")
                });
            }

            return list;
        }

        public async Task<FaqEntry?> GetFaqByIdAsync(Guid idFaq)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    f.id_faq,
    f.id_faq_category,
    c.name AS category,
    f.question,
    f.description,
    f.created_at,
    f.updated_at,
    f.user_id
FROM public.faqs f
JOIN public.faq_categories c ON c.id_faq_category = f.id_faq_category
WHERE f.id_faq = @id_faq
LIMIT 1;";
            cmd.Parameters.AddWithValue("id_faq", idFaq);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new FaqEntry
            {
                IdFaq = reader.GetGuid(reader.GetOrdinal("id_faq")),
                IdFaqCategory = reader.GetGuid(reader.GetOrdinal("id_faq_category")),
                CategoryName = reader.GetString(reader.GetOrdinal("category")),
                Question = reader.GetString(reader.GetOrdinal("question")),
                Description = reader.GetString(reader.GetOrdinal("description")),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at"),
                UserId = GetNullableGuid(reader, "user_id")
            };
        }

        public async Task<Guid> InsertFaqAsync(FaqEntry faq)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
INSERT INTO public.faqs (
    id_faq_category,
    question,
    description,
    created_at,
    updated_at,
    user_id
)
VALUES (
    @id_faq_category,
    @question,
    @description,
    COALESCE(@created_at, now()),
    COALESCE(@updated_at, now()),
    @user_id
)
RETURNING id_faq;";
            cmd.Parameters.AddWithValue("id_faq_category", faq.IdFaqCategory);
            cmd.Parameters.AddWithValue("question", faq.Question);
            cmd.Parameters.AddWithValue("description", faq.Description);
            cmd.Parameters.AddWithValue("created_at", (object?)faq.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)faq.UpdatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("user_id", (object?)faq.UserId ?? DBNull.Value);

            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? Guid.Empty : (Guid)result;
        }

        public async Task<int> UpdateFaqAsync(FaqEntry faq)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
UPDATE public.faqs
SET
    id_faq_category = @id_faq_category,
    question = @question,
    description = @description,
    updated_at = COALESCE(@updated_at, now()),
    user_id = @user_id
WHERE id_faq = @id_faq;";
            cmd.Parameters.AddWithValue("id_faq", faq.IdFaq);
            cmd.Parameters.AddWithValue("id_faq_category", faq.IdFaqCategory);
            cmd.Parameters.AddWithValue("question", faq.Question);
            cmd.Parameters.AddWithValue("description", faq.Description);
            cmd.Parameters.AddWithValue("updated_at", (object?)faq.UpdatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("user_id", (object?)faq.UserId ?? DBNull.Value);

            return await cmd.ExecuteNonQueryAsync();
        }

        public async Task<int> DeleteFaqAsync(Guid idFaq)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "DELETE FROM public.faqs WHERE id_faq = @id_faq;";
            cmd.Parameters.AddWithValue("id_faq", idFaq);
            return await cmd.ExecuteNonQueryAsync();
        }

        public async Task<IEnumerable<FaqCategory>> GetCategoriesAllAsync()
        {
            var list = new List<FaqCategory>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    c.id_faq_category,
    c.name,
    c.description,
    c.created_at,
    c.updated_at,
    c.user_id
FROM public.faq_categories c
ORDER BY c.name ASC;";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new FaqCategory
                {
                    IdFaqCategory = reader.GetGuid(reader.GetOrdinal("id_faq_category")),
                    Name = reader.GetString(reader.GetOrdinal("name")),
                    Description = GetNullableString(reader, "description"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at"),
                    UserId = GetNullableGuid(reader, "user_id")
                });
            }

            return list;
        }

        public async Task<FaqCategory?> GetCategoryByIdAsync(Guid idFaqCategory)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    c.id_faq_category,
    c.name,
    c.description,
    c.created_at,
    c.updated_at,
    c.user_id
FROM public.faq_categories c
WHERE c.id_faq_category = @id_faq_category
LIMIT 1;";
            cmd.Parameters.AddWithValue("id_faq_category", idFaqCategory);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new FaqCategory
            {
                IdFaqCategory = reader.GetGuid(reader.GetOrdinal("id_faq_category")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Description = GetNullableString(reader, "description"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at"),
                UserId = GetNullableGuid(reader, "user_id")
            };
        }

        public async Task<Guid> InsertCategoryAsync(FaqCategory category)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
INSERT INTO public.faq_categories (
    name,
    description,
    created_at,
    updated_at,
    user_id
)
VALUES (
    @name,
    @description,
    COALESCE(@created_at, now()),
    COALESCE(@updated_at, now()),
    @user_id
)
RETURNING id_faq_category;";
            cmd.Parameters.AddWithValue("name", category.Name);
            cmd.Parameters.AddWithValue("description", (object?)category.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)category.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)category.UpdatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("user_id", (object?)category.UserId ?? DBNull.Value);

            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? Guid.Empty : (Guid)result;
        }

        public async Task<int> UpdateCategoryAsync(FaqCategory category)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
UPDATE public.faq_categories
SET
    name = @name,
    description = @description,
    updated_at = COALESCE(@updated_at, now()),
    user_id = @user_id
WHERE id_faq_category = @id_faq_category;";
            cmd.Parameters.AddWithValue("id_faq_category", category.IdFaqCategory);
            cmd.Parameters.AddWithValue("name", category.Name);
            cmd.Parameters.AddWithValue("description", (object?)category.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)category.UpdatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("user_id", (object?)category.UserId ?? DBNull.Value);

            return await cmd.ExecuteNonQueryAsync();
        }

        public async Task<int> DeleteCategoryAsync(Guid idFaqCategory)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "DELETE FROM public.faq_categories WHERE id_faq_category = @id_faq_category;";
            cmd.Parameters.AddWithValue("id_faq_category", idFaqCategory);
            return await cmd.ExecuteNonQueryAsync();
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

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try { return reader.GetFieldValue<DateTime>(idx); } catch { return null; }
        }
    }
}
