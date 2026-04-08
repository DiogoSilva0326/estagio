using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Education.Models;
using ConfidantPostgreSQL.Modules.Professors.Models;
using Npgsql;
using NpgsqlTypes;

namespace ConfidantPostgreSQL.Modules.Professors.Repository
{
    public class ProfessorsRepository : IProfessorsRepository
    {
        private readonly string _connectionString;

        public ProfessorsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Professor>> GetProfessorsAllAsync()
        {
            var list = new List<Professor>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professors_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessor(reader));
            }
            return list;
        }

        public async Task<ProfessorStats> GetProfessorStatsAsync(Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    COALESCE((
        SELECT AVG(pf.rating::numeric)
        FROM professor_feedback pf
        WHERE pf.id_professor = @id_professor
            AND pf.is_valid = TRUE
            AND pf.rating IS NOT NULL
    ), 0) AS avg_rating,
    COALESCE((
        SELECT COUNT(*)
        FROM professor_feedback pf
        WHERE pf.id_professor = @id_professor
            AND pf.is_valid = TRUE
            AND pf.rating IS NOT NULL
    ), 0) AS review_count,
    COALESCE((
        SELECT COUNT(*)
        FROM lessons l
        WHERE l.id_professor = @id_professor
    ), 0) AS lessons_count;
";

            cmd.Parameters.AddWithValue("id_professor", idProfessor);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync())
            {
                return new ProfessorStats();
            }

            return new ProfessorStats
            {
                AvgRating = reader.IsDBNull(reader.GetOrdinal("avg_rating")) ? 0 : reader.GetDecimal(reader.GetOrdinal("avg_rating")),
                ReviewCount = reader.IsDBNull(reader.GetOrdinal("review_count")) ? 0 : reader.GetInt32(reader.GetOrdinal("review_count")),
                LessonsCount = reader.IsDBNull(reader.GetOrdinal("lessons_count")) ? 0 : reader.GetInt32(reader.GetOrdinal("lessons_count")),
            };
        }

                public async Task<TutorBrowseResponse> BrowseTutorsAsync(TutorBrowseQuery query)
                {
                        query ??= new TutorBrowseQuery();

                        var page = query.Page < 1 ? 1 : query.Page;
                        var pageSize = query.PageSize;
                        if (pageSize < 1) pageSize = 1;
                        if (pageSize > 50) pageSize = 50;

                        var offset = (page - 1) * pageSize;

                        var availabilityMode = (query.Morning || query.Afternoon || query.Evening || query.Weekend) ? 1 : 0;

                        var response = new TutorBrowseResponse
                        {
                                Page = page,
                                PageSize = pageSize,
                                Total = 0,
                                Items = new List<TutorBrowseItem>()
                        };

                        await using var conn = new NpgsqlConnection(_connectionString);
                        await conn.OpenAsync();
                        await using var cmd = conn.CreateCommand();

                        cmd.CommandText = @"
WITH base AS (
    SELECT
        p.id_professor,
        CONCAT_WS(' ', NULLIF(u.first_name, ''), NULLIF(u.last_name, '')) AS user_name,
        u.display_name,
        u.username,
        p.current_school,
        p.biography
    FROM professors p
    JOIN users u ON u.id_user = p.id_user
    WHERE COALESCE(p.is_active, TRUE) = TRUE
        AND COALESCE(p.is_verified, FALSE) = TRUE
        AND (
            @q IS NULL
            OR CONCAT_WS(' ', COALESCE(u.first_name, ''), COALESCE(u.last_name, '')) ILIKE '%' || @q || '%'
            OR COALESCE(u.display_name, '') ILIKE '%' || @q || '%'
            OR COALESCE(u.username, '') ILIKE '%' || @q || '%'
            OR EXISTS (
                SELECT 1
                FROM courses c
                JOIN disciplinas d ON d.id_disciplina = c.id_disciplina
                WHERE c.id_professor = p.id_professor
                    AND d.nome ILIKE '%' || @q || '%'
            )
        )
        AND (
            @area_id IS NULL
            OR EXISTS (
                SELECT 1
                FROM courses c
                JOIN disciplinas d ON d.id_disciplina = c.id_disciplina
                WHERE c.id_professor = p.id_professor
                    AND d.id_area = @area_id
            )
        )
        AND (
            @disciplina_id IS NULL
            OR EXISTS (
                SELECT 1
                FROM courses c
                WHERE c.id_professor = p.id_professor
                    AND c.id_disciplina = @disciplina_id
            )
        )
        AND (
            @ciclo_id IS NULL
            OR EXISTS (
                SELECT 1
                FROM courses c
                WHERE c.id_professor = p.id_professor
                    AND c.id_ciclo_estudo = @ciclo_id
            )
        )
        AND (
            @ano_id IS NULL
            OR EXISTS (
                SELECT 1
                FROM courses c
                WHERE c.id_professor = p.id_professor
                    AND c.id_ano_escolaridade = @ano_id
            )
        )
        AND (
            @max_price IS NULL
            OR EXISTS (
                SELECT 1
                FROM courses c
                JOIN course_prices cp ON cp.id_course = c.id_course AND cp.active = TRUE
                WHERE c.id_professor = p.id_professor
                    AND cp.session_price IS NOT NULL
                    AND cp.session_price <= @max_price
            )
        )
        AND (
            @min_rating IS NULL
            OR COALESCE((
                SELECT AVG(pf.rating::numeric)
                FROM professor_feedback pf
                WHERE pf.id_professor = p.id_professor
                    AND pf.is_valid = TRUE
                    AND pf.rating IS NOT NULL
            ), 0) >= @min_rating
        )
        AND (
            @availability_mode = 0
            OR (
                (@avail_morning = TRUE AND EXISTS (
                    SELECT 1
                    FROM schedule_blocks sb
                    WHERE sb.id_professor = p.id_professor
                        AND sb.is_available = TRUE
                        AND sb.start_time IS NOT NULL
                        AND EXTRACT(HOUR FROM sb.start_time) < 12
                ))
                OR (@avail_afternoon = TRUE AND EXISTS (
                    SELECT 1
                    FROM schedule_blocks sb
                    WHERE sb.id_professor = p.id_professor
                        AND sb.is_available = TRUE
                        AND sb.start_time IS NOT NULL
                        AND EXTRACT(HOUR FROM sb.start_time) >= 12
                        AND EXTRACT(HOUR FROM sb.start_time) < 18
                ))
                OR (@avail_evening = TRUE AND EXISTS (
                    SELECT 1
                    FROM schedule_blocks sb
                    WHERE sb.id_professor = p.id_professor
                        AND sb.is_available = TRUE
                        AND sb.start_time IS NOT NULL
                        AND EXTRACT(HOUR FROM sb.start_time) >= 18
                ))
                OR (@avail_weekend = TRUE AND EXISTS (
                    SELECT 1
                    FROM schedule_blocks sb
                    WHERE sb.id_professor = p.id_professor
                        AND sb.is_available = TRUE
                        AND sb.start_time IS NOT NULL
                        AND EXTRACT(DOW FROM sb.start_time) IN (0, 6)
                ))
            )
        )
)
SELECT
    b.id_professor,
    COALESCE(NULLIF(TRIM(b.display_name), ''), NULLIF(TRIM(b.user_name), ''), NULLIF(TRIM(b.username), ''), 'Explicador') AS display_name,
    COALESCE(NULLIF(TRIM(b.current_school), ''), 'Online') AS subtitle,
    COALESCE(NULLIF(TRIM(b.biography), ''), 'Sem descrição') AS biography,
    COALESCE(r.avg_rating, 0) AS avg_rating,
    COALESCE(r.review_count, 0) AS review_count,
    COALESCE(pr.min_price, 0) AS min_price,
    COALESCE(ls.lessons_count, 0) AS lessons_count,
    COALESCE(tg.tags, ARRAY[]::text[]) AS tags,
    COUNT(*) OVER() AS total_count
FROM base b
LEFT JOIN LATERAL (
    SELECT AVG(pf.rating::numeric) AS avg_rating, COUNT(*) AS review_count
    FROM professor_feedback pf
    WHERE pf.id_professor = b.id_professor
        AND pf.is_valid = TRUE
        AND pf.rating IS NOT NULL
) r ON TRUE
LEFT JOIN LATERAL (
    SELECT MIN(cp.session_price) AS min_price
    FROM courses c
    JOIN course_prices cp ON cp.id_course = c.id_course AND cp.active = TRUE
    WHERE c.id_professor = b.id_professor
        AND cp.session_price IS NOT NULL
) pr ON TRUE
LEFT JOIN LATERAL (
    SELECT COUNT(*) AS lessons_count
    FROM lessons l
    WHERE l.id_professor = b.id_professor
) ls ON TRUE
LEFT JOIN LATERAL (
    SELECT ARRAY_AGG(DISTINCT d.nome) FILTER (WHERE d.nome IS NOT NULL) AS tags
    FROM courses c
    JOIN disciplinas d ON d.id_disciplina = c.id_disciplina
    WHERE c.id_professor = b.id_professor
) tg ON TRUE
ORDER BY r.avg_rating DESC NULLS LAST, r.review_count DESC, display_name ASC
OFFSET @offset
LIMIT @limit;
";

                        var q = string.IsNullOrWhiteSpace(query.Q) ? null : query.Q!.Trim();

                        cmd.Parameters.Add(new NpgsqlParameter("q", NpgsqlDbType.Text) { Value = (object?)q ?? DBNull.Value });
                        cmd.Parameters.Add(new NpgsqlParameter("area_id", NpgsqlDbType.Uuid) { Value = (object?)query.AreaId ?? DBNull.Value });
                        cmd.Parameters.Add(new NpgsqlParameter("disciplina_id", NpgsqlDbType.Uuid) { Value = (object?)query.DisciplinaId ?? DBNull.Value });
                        cmd.Parameters.Add(new NpgsqlParameter("ciclo_id", NpgsqlDbType.Uuid) { Value = (object?)query.CicloEstudoId ?? DBNull.Value });
                        cmd.Parameters.Add(new NpgsqlParameter("ano_id", NpgsqlDbType.Uuid) { Value = (object?)query.AnoEscolaridadeId ?? DBNull.Value });
                        cmd.Parameters.Add(new NpgsqlParameter("max_price", NpgsqlDbType.Numeric) { Value = (object?)query.MaxPrice ?? DBNull.Value });
                        cmd.Parameters.Add(new NpgsqlParameter("min_rating", NpgsqlDbType.Numeric) { Value = (object?)query.MinRating ?? DBNull.Value });

                        cmd.Parameters.Add(new NpgsqlParameter("availability_mode", NpgsqlDbType.Integer) { Value = availabilityMode });
                        cmd.Parameters.Add(new NpgsqlParameter("avail_morning", NpgsqlDbType.Boolean) { Value = query.Morning });
                        cmd.Parameters.Add(new NpgsqlParameter("avail_afternoon", NpgsqlDbType.Boolean) { Value = query.Afternoon });
                        cmd.Parameters.Add(new NpgsqlParameter("avail_evening", NpgsqlDbType.Boolean) { Value = query.Evening });
                        cmd.Parameters.Add(new NpgsqlParameter("avail_weekend", NpgsqlDbType.Boolean) { Value = query.Weekend });

                        cmd.Parameters.Add(new NpgsqlParameter("offset", NpgsqlDbType.Integer) { Value = offset });
                        cmd.Parameters.Add(new NpgsqlParameter("limit", NpgsqlDbType.Integer) { Value = pageSize });

                        await using var reader = await cmd.ExecuteReaderAsync();
                        while (await reader.ReadAsync())
                        {
                                var item = new TutorBrowseItem
                                {
                                        IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                                        Name = reader.GetString(reader.GetOrdinal("display_name")),
                                        Subtitle = reader.GetString(reader.GetOrdinal("subtitle")),
                                        Description = reader.GetString(reader.GetOrdinal("biography")),
                                        Rating = reader.IsDBNull(reader.GetOrdinal("avg_rating")) ? 0 : reader.GetDecimal(reader.GetOrdinal("avg_rating")),
                                        ReviewCount = reader.IsDBNull(reader.GetOrdinal("review_count")) ? 0 : reader.GetInt32(reader.GetOrdinal("review_count")),
                                        MinPrice = reader.IsDBNull(reader.GetOrdinal("min_price")) ? 0 : reader.GetDecimal(reader.GetOrdinal("min_price")),
                                        LessonsCount = reader.IsDBNull(reader.GetOrdinal("lessons_count")) ? 0 : reader.GetInt32(reader.GetOrdinal("lessons_count")),
                                };

                                var tagsOrdinal = reader.GetOrdinal("tags");
                                if (!reader.IsDBNull(tagsOrdinal))
                                {
                                        if (reader.GetValue(tagsOrdinal) is string[] arr)
                                        {
                                                item.Tags = new List<string>(arr);
                                        }
                                }

                                var totalOrdinal = reader.GetOrdinal("total_count");
                                if (!reader.IsDBNull(totalOrdinal))
                                {
                                        response.Total = Convert.ToInt32(reader.GetValue(totalOrdinal));
                                }

                                response.Items.Add(item);
                        }

                        return response;
                }

        public async Task<Professor?> GetProfessorByIdAsync(Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professors_select_details01(@id_professor);";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessor(reader);
        }

        public async Task<Professor?> GetProfessorByUserIdAsync(Guid idUser)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professors_select_by_user01(@id_user);";
            cmd.Parameters.AddWithValue("id_user", idUser);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessor(reader);
        }

        public async Task<Guid> InsertProfessorAsync(Professor professor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_professors_insert(@id_user, @current_school, @years_experience, @photo, @biography, @presentation_video_url, @vat, @iban, @iban_document_url, @is_verified_iban, @is_active, @is_verified, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("id_user", professor.IdUser);
            cmd.Parameters.AddWithValue("current_school", (object?)professor.CurrentSchool ?? DBNull.Value);
            cmd.Parameters.AddWithValue("years_experience", (object?)professor.YearsExperience ?? DBNull.Value);
            cmd.Parameters.AddWithValue("photo", (object?)professor.Photo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("biography", (object?)professor.Biography ?? DBNull.Value);
            cmd.Parameters.AddWithValue("presentation_video_url", (object?)professor.PresentationVideoUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("vat", (object?)professor.Vat ?? DBNull.Value);
            cmd.Parameters.AddWithValue("iban", (object?)professor.Iban ?? DBNull.Value);
            cmd.Parameters.AddWithValue("iban_document_url", (object?)professor.IbanDocumentUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_verified_iban", (object?)professor.IsVerifiedIban ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", (object?)professor.IsActive ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_verified", (object?)professor.IsVerified ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)professor.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)professor.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateProfessorAsync(Professor professor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professors_update(@id_professor, @id_user, @current_school, @years_experience, @photo, @biography, @presentation_video_url, @vat, @iban, @iban_document_url, @is_verified_iban, @is_active, @is_verified);";
            cmd.Parameters.AddWithValue("id_professor", professor.IdProfessor);
            cmd.Parameters.AddWithValue("id_user", professor.IdUser);
            cmd.Parameters.AddWithValue("current_school", (object?)professor.CurrentSchool ?? DBNull.Value);
            cmd.Parameters.AddWithValue("years_experience", (object?)professor.YearsExperience ?? DBNull.Value);
            cmd.Parameters.AddWithValue("photo", (object?)professor.Photo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("biography", (object?)professor.Biography ?? DBNull.Value);
            cmd.Parameters.AddWithValue("presentation_video_url", (object?)professor.PresentationVideoUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("vat", (object?)professor.Vat ?? DBNull.Value);
            cmd.Parameters.AddWithValue("iban", (object?)professor.Iban ?? DBNull.Value);
            cmd.Parameters.AddWithValue("iban_document_url", (object?)professor.IbanDocumentUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_verified_iban", (object?)professor.IsVerifiedIban ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", (object?)professor.IsActive ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_verified", (object?)professor.IsVerified ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteProfessorAsync(Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professors_delete(@id_professor);";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ProfessorFeedback>> GetProfessorFeedbackAllAsync()
        {
            var list = new List<ProfessorFeedback>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professor_feedback_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessorFeedback(reader));
            }
            return list;
        }

        public async Task<ProfessorFeedback?> GetProfessorFeedbackByIdAsync(Guid idProfessorFeedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professor_feedback_select_details01(@id_professor_feedback);";
            cmd.Parameters.AddWithValue("id_professor_feedback", idProfessorFeedback);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessorFeedback(reader);
        }

        public async Task<Guid> InsertProfessorFeedbackAsync(ProfessorFeedback feedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_professor_feedback_insert(@id_professor, @id_user, @is_valid, @rating, @comments, @created_at);";
            cmd.Parameters.AddWithValue("id_professor", feedback.IdProfessor);
            cmd.Parameters.AddWithValue("id_user", feedback.IdUser);
            cmd.Parameters.AddWithValue("is_valid", (object?)feedback.IsValid ?? DBNull.Value);
            cmd.Parameters.AddWithValue("rating", (object?)feedback.Rating ?? DBNull.Value);
            cmd.Parameters.AddWithValue("comments", (object?)feedback.Comments ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)feedback.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateProfessorFeedbackAsync(ProfessorFeedback feedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_feedback_update(@id_professor_feedback, @id_professor, @id_user, @is_valid, @rating, @comments, @created_at);";
            cmd.Parameters.AddWithValue("id_professor_feedback", feedback.IdProfessorFeedback);
            cmd.Parameters.AddWithValue("id_professor", feedback.IdProfessor);
            cmd.Parameters.AddWithValue("id_user", feedback.IdUser);
            cmd.Parameters.AddWithValue("is_valid", (object?)feedback.IsValid ?? DBNull.Value);
            cmd.Parameters.AddWithValue("rating", (object?)feedback.Rating ?? DBNull.Value);
            cmd.Parameters.AddWithValue("comments", (object?)feedback.Comments ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)feedback.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteProfessorFeedbackAsync(Guid idProfessorFeedback)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_feedback_delete(@id_professor_feedback);";
            cmd.Parameters.AddWithValue("id_professor_feedback", idProfessorFeedback);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Certificate>> GetCertificatesAllAsync()
        {
            var list = new List<Certificate>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_certificates_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapCertificate(reader));
            }
            return list;
        }

        public async Task<Certificate?> GetCertificateByIdAsync(Guid idCertificate)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_certificates_select_details01(@id_certificate);";
            cmd.Parameters.AddWithValue("id_certificate", idCertificate);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapCertificate(reader);
        }

        public async Task<IEnumerable<Certificate>> GetCertificatesByProfessorIdAsync(Guid idProfessor)
        {
            var list = new List<Certificate>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT *
FROM public.certificates
WHERE id_professor = @id_professor
ORDER BY created_at DESC, updated_at DESC;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapCertificate(reader));
            }

            return list;
        }

        public async Task<Guid> InsertCertificateAsync(Certificate cert)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT public.usp_certificates_insert(
    @id_professor::uuid,
    @name::varchar,
    @description::text,
    @file_url::text,
    @verified::boolean,
    @verified_by_user_id::uuid,
    @created_at::timestamp,
    @updated_at::timestamp
);";
            cmd.Parameters.AddWithValue("id_professor", cert.IdProfessor);
            cmd.Parameters.AddWithValue("name", (object?)cert.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("description", (object?)cert.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("file_url", (object?)cert.FileUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("verified", (object?)cert.Verified ?? DBNull.Value);
            cmd.Parameters.AddWithValue("verified_by_user_id", (object?)cert.VerifiedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)cert.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)cert.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateCertificateAsync(Certificate cert)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT public.usp_certificates_update(
    @id_certificate::uuid,
    @id_professor::uuid,
    @name::varchar,
    @description::text,
    @file_url::text,
    @verified::boolean,
    @verified_by_user_id::uuid
);";
            cmd.Parameters.AddWithValue("id_certificate", cert.IdCertificate);
            cmd.Parameters.AddWithValue("id_professor", cert.IdProfessor);
            cmd.Parameters.AddWithValue("name", (object?)cert.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("description", (object?)cert.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("file_url", (object?)cert.FileUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("verified", (object?)cert.Verified ?? DBNull.Value);
            cmd.Parameters.AddWithValue("verified_by_user_id", (object?)cert.VerifiedByUserId ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteCertificateAsync(Guid idCertificate)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_certificates_delete(@id_certificate);";
            cmd.Parameters.AddWithValue("id_certificate", idCertificate);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteCertificatesByProfessorIdAsync(Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "DELETE FROM public.certificates WHERE id_professor = @id_professor;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            return await cmd.ExecuteNonQueryAsync();
        }

        public async Task<IEnumerable<ProfessorRoom>> GetProfessorRoomsAllAsync()
        {
            var list = new List<ProfessorRoom>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professor_rooms_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessorRoom(reader));
            }
            return list;
        }

        public async Task<ProfessorRoom?> GetProfessorRoomByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_professor_rooms_select_details01(@id);";
            cmd.Parameters.AddWithValue("id", id);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessorRoom(reader);
        }

        public async Task<ProfessorRoom?> GetProfessorRoomByProfessorIdAsync(Guid professorId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT id, professor_id, professor_name, room_name, description, is_active, created_at, updated_at
FROM public.professor_rooms
WHERE professor_id = @professor_id
LIMIT 1;";
            cmd.Parameters.AddWithValue("professor_id", professorId);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessorRoom(reader);
        }

        public async Task<Guid> InsertProfessorRoomAsync(ProfessorRoom room)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_professor_rooms_insert(@professor_id, @professor_name, @room_name, @description, @is_active);";
            cmd.Parameters.AddWithValue("professor_id", room.ProfessorId);
            cmd.Parameters.AddWithValue("professor_name", room.ProfessorName);
            cmd.Parameters.AddWithValue("room_name", room.RoomName);
            cmd.Parameters.AddWithValue("description", (object?)room.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", room.IsActive);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateProfessorRoomAsync(ProfessorRoom room)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_rooms_update(@id, @professor_id, @professor_name, @room_name, @description, @is_active);";
            cmd.Parameters.AddWithValue("id", room.Id);
            cmd.Parameters.AddWithValue("professor_id", room.ProfessorId);
            cmd.Parameters.AddWithValue("professor_name", room.ProfessorName);
            cmd.Parameters.AddWithValue("room_name", room.RoomName);
            cmd.Parameters.AddWithValue("description", (object?)room.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("is_active", room.IsActive);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteProfessorRoomAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_rooms_delete(@id);";
            cmd.Parameters.AddWithValue("id", id);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ProfessorStudentDto>> GetAlunosByProfessorIdAsync(Guid professorUserId)
        {
            var list = new List<ProfessorStudentDto>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();

            cmd.CommandText = @"
                SELECT
                    u.id_user AS Id,
                    u.username AS Username,
                    TRIM(CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, ''))) AS Name,
                    u.first_name AS FirstName,
                    u.last_name AS LastName,
                    '' AS AvatarUrl,
                    (
                        SELECT STRING_AGG(subject.nome, ',' ORDER BY subject.nome)
                        FROM (
                            SELECT DISTINCT d.nome
                            FROM public.enrollments e2
                            INNER JOIN public.lessons l2 ON e2.id_lesson = l2.id_lesson
                            INNER JOIN public.courses c ON l2.id_course = c.id_course
                            INNER JOIN public.disciplinas d ON c.id_disciplina = d.id_disciplina
                            WHERE e2.id_user = u.id_user AND l2.id_professor = p.id_professor
                        ) AS subject
                    ) AS SubjectsJoined,
                    (
                        SELECT MAX(l3.scheduled_start)
                        FROM public.lessons l3
                        INNER JOIN public.enrollments e3 ON l3.id_lesson = e3.id_lesson
                        WHERE e3.id_user = u.id_user AND l3.id_professor = p.id_professor
                    ) AS LastLessonDate,
                    0.5 AS Progress
                FROM public.users u
                INNER JOIN public.enrollments e ON u.id_user = e.id_user
                INNER JOIN public.lessons l ON e.id_lesson = l.id_lesson
                INNER JOIN public.professors p ON l.id_professor = p.id_professor
                WHERE p.id_user = @ProfessorUserId
                GROUP BY u.id_user, u.username, u.first_name, u.last_name, p.id_professor";

            cmd.Parameters.AddWithValue("ProfessorUserId", professorUserId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                var subjectsStr = GetNullableString(reader, "SubjectsJoined");
                var lastLesson = GetNullableDateTime(reader, "LastLessonDate");

                list.Add(new ProfessorStudentDto
                {
                    Id = reader.GetGuid(reader.GetOrdinal("Id")),
                    Username = GetNullableString(reader, "Username") ?? string.Empty,
                    Name = GetNullableString(reader, "Name") ?? string.Empty,
                    FirstName = GetNullableString(reader, "FirstName"),
                    LastName = GetNullableString(reader, "LastName"),
                    AvatarUrl = GetNullableString(reader, "AvatarUrl") ?? string.Empty,
                    Subjects = string.IsNullOrEmpty(subjectsStr)
                        ? new List<string>()
                        : subjectsStr
                            .Split(',')
                            .Select(subject => subject.Trim())
                            .Where(subject => !string.IsNullOrWhiteSpace(subject))
                            .Distinct(StringComparer.OrdinalIgnoreCase)
                            .ToList(),
                    LastLessonDate = lastLesson?.ToString("dd/MM/yyyy") ?? "-",
                    Progress = 0.5,
                });

                if (string.IsNullOrWhiteSpace(list[^1].Name))
                {
                    list[^1].Name = list[^1].Username;
                }
            }

            return list;
        }

        public async Task<IEnumerable<Disciplina>> GetDisciplinasByProfessorIdAsync(Guid idProfessor)
        {
            var list = new List<Disciplina>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    d.id_disciplina,
    COALESCE(pd.id_area, d.id_area) AS id_area,
    a.nome AS area_nome,
    d.nome,
    d.descricao,
    pd.id_ciclo_estudo,
    d.created_at,
    COALESCE(pd.updated_at, d.updated_at) AS updated_at,
    COALESCE(ce.nome, '') AS ciclo_estudos,
    COALESCE(pd.is_active, TRUE) AS is_active,
    COUNT(DISTINCT e.id_user) AS active_students_count
FROM public.professor_disciplina pd
INNER JOIN public.disciplinas d
    ON d.id_disciplina = pd.id_disciplina
LEFT JOIN public.areas a
    ON a.id_area = COALESCE(pd.id_area, d.id_area)
LEFT JOIN public.ciclos_estudo ce
    ON ce.id_ciclo_estudo = pd.id_ciclo_estudo
LEFT JOIN public.courses c
    ON c.id_professor = pd.id_professor
   AND c.id_disciplina = pd.id_disciplina
LEFT JOIN public.lessons l
    ON l.id_course = c.id_course
   AND l.id_professor = pd.id_professor
LEFT JOIN public.enrollments e
    ON e.id_lesson = l.id_lesson
WHERE pd.id_professor = @id_professor
  AND COALESCE(pd.is_active, TRUE) = TRUE
GROUP BY
    d.id_disciplina,
    COALESCE(pd.id_area, d.id_area),
    a.nome,
    d.nome,
    d.descricao,
    pd.id_ciclo_estudo,
    d.created_at,
    COALESCE(pd.updated_at, d.updated_at),
    COALESCE(ce.nome, ''),
    COALESCE(pd.is_active, TRUE)
ORDER BY d.nome ASC;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapDisciplina(reader));
            }

            return list;
        }

        public async Task<int> UpsertDisciplinaForProfessorAsync(Guid idProfessor, ProfessorDisciplinaUpsert input, Guid? currentIdDisciplina = null)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var tx = await conn.BeginTransactionAsync();

            Guid resolvedDisciplinaId;

            await using (var resolveCmd = conn.CreateCommand())
            {
                resolveCmd.Transaction = tx;
                resolveCmd.CommandText = @"
SELECT public.usp_disciplinas_ensure_for_area01(@id_area, @nome, @descricao);";
                resolveCmd.Parameters.AddWithValue("id_area", input.IdArea);
                resolveCmd.Parameters.AddWithValue("nome", input.Nome.Trim());
                resolveCmd.Parameters.AddWithValue("descricao", (object?)input.Descricao ?? DBNull.Value);

                var resolved = await resolveCmd.ExecuteScalarAsync();
                resolvedDisciplinaId = resolved == null || resolved == DBNull.Value
                    ? Guid.Empty
                    : (Guid)resolved;
            }

            if (resolvedDisciplinaId == Guid.Empty)
            {
                await tx.RollbackAsync();
                return 0;
            }

            if (currentIdDisciplina.HasValue &&
                currentIdDisciplina.Value != Guid.Empty &&
                currentIdDisciplina.Value != resolvedDisciplinaId)
            {
                await using var deactivateCurrentCmd = conn.CreateCommand();
                deactivateCurrentCmd.Transaction = tx;
                deactivateCurrentCmd.CommandText = @"
UPDATE public.professor_disciplina
SET is_active = FALSE,
    updated_at = now()
WHERE id_professor = @id_professor
  AND id_disciplina = @current_id_disciplina;";
                deactivateCurrentCmd.Parameters.AddWithValue("id_professor", idProfessor);
                deactivateCurrentCmd.Parameters.AddWithValue("current_id_disciplina", currentIdDisciplina.Value);
                await deactivateCurrentCmd.ExecuteNonQueryAsync();
            }

            await using (var upsertCmd = conn.CreateCommand())
            {
                upsertCmd.Transaction = tx;
                upsertCmd.CommandText = @"
INSERT INTO public.professor_disciplina (
    id_professor,
    id_disciplina,
    id_area,
    id_ciclo_estudo,
    is_active,
    created_at,
    updated_at
)
VALUES (
    @id_professor,
    @id_disciplina,
    @id_area,
    @id_ciclo_estudo,
    @is_active,
    now(),
    now()
)
ON CONFLICT (id_professor, id_disciplina) DO UPDATE
SET id_area = EXCLUDED.id_area,
    id_ciclo_estudo = EXCLUDED.id_ciclo_estudo,
    is_active = EXCLUDED.is_active,
    updated_at = now();";
                upsertCmd.Parameters.AddWithValue("id_professor", idProfessor);
                upsertCmd.Parameters.AddWithValue("id_disciplina", resolvedDisciplinaId);
                upsertCmd.Parameters.AddWithValue("id_area", input.IdArea);
                upsertCmd.Parameters.AddWithValue("id_ciclo_estudo", input.IdCicloEstudo);
                upsertCmd.Parameters.AddWithValue("is_active", input.IsActive);
                await upsertCmd.ExecuteNonQueryAsync();
            }

            await tx.CommitAsync();
            return 1;
        }

        public async Task<int> SetDisciplinasForProfessorAsync(Guid idProfessor, Guid[] ids)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_disciplinas_set_for_professor01(@id_professor, @ids);";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);

            var idsParam = cmd.Parameters.Add("ids", NpgsqlDbType.Array | NpgsqlDbType.Uuid);
            idsParam.Value = (object?)ids ?? Array.Empty<Guid>();

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> RemoveDisciplinaForProfessorAsync(Guid idProfessor, Guid idDisciplina)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_disciplinas_delete_for_professor01(@id_professor, @id_disciplina);";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            cmd.Parameters.AddWithValue("id_disciplina", idDisciplina);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<ProfessorLanguage>> GetLanguagesCatalogAsync()
        {
            var list = new List<ProfessorLanguage>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    l.id_language,
    l.nome,
    NULL::varchar AS proficiency_level,
    l.created_at,
    l.updated_at
FROM public.languages l
ORDER BY l.nome ASC;";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessorLanguage(reader));
            }

            return list;
        }

        public async Task<IEnumerable<ProfessorLanguage>> GetLanguagesByProfessorIdAsync(Guid idProfessor)
        {
            var list = new List<ProfessorLanguage>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    l.id_language,
    l.nome,
    pl.proficiency_level,
    pl.created_at,
    pl.updated_at
FROM public.professor_languages pl
JOIN public.languages l ON l.id_language = pl.id_language
WHERE pl.id_professor = @id_professor
ORDER BY l.nome ASC;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessorLanguage(reader));
            }

            return list;
        }

        public async Task<int> SetLanguagesForProfessorAsync(Guid idProfessor, ProfessorLanguage[] items)
        {
            var normalizedItems = (items ?? Array.Empty<ProfessorLanguage>())
                .Where(item => item != null && item.IdLanguage != Guid.Empty)
                .GroupBy(item => item.IdLanguage)
                .Select(group => group.First())
                .ToArray();

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var tx = await conn.BeginTransactionAsync();

            await using (var deleteCmd = conn.CreateCommand())
            {
                deleteCmd.Transaction = tx;
                deleteCmd.CommandText = "DELETE FROM public.professor_languages WHERE id_professor = @id_professor;";
                deleteCmd.Parameters.AddWithValue("id_professor", idProfessor);
                await deleteCmd.ExecuteNonQueryAsync();
            }

            var count = 0;
            foreach (var item in normalizedItems)
            {
                await using var insertCmd = conn.CreateCommand();
                insertCmd.Transaction = tx;
                insertCmd.CommandText = @"
INSERT INTO public.professor_languages (
    id_professor,
    id_language,
    proficiency_level,
    created_at,
    updated_at
)
VALUES (
    @id_professor,
    @id_language,
    @proficiency_level,
    now(),
    now()
);";
                insertCmd.Parameters.AddWithValue("id_professor", idProfessor);
                insertCmd.Parameters.AddWithValue("id_language", item.IdLanguage);
                insertCmd.Parameters.AddWithValue("proficiency_level", (object?)item.ProficiencyLevel ?? DBNull.Value);
                count += await insertCmd.ExecuteNonQueryAsync();
            }

            await tx.CommitAsync();
            return count;
        }

        public async Task<int> RemoveLanguageForProfessorAsync(Guid idProfessor, Guid idLanguage)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
DELETE FROM public.professor_languages
WHERE id_professor = @id_professor
  AND id_language = @id_language;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            cmd.Parameters.AddWithValue("id_language", idLanguage);
            return await cmd.ExecuteNonQueryAsync();
        }

        private static Professor MapProfessor(NpgsqlDataReader reader)
        {
            return new Professor
            {
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                CurrentSchool = GetNullableString(reader, "current_school"),
                YearsExperience = GetNullableInt(reader, "years_experience"),
                Photo = GetNullableString(reader, "photo"),
                Biography = GetNullableString(reader, "biography"),
                PresentationVideoUrl = GetNullableString(reader, "presentation_video_url"),
                Vat = GetNullableString(reader, "vat"),
                Iban = GetNullableString(reader, "iban"),
                IbanDocumentUrl = GetNullableString(reader, "iban_document_url"),
                IsVerifiedIban = GetNullableBool(reader, "is_verified_iban"),
                IsActive = GetNullableBool(reader, "is_active"),
                IsVerified = GetNullableBool(reader, "is_verified"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        private static ProfessorLanguage MapProfessorLanguage(NpgsqlDataReader reader)
        {
            return new ProfessorLanguage
            {
                IdLanguage = reader.GetGuid(reader.GetOrdinal("id_language")),
                Nome = GetNullableString(reader, "nome") ?? string.Empty,
                ProficiencyLevel = GetNullableString(reader, "proficiency_level"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at"),
            };
        }

        private static Disciplina MapDisciplina(NpgsqlDataReader reader)
        {
            return new Disciplina
            {
                IdDisciplina = reader.GetGuid(reader.GetOrdinal("id_disciplina")),
                IdArea = GetNullableGuid(reader, "id_area"),
                AreaNome = GetNullableString(reader, "area_nome"),
                Nome = reader.GetString(reader.GetOrdinal("nome")),
                Descricao = GetNullableString(reader, "descricao"),
                IdCicloEstudo = GetNullableGuid(reader, "id_ciclo_estudo"),
                CicloEstudos = GetNullableString(reader, "ciclo_estudos"),
                ActiveStudentsCount = GetNullableInt(reader, "active_students_count") ?? 0,
                IsActive = GetNullableBool(reader, "is_active") ?? true,
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at"),
            };
        }

        private static ProfessorFeedback MapProfessorFeedback(NpgsqlDataReader reader)
        {
            return new ProfessorFeedback
            {
                IdProfessorFeedback = reader.GetGuid(reader.GetOrdinal("id_professor_feedback")),
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                IsValid = GetNullableBool(reader, "is_valid"),
                Rating = GetNullableInt(reader, "rating"),
                Comments = GetNullableString(reader, "comments"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static Certificate MapCertificate(NpgsqlDataReader reader)
        {
            return new Certificate
            {
                IdCertificate = reader.GetGuid(reader.GetOrdinal("id_certificate")),
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                Name = GetNullableString(reader, "name"),
                Description = GetNullableString(reader, "description"),
                FileUrl = GetNullableString(reader, "file_url"),
                Verified = GetNullableBool(reader, "verified"),
                VerifiedByUserId = GetNullableGuid(reader, "verified_by_user_id"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        private static ProfessorRoom MapProfessorRoom(NpgsqlDataReader reader)
        {
            return new ProfessorRoom
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                ProfessorId = reader.GetGuid(reader.GetOrdinal("professor_id")),
                ProfessorName = reader.GetString(reader.GetOrdinal("professor_name")),
                RoomName = reader.GetString(reader.GetOrdinal("room_name")),
                Description = GetNullableString(reader, "description"),
                IsActive = reader.GetBoolean(reader.GetOrdinal("is_active")),
                CreatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("created_at")),
                UpdatedAt = reader.GetFieldValue<DateTimeOffset>(reader.GetOrdinal("updated_at"))
            };
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

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetInt32(idx);
        }

        private static bool? GetNullableBool(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetBoolean(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try { return reader.GetFieldValue<DateTime>(idx); } catch { return null; }
        }
    }
}
