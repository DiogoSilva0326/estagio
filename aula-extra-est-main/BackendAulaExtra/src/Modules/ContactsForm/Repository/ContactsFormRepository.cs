using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.ContactsForm.Models;
using Npgsql;
using NpgsqlTypes;

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
            AddNullableTextParameter(cmd, "description", category.Description);
            AddNullableTimestampTzParameter(cmd, "created_at", category.CreatedAt == default ? null : category.CreatedAt);
            AddNullableTimestampTzParameter(cmd, "updated_at", category.UpdatedAt == default ? null : category.UpdatedAt);

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
            AddNullableTextParameter(cmd, "description", category.Description);
            AddNullableTimestampTzParameter(cmd, "updated_at", category.UpdatedAt == default ? null : category.UpdatedAt);

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
            AddNullableTextParameter(cmd, "status", status);

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

            AddNullableUuidParameter(cmd, "id_contact_form_category", submission.IdContactFormCategory);
            cmd.Parameters.AddWithValue("name", submission.Name);
            cmd.Parameters.AddWithValue("email", submission.Email);
            cmd.Parameters.AddWithValue("subject", submission.Subject);
            cmd.Parameters.AddWithValue("message", submission.Message);
            cmd.Parameters.AddWithValue("status", submission.Status);
            AddNullableUuidParameter(cmd, "user_id", submission.UserId);
            AddNullableUuidParameter(cmd, "user_id_response", submission.UserIdResponse);
            AddNullableTimestampTzParameter(cmd, "created_at", submission.CreatedAt == default ? null : submission.CreatedAt);
            AddNullableTimestampTzParameter(cmd, "updated_at", submission.UpdatedAt == default ? null : submission.UpdatedAt);

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
            AddNullableUuidParameter(cmd, "id_contact_form_category", submission.IdContactFormCategory);
            cmd.Parameters.AddWithValue("name", submission.Name);
            cmd.Parameters.AddWithValue("email", submission.Email);
            cmd.Parameters.AddWithValue("subject", submission.Subject);
            cmd.Parameters.AddWithValue("message", submission.Message);
            cmd.Parameters.AddWithValue("status", submission.Status);
            AddNullableUuidParameter(cmd, "user_id", submission.UserId);
            AddNullableUuidParameter(cmd, "user_id_response", submission.UserIdResponse);
            AddNullableTimestampTzParameter(cmd, "updated_at", submission.UpdatedAt == default ? null : submission.UpdatedAt);

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

        private static void AddNullableTextParameter(NpgsqlCommand cmd, string name, string? value)
        {
            cmd.Parameters.AddWithValue(name, NpgsqlDbType.Text, (object?)value ?? DBNull.Value);
        }

        private static void AddNullableUuidParameter(NpgsqlCommand cmd, string name, Guid? value)
        {
            cmd.Parameters.AddWithValue(name, NpgsqlDbType.Uuid, (object?)value ?? DBNull.Value);
        }

        private static void AddNullableTimestampTzParameter(NpgsqlCommand cmd, string name, DateTimeOffset? value)
        {
            cmd.Parameters.AddWithValue(name, NpgsqlDbType.TimestampTz, (object?)value ?? DBNull.Value);
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
