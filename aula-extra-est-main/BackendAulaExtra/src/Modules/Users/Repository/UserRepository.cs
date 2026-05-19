using System;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using ConfidantPostgreSQL.Modules.Users.Models;
using ConfidantPostgreSQL.Modules.Users.DTOs;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Users.Repository
{
    public class UserRepository : IUserRepository
    {
        private readonly string _connectionString;

        public UserRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<User?> GetByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            // Read directly from public.users to avoid depending on stored procs being up-to-date.
            cmd.CommandText = @"
                SELECT
                    id_user, email, password, first_name, last_name, education_level, birth_date,
                    biography, auth_message, username, display_name, mobile_number, phone_number, nif, website, inactive,
                    creation_date, last_update, last_user_id
                FROM public.users
                WHERE id_user = @p_id
                LIMIT 1;";
            cmd.Parameters.AddWithValue("p_id", id);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return MapUser(reader);
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            // Read directly from public.users to avoid depending on stored procs being up-to-date.
            cmd.CommandText = @"
                SELECT
                    id_user, email, password, first_name, last_name, education_level, birth_date,
                    biography, auth_message, username, display_name, mobile_number, phone_number, nif, website, inactive,
                    creation_date, last_update, last_user_id
                FROM public.users
                WHERE lower(email) = lower(@p_email)
                ORDER BY id_user
                LIMIT 1;";
            cmd.Parameters.AddWithValue("p_email", email);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapUser(reader);
        }

        public async Task<User?> GetByGoogleSubjectAsync(string googleSubject)
        {
            if (string.IsNullOrWhiteSpace(googleSubject)) return null;

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT
                    id_user, email, password, first_name, last_name, education_level, birth_date,
                    biography, auth_message, username, display_name, mobile_number, phone_number, nif, website, inactive,
                    creation_date, last_update, last_user_id
                FROM public.users
                WHERE google_subject = @p_google_subject
                ORDER BY id_user
                LIMIT 1;";
            cmd.Parameters.AddWithValue("p_google_subject", googleSubject.Trim());

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapUser(reader);
        }

        public async Task<User?> GetByUsernameAsync(string username)
        {
            if (string.IsNullOrWhiteSpace(username)) return null;

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT
                    id_user, email, password, first_name, last_name, education_level, birth_date,
                    biography, auth_message, username, display_name, mobile_number, phone_number, nif, website, inactive,
                    creation_date, last_update, last_user_id
                FROM public.users
                WHERE lower(username) = lower(@p_username)
                ORDER BY id_user
                LIMIT 1;";
            cmd.Parameters.AddWithValue("p_username", username.Trim());

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapUser(reader);
        }

        public async Task<IEnumerable<User>> GetAllAsync()
        {
            var list = new List<User>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_users_select_all01(NULL, '.AU-ID', 1, 10000);";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapUser(reader));
            }
            return list;
        }

        public async Task<IEnumerable<AdminStudentDirectoryItem>> GetAdminStudentDirectoryAsync()
        {
            var list = new List<AdminStudentDirectoryItem>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                WITH student_roles AS (
                    SELECT ur.user_id
                    FROM public.user_role ur
                    INNER JOIN public.role r ON r.id = ur.role_id
                    WHERE lower(r.description) = 'aluno'
                ),
                lesson_stats AS (
                    SELECT
                        e.id_user,
                        COUNT(*)::int AS sessions_count
                    FROM public.enrollments e
                    INNER JOIN public.lessons l ON l.id_lesson = e.id_lesson
                    GROUP BY e.id_user
                ),
                pack_stats AS (
                    SELECT
                        ulp.id_user,
                        COUNT(*) FILTER (WHERE COALESCE(ulp.status, '') = '' OR lower(ulp.status) IN ('active', 'ativo'))::int AS active_packs,
                        COALESCE(SUM(COALESCE(lp.total_price, 0)), 0)::numeric(18,2) AS total_spent
                    FROM public.user_lesson_packs ulp
                    INNER JOIN public.lesson_packs lp ON lp.id_lesson_pack = ulp.id_lesson_pack
                    GROUP BY ulp.id_user
                )
                SELECT
                    u.id_user,
                    COALESCE(NULLIF(TRIM(u.display_name), ''), NULLIF(TRIM(CONCAT_WS(' ', u.first_name, u.last_name)), ''), NULLIF(TRIM(u.username), ''), u.email) AS name,
                    COALESCE(u.email, '') AS email,
                    COALESCE(NULLIF(TRIM(u.education_level), ''), '—') AS school_year,
                    CASE
                        WHEN COALESCE(ps.active_packs, 0) > 0 THEN CONCAT(ps.active_packs, ' plano(s) ativo(s)')
                        ELSE 'Sem plano ativo'
                    END AS plan_label,
                    CONCAT(COALESCE(ls.sessions_count, 0), ' sessões') AS sessions_label,
                    CASE
                        WHEN COALESCE(u.inactive, false) OR COALESCE(up.inactive, false) THEN 'INATIVO'
                        ELSE 'ATIVO'
                    END AS status_label,
                    CASE
                        WHEN COALESCE(u.inactive, false) OR COALESCE(up.inactive, false) THEN 'Conta inativa'
                        ELSE 'Conta ativa'
                    END AS account_state_label,
                    COALESCE(up.total_spent, ps.total_spent, 0)::numeric(18,2) AS total_spent,
                    COALESCE(ps.active_packs, 0) AS active_lesson_packs,
                    COALESCE(ls.sessions_count, 0) AS sessions_count
                FROM public.users u
                INNER JOIN student_roles sr ON sr.user_id = u.id_user
                LEFT JOIN public.user_profile up ON up.user_id = u.id_user
                LEFT JOIN lesson_stats ls ON ls.id_user = u.id_user
                LEFT JOIN pack_stats ps ON ps.id_user = u.id_user
                ORDER BY u.last_update DESC, u.creation_date DESC, u.id_user DESC;";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new AdminStudentDirectoryItem
                {
                    UserId = reader.GetGuid(reader.GetOrdinal("id_user")),
                    Name = GetNullableString(reader, "name") ?? "Aluno",
                    Email = GetNullableString(reader, "email") ?? string.Empty,
                    SchoolYear = GetNullableString(reader, "school_year") ?? "—",
                    PlanLabel = GetNullableString(reader, "plan_label") ?? "Sem plano ativo",
                    SessionsLabel = GetNullableString(reader, "sessions_label") ?? "0 sessões",
                    StatusLabel = GetNullableString(reader, "status_label") ?? "ATIVO",
                    AccountStateLabel = GetNullableString(reader, "account_state_label") ?? "Conta ativa",
                    TotalSpent = GetNullableDecimal(reader, "total_spent") ?? 0m,
                    ActiveLessonPacks = GetNullableInt(reader, "active_lesson_packs") ?? 0,
                    SessionsCount = GetNullableInt(reader, "sessions_count") ?? 0,
                });
            }

            return list;
        }

        public async Task<Guid> InsertAsync(User user)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            // Insert directly into public.users to avoid dependency on stored procs during bootstrap.
            cmd.CommandText = @"
                INSERT INTO public.users (
                    email, password, first_name, last_name, education_level, biography, username, display_name, birth_date,
                    auth_message, mobile_number, nif, inactive, creation_date, last_update, last_user_id, google_subject
                ) VALUES (
                    @p_email, @p_password, @p_first_name, @p_last_name, @p_education_level, @p_biography, COALESCE(@p_username, @p_email), @p_display_name, @p_birth_date,
                    @p_auth_message, @p_mobile_number, @p_nif, COALESCE(@p_inactive, false), now(), now(), @p_last_user_id, @p_google_subject
                ) RETURNING id_user;";

            cmd.Parameters.AddWithValue("p_email", (object?)user.Email ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_password", (object?)user.Password ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_first_name", (object?)user.FirstName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_last_name", (object?)user.LastName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_education_level", (object?)user.EducationLevel ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_biography", (object?)user.Biography ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_username", (object?)user.Username ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_display_name", (object?)user.DisplayName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_birth_date", (object?)user.BirthDate ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_auth_message", (object?)user.AuthMessage ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_mobile_number", (object?)user.MobileNumber ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_nif", (object?)user.Nif ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_inactive", (object?)(user.Inactive) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_last_user_id", (object?)user.LastUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_google_subject", (object?)user.GoogleSubject ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            var userId = res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
            if (userId != Guid.Empty)
            {
                await EnsureDefaultRoleAsync(conn, userId);
            }
            return userId;
        }

        public async Task<IReadOnlyList<string>> GetRoleDescriptionsAsync(Guid userId)
        {
            var roles = new List<string>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT r.description
                FROM public.user_role ur
                JOIN public.role r ON r.id = ur.role_id
                WHERE ur.user_id = @p_user_id
                ORDER BY r.id;";
            cmd.Parameters.AddWithValue("p_user_id", userId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                if (!reader.IsDBNull(0)) roles.Add(reader.GetString(0));
            }
            return roles;
        }

        public async Task<bool> EnsureRoleAsync(Guid userId, string roleDescription)
        {
            if (userId == Guid.Empty) return false;
            if (string.IsNullOrWhiteSpace(roleDescription)) return false;

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            int? roleId = null;
            await using (var roleCmd = conn.CreateCommand())
            {
                roleCmd.CommandText = @"
                    SELECT id
                    FROM public.role
                    WHERE lower(description) = lower(@p_desc)
                    LIMIT 1;";
                roleCmd.Parameters.AddWithValue("p_desc", roleDescription.Trim());
                var res = await roleCmd.ExecuteScalarAsync();
                if (res != null && res != DBNull.Value) roleId = Convert.ToInt32(res);
            }

            if (roleId == null)
            {
                await using var createRoleCmd = conn.CreateCommand();
                createRoleCmd.CommandText = @"
                    INSERT INTO public.role (description)
                    VALUES (@p_desc)
                    ON CONFLICT (description) DO UPDATE SET description = EXCLUDED.description
                    RETURNING id;";
                createRoleCmd.Parameters.AddWithValue("p_desc", roleDescription.Trim());
                var createdRole = await createRoleCmd.ExecuteScalarAsync();
                if (createdRole != null && createdRole != DBNull.Value)
                {
                    roleId = Convert.ToInt32(createdRole);
                }
            }

            if (roleId == null) return false;

            await using var insCmd = conn.CreateCommand();
            insCmd.CommandText = @"
                INSERT INTO public.user_role (user_id, role_id)
                VALUES (@p_user_id, @p_role_id)
                ON CONFLICT DO NOTHING;";
            insCmd.Parameters.AddWithValue("p_user_id", userId);
            insCmd.Parameters.AddWithValue("p_role_id", roleId.Value);

            await insCmd.ExecuteNonQueryAsync();
            return true;
        }

        public async Task<bool> SetGoogleSubjectAsync(Guid userId, string googleSubject)
        {
            if (userId == Guid.Empty) return false;
            if (string.IsNullOrWhiteSpace(googleSubject)) return false;

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                UPDATE public.users
                SET google_subject = @p_google_subject,
                    last_update = now()
                WHERE id_user = @p_user_id
                  AND (google_subject IS NULL OR google_subject = @p_google_subject);";
            cmd.Parameters.AddWithValue("p_user_id", userId);
            cmd.Parameters.AddWithValue("p_google_subject", googleSubject.Trim());

            var rows = await cmd.ExecuteNonQueryAsync();
            return rows > 0;
        }

        public async Task<bool> RemoveRoleAsync(Guid userId, string roleDescription)
        {
            if (userId == Guid.Empty) return false;
            if (string.IsNullOrWhiteSpace(roleDescription)) return false;

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                DELETE FROM public.user_role ur
                USING public.role r
                WHERE ur.role_id = r.id
                  AND ur.user_id = @p_user_id
                  AND lower(r.description) = lower(@p_desc);";
            cmd.Parameters.AddWithValue("p_user_id", userId);
            cmd.Parameters.AddWithValue("p_desc", roleDescription.Trim());

            await cmd.ExecuteNonQueryAsync();
            return true;
        }

        private static async Task EnsureDefaultRoleAsync(NpgsqlConnection conn, Guid userId)
        {
            // If roles table exists, assign new users to 'aluno' (fallback to 'Standard').
            int? roleId = null;
            await using (var roleCmd = conn.CreateCommand())
            {
                roleCmd.CommandText = @"
                    SELECT id
                    FROM public.role
                    WHERE description IN ('aluno','Standard')
                    ORDER BY CASE WHEN description='aluno' THEN 0 ELSE 1 END, id
                    LIMIT 1;";
                var res = await roleCmd.ExecuteScalarAsync();
                if (res != null && res != DBNull.Value) roleId = Convert.ToInt32(res);
            }

            if (roleId == null) return;

            await using var insCmd = conn.CreateCommand();
            insCmd.CommandText = @"
                INSERT INTO public.user_role (user_id, role_id)
                VALUES (@p_user_id, @p_role_id)
                ON CONFLICT DO NOTHING;";
            insCmd.Parameters.AddWithValue("p_user_id", userId);
            insCmd.Parameters.AddWithValue("p_role_id", roleId.Value);
            await insCmd.ExecuteNonQueryAsync();
        }

        public async Task<int> UpdateAsync(User user)
        {
            if (user.Id == null) throw new ArgumentNullException(nameof(user.Id));
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_users_update(@p_id::uuid, @p_email::text, @p_password::text, @p_first_name::text, @p_last_name::text, @p_username::text, @p_display_name::text, @p_mobile_number::text, @p_nif::text, @p_inactive::boolean, @p_last_user_id::uuid);";

            cmd.Parameters.AddWithValue("p_id", user.Id.Value);
            cmd.Parameters.AddWithValue("p_email", (object?)user.Email ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_password", (object?)user.Password ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_first_name", (object?)user.FirstName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_last_name", (object?)user.LastName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_username", (object?)user.Username ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_display_name", (object?)user.DisplayName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_mobile_number", (object?)user.MobileNumber ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_nif", (object?)user.Nif ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_inactive", (object?)user.Inactive ?? DBNull.Value);
            cmd.Parameters.AddWithValue("p_last_user_id", (object?)user.LastUserId ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();

            // Simple delete by id; return id_user if deleted, otherwise 0
            cmd.CommandText = @"
                DELETE FROM public.users
                WHERE id_user = @p_id
                RETURNING id_user;";

            cmd.Parameters.AddWithValue("p_id", id);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : 1;
        }

        public async Task UpdateRolesAsync(Guid userId, IEnumerable<int> roleIds)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            // Remove existing roles
            await using (var delCmd = conn.CreateCommand())
            {
                delCmd.CommandText = "DELETE FROM user_role WHERE user_id = @userId";
                delCmd.Parameters.AddWithValue("userId", userId);
                await delCmd.ExecuteNonQueryAsync();
            }

            // Insert new roles
            foreach (var roleId in roleIds)
            {
                await using var insCmd = conn.CreateCommand();
                insCmd.CommandText = "INSERT INTO user_role (role_id, user_id) VALUES (@roleId, @userId)";
                insCmd.Parameters.AddWithValue("roleId", roleId);
                insCmd.Parameters.AddWithValue("userId", userId);
                await insCmd.ExecuteNonQueryAsync();
            }
        }

        public async Task<IReadOnlyList<UserNotificationDto>> GetNotificationsByUserIdAsync(Guid userId)
        {
            var list = new List<UserNotificationDto>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT
                    un.id_notification AS id,
                    COALESCE(un.type, '') AS type,
                    CASE
                        WHEN lower(COALESCE(un.type, '')) = 'marcar_aula' THEN 'Marcar Aula'
                        ELSE INITCAP(REPLACE(COALESCE(un.type, ''), '_', ' '))
                    END AS title,
                    COALESCE(un.message, '') AS message,
                    COALESCE(un.was_read, false) AS is_read,
                    un.created_at AS creation_date,
                    un.updated_at AS last_update
                FROM public.notifications un
                WHERE un.id_user = @p_user_id
                  AND COALESCE(un.was_read, false) = false
                ORDER BY COALESCE(un.updated_at, un.created_at) DESC NULLS LAST,
                         un.id_notification DESC;";
            cmd.Parameters.AddWithValue("p_user_id", userId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new UserNotificationDto
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    Type = GetNullableString(reader, "type") ?? string.Empty,
                    Title = GetNullableString(reader, "title") ?? string.Empty,
                    Message = GetNullableString(reader, "message") ?? string.Empty,
                    IsRead = !reader.IsDBNull(reader.GetOrdinal("is_read")) && reader.GetBoolean(reader.GetOrdinal("is_read")),
                    CreationDate = GetNullableDateTime(reader, "creation_date"),
                    LastUpdate = GetNullableDateTime(reader, "last_update")
                });
            }

            return list;
        }

        public async Task<bool> MarkNotificationAsReadAsync(Guid userId, Guid notificationId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                UPDATE public.notifications
                SET was_read = true,
                    updated_at = now()
                WHERE id_notification = @p_notification_id
                  AND id_user = @p_user_id
                  AND COALESCE(was_read, false) = false;";
            cmd.Parameters.AddWithValue("p_notification_id", notificationId);
            cmd.Parameters.AddWithValue("p_user_id", userId);
            var rows = await cmd.ExecuteNonQueryAsync();
            return rows > 0;
        }

        public async Task<int> MarkAllNotificationsAsReadAsync(Guid userId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                UPDATE public.notifications
                SET was_read = true,
                    updated_at = now()
                WHERE id_user = @p_user_id
                  AND COALESCE(was_read, false) = false;";
            cmd.Parameters.AddWithValue("p_user_id", userId);
            return await cmd.ExecuteNonQueryAsync();
        }

        public async Task<int> MarkLessonRequestNotificationsAsReadAsync(Guid userId, Guid reservationId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                UPDATE public.notifications
                SET was_read = true,
                    updated_at = now()
                WHERE id_user = @p_user_id
                  AND COALESCE(was_read, false) = false
                  AND lower(COALESCE(type, '')) = 'marcar_aula'
                  AND COALESCE(message, '') ILIKE '%' || @p_reservation_id || '%';";
            cmd.Parameters.AddWithValue("p_user_id", userId);
            cmd.Parameters.AddWithValue("p_reservation_id", reservationId.ToString());
            return await cmd.ExecuteNonQueryAsync();
        }

        private static User MapUser(NpgsqlDataReader reader)
        {
            var user = new User
            {
                Id = GetNullableGuid(reader, "id_user"),
                Email = GetNullableString(reader, "email"),
                Password = GetNullableString(reader, "password"),
                FirstName = GetNullableString(reader, "first_name"),
                LastName = GetNullableString(reader, "last_name"),
                EducationLevel = GetNullableString(reader, "education_level"),
                Biography = GetNullableString(reader, "biography"),
                BirthDate = GetNullableString(reader, "birth_date"),
                AuthMessage = GetNullableString(reader, "auth_message"),
                Username = GetNullableString(reader, "username"),
                DisplayName = GetNullableString(reader, "display_name"),
                MobileNumber = GetNullableString(reader, "mobile_number"),
                PhoneNumber = GetNullableString(reader, "phone_number"),
                Website = GetNullableString(reader, "website"),
                Nif = GetNullableString(reader, "nif"),
                GoogleSubject = GetNullableString(reader, "google_subject"),
                Inactive = GetBoolDefaultFalse(reader, "inactive")
            };

            user.CreationDate = GetNullableDateTime(reader, "creation_date");
            user.LastUpdate = GetNullableDateTime(reader, "last_update");
            user.LastUserId = GetNullableGuid(reader, "last_user_id");

            return user;
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            if (!TryGetOrdinal(reader, column, out var idx)) return null;
            return reader.IsDBNull(idx) ? null : reader.GetGuid(idx);
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            if (!TryGetOrdinal(reader, column, out var idx)) return null;
            return reader.IsDBNull(idx) ? null : reader.GetString(idx);
        }

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            if (!TryGetOrdinal(reader, column, out var idx)) return null;
            return reader.IsDBNull(idx) ? null : reader.GetInt32(idx);
        }

        private static decimal? GetNullableDecimal(NpgsqlDataReader reader, string column)
        {
            if (!TryGetOrdinal(reader, column, out var idx)) return null;
            return reader.IsDBNull(idx) ? null : reader.GetDecimal(idx);
        }

        /// <summary>
        /// Tenta obter string da coluna primária, fallback para coluna secundária (retrocompatibilidade migração)
        /// </summary>
        private static string? GetNullableStringWithFallback(NpgsqlDataReader reader, string primaryColumn, string fallbackColumn)
        {
            if (TryGetOrdinal(reader, primaryColumn, out var primaryIdx))
                return reader.IsDBNull(primaryIdx) ? null : reader.GetString(primaryIdx);

            if (TryGetOrdinal(reader, fallbackColumn, out var fallbackIdx))
                return reader.IsDBNull(fallbackIdx) ? null : reader.GetString(fallbackIdx);

            return null;
        }

        private static bool GetBoolDefaultFalse(NpgsqlDataReader reader, string column)
        {
            if (!TryGetOrdinal(reader, column, out var idx)) return false;
            return reader.IsDBNull(idx) ? false : reader.GetBoolean(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            if (!TryGetOrdinal(reader, column, out var idx)) return null;
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

        private static bool TryGetOrdinal(NpgsqlDataReader reader, string column, out int ordinal)
        {
            try
            {
                ordinal = reader.GetOrdinal(column);
                return true;
            }
            catch (IndexOutOfRangeException)
            {
                ordinal = -1;
                return false;
            }
        }
    }
}
