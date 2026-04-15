using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.ContactsForm.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.ContactsForm.Repository
{
    public class ContactsFormRepository : IContactsFormRepository
    {
        private readonly string _connectionString;

        public ContactsFormRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<ContactFormCategory>> GetContactFormCategoriesAllAsync()
        {
            var list = new List<ContactFormCategory>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_contact_form_categories_select_all01();";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapContactFormCategory(reader));
            }

            return list;
        }

        public async Task<ContactFormCategory?> GetContactFormCategoryByIdAsync(Guid idContactFormCategory)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_contact_form_categories_select_details01(@id_contact_form_category);";
            cmd.Parameters.AddWithValue("id_contact_form_category", idContactFormCategory);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return MapContactFormCategory(reader);
        }

        public async Task<Guid> InsertContactFormCategoryAsync(ContactFormCategory category)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_contact_form_categories_insert(
                @name,
                @description,
                @created_at,
                @updated_at
            );";

            cmd.Parameters.AddWithValue("name", category.Name);
            cmd.Parameters.AddWithValue("description", (object?)category.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", category.CreatedAt == default ? DBNull.Value : category.CreatedAt);
            cmd.Parameters.AddWithValue("updated_at", category.UpdatedAt == default ? DBNull.Value : category.UpdatedAt);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateContactFormCategoryAsync(ContactFormCategory category)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_contact_form_categories_update(
                @id_contact_form_category,
                @name,
                @description,
                @updated_at
            );";

            cmd.Parameters.AddWithValue("id_contact_form_category", category.IdContactFormCategory);
            cmd.Parameters.AddWithValue("name", category.Name);
            cmd.Parameters.AddWithValue("description", (object?)category.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", category.UpdatedAt == default ? DBNull.Value : category.UpdatedAt);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteContactFormCategoryAsync(Guid idContactFormCategory)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_contact_form_categories_delete(@id_contact_form_category);";
            cmd.Parameters.AddWithValue("id_contact_form_category", idContactFormCategory);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ContactFormSubmission>> GetContactFormSubmissionsAllAsync(string? status = null)
        {
            var list = new List<ContactFormSubmission>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_contact_form_submissions_select_all01(@status);";
            cmd.Parameters.AddWithValue("status", (object?)status ?? DBNull.Value);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapContactFormSubmission(reader));
            }

            return list;
        }

        public async Task<ContactFormSubmission?> GetContactFormSubmissionByIdAsync(Guid idContactFormSubmission)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_contact_form_submissions_select_details01(@id_contact_form_submission);";
            cmd.Parameters.AddWithValue("id_contact_form_submission", idContactFormSubmission);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return MapContactFormSubmission(reader);
        }

        public async Task<Guid> InsertContactFormSubmissionAsync(ContactFormSubmission submission)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_contact_form_submissions_insert(
                @id_contact_form_category,
                @name,
                @email,
                @subject,
                @message,
                @status,
                @user_id,
                @user_id_response,
                @created_at,
                @updated_at
            );";

            cmd.Parameters.AddWithValue("id_contact_form_category", (object?)submission.IdContactFormCategory ?? DBNull.Value);
            cmd.Parameters.AddWithValue("name", submission.Name);
            cmd.Parameters.AddWithValue("email", submission.Email);
            cmd.Parameters.AddWithValue("subject", submission.Subject);
            cmd.Parameters.AddWithValue("message", submission.Message);
            cmd.Parameters.AddWithValue("status", submission.Status);
            cmd.Parameters.AddWithValue("user_id", (object?)submission.UserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("user_id_response", (object?)submission.UserIdResponse ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", submission.CreatedAt == default ? DBNull.Value : submission.CreatedAt);
            cmd.Parameters.AddWithValue("updated_at", submission.UpdatedAt == default ? DBNull.Value : submission.UpdatedAt);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateContactFormSubmissionAsync(ContactFormSubmission submission)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_contact_form_submissions_update(
                @id_contact_form_submission,
                @id_contact_form_category,
                @name,
                @email,
                @subject,
                @message,
                @status,
                @user_id,
                @user_id_response,
                @updated_at
            );";

            cmd.Parameters.AddWithValue("id_contact_form_submission", submission.IdContactFormSubmission);
            cmd.Parameters.AddWithValue("id_contact_form_category", (object?)submission.IdContactFormCategory ?? DBNull.Value);
            cmd.Parameters.AddWithValue("name", submission.Name);
            cmd.Parameters.AddWithValue("email", submission.Email);
            cmd.Parameters.AddWithValue("subject", submission.Subject);
            cmd.Parameters.AddWithValue("message", submission.Message);
            cmd.Parameters.AddWithValue("status", submission.Status);
            cmd.Parameters.AddWithValue("user_id", (object?)submission.UserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("user_id_response", (object?)submission.UserIdResponse ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", submission.UpdatedAt == default ? DBNull.Value : submission.UpdatedAt);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteContactFormSubmissionAsync(Guid idContactFormSubmission)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_contact_form_submissions_delete(@id_contact_form_submission);";
            cmd.Parameters.AddWithValue("id_contact_form_submission", idContactFormSubmission);

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

        private static ContactFormCategory MapContactFormCategory(NpgsqlDataReader reader)
        {
            return new ContactFormCategory
            {
                IdContactFormCategory = reader.GetGuid(reader.GetOrdinal("id_contact_form_category")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Description = GetNullableString(reader, "description"),
                CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
            };
        }

        private static ContactFormSubmission MapContactFormSubmission(NpgsqlDataReader reader)
        {
            return new ContactFormSubmission
            {
                IdContactFormSubmission = reader.GetGuid(reader.GetOrdinal("id_contact_form_submission")),
                IdContactFormCategory = GetNullableGuid(reader, "id_contact_form_category"),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Email = reader.GetString(reader.GetOrdinal("email")),
                Subject = reader.GetString(reader.GetOrdinal("subject")),
                Message = reader.GetString(reader.GetOrdinal("message")),
                Status = reader.GetString(reader.GetOrdinal("status")),
                UserId = GetNullableGuid(reader, "user_id"),
                UserIdResponse = GetNullableGuid(reader, "user_id_response"),
                CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at")),
                CategoryName = GetNullableString(reader, "category_name"),
                ResponseUserDisplayName = GetNullableString(reader, "response_user_display_name")
            };
        }
    }
}
