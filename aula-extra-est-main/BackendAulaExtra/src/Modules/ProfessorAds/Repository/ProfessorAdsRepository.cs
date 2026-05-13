using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.ProfessorAds.Models;
using Npgsql;
using NpgsqlTypes;

namespace ConfidantPostgreSQL.Modules.ProfessorAds.Repository
{
    public class ProfessorAdsRepository : IProfessorAdsRepository
    {
        private readonly string _connectionString;

        public ProfessorAdsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<ProfessorAd>> GetProfessorAdsByProfessorIdAsync(Guid idProfessor)
        {
            var list = new List<ProfessorAd>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = SelectAdsSql + " WHERE pa.id_professor = @id_professor ORDER BY COALESCE(pa.updated_at, pa.created_at) DESC, pa.created_at DESC;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(MapProfessorAd(reader));
            }

            return list;
        }

        public async Task<ProfessorAd?> GetProfessorAdByIdAsync(Guid idProfessorAd, Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            return await GetProfessorAdByIdInternalAsync(conn, null, idProfessorAd, idProfessor);
        }

        public async Task<ProfessorAd> UpsertProfessorAdAsync(Guid idProfessor, ProfessorAdUpsert input)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var tx = await conn.BeginTransactionAsync();

            var resolvedDiscipline = await ResolveProfessorDisciplineAsync(conn, tx, idProfessor, input.IdDisciplina);
            if (resolvedDiscipline == null)
            {
                throw new InvalidOperationException("Só pode publicar anúncios para disciplinas já adicionadas em Minhas Disciplinas.");
            }

            var discipline = resolvedDiscipline.Value;

            // REMOVIDA A VALIDAÇÃO QUE OBRIGAVA A TER CICLO DE ESTUDO AQUI

            var tutoringTypeName = await ResolveTutoringTypeNameAsync(conn, tx, input.IdTutoringType);
            if (string.IsNullOrWhiteSpace(tutoringTypeName))
            {
                throw new InvalidOperationException("Tipo de aula inválido.");
            }

            var pricingModelId = await ResolveDefaultPricingModelIdAsync(conn, tx);
            var courseId = await ResolveExistingCourseIdAsync(conn, tx, idProfessor, input.IdDisciplina, input.IdTutoringType);
            var disciplinaNome = string.IsNullOrWhiteSpace(discipline.DisciplinaNome) ? "Disciplina" : discipline.DisciplinaNome!;
            var cicloNome = string.IsNullOrWhiteSpace(discipline.CicloEstudos) ? null : discipline.CicloEstudos;
            var isIndividual = tutoringTypeName.Trim().Equals("individual", StringComparison.OrdinalIgnoreCase) || tutoringTypeName.Trim().Equals("1:1", StringComparison.OrdinalIgnoreCase);
            var minStudents = isIndividual ? 1 : 1;
            var maxStudents = isIndividual ? 1 : (int?)null;

            if (courseId == null || courseId == Guid.Empty)
            {
                await using var insertCourse = conn.CreateCommand();
                insertCourse.Transaction = tx;
                insertCourse.CommandText = @"
INSERT INTO public.courses (
    id_professor,
    id_pricing_model,
    id_tutoring_type,
    id_disciplina,
    id_ciclo_estudo,
    name,
    description,
    level_of_education,
    num_max_students,
    num_min_students,
    created_at,
    updated_at
)
VALUES (
    @id_professor,
    @id_pricing_model,
    @id_tutoring_type,
    @id_disciplina,
    @id_ciclo_estudo,
    @name,
    @description,
    @level_of_education,
    @num_max_students,
    @num_min_students,
    now(),
    now()
)
RETURNING id_course;";
                insertCourse.Parameters.AddWithValue("id_professor", idProfessor);
                insertCourse.Parameters.Add(new NpgsqlParameter("id_pricing_model", NpgsqlDbType.Uuid) { Value = (object?)pricingModelId ?? DBNull.Value });
                insertCourse.Parameters.AddWithValue("id_tutoring_type", input.IdTutoringType);
                insertCourse.Parameters.AddWithValue("id_disciplina", input.IdDisciplina);
                
                // CORREÇÃO: Permite que o ciclo de estudo vá a NULL para a base de dados
                insertCourse.Parameters.Add(new NpgsqlParameter("id_ciclo_estudo", NpgsqlDbType.Uuid) { Value = (object?)discipline.IdCicloEstudo ?? DBNull.Value });
                
                insertCourse.Parameters.AddWithValue("name", disciplinaNome);
                insertCourse.Parameters.Add(new NpgsqlParameter("description", NpgsqlDbType.Text) { Value = (object?)Normalize(input.Description) ?? DBNull.Value });
                insertCourse.Parameters.Add(new NpgsqlParameter("level_of_education", NpgsqlDbType.Varchar) { Value = (object?)cicloNome ?? DBNull.Value });
                insertCourse.Parameters.Add(new NpgsqlParameter("num_max_students", NpgsqlDbType.Integer) { Value = (object?)maxStudents ?? DBNull.Value });
                insertCourse.Parameters.AddWithValue("num_min_students", minStudents);
                var courseScalar = await insertCourse.ExecuteScalarAsync();
                courseId = courseScalar == null || courseScalar == DBNull.Value ? Guid.Empty : (Guid)courseScalar;
            }
            else
            {
                await using var updateCourse = conn.CreateCommand();
                updateCourse.Transaction = tx;
                updateCourse.CommandText = @"
UPDATE public.courses
SET id_ciclo_estudo = @id_ciclo_estudo,
    name = @name,
    description = @description,
    level_of_education = @level_of_education,
    num_max_students = @num_max_students,
    num_min_students = @num_min_students,
    updated_at = now()
WHERE id_course = @id_course;";
                updateCourse.Parameters.AddWithValue("id_course", courseId.Value);
                
                // CORREÇÃO: Permite que o ciclo de estudo vá a NULL para a base de dados
                updateCourse.Parameters.Add(new NpgsqlParameter("id_ciclo_estudo", NpgsqlDbType.Uuid) { Value = (object?)discipline.IdCicloEstudo ?? DBNull.Value });
                
                updateCourse.Parameters.AddWithValue("name", disciplinaNome);
                updateCourse.Parameters.Add(new NpgsqlParameter("description", NpgsqlDbType.Text) { Value = (object?)Normalize(input.Description) ?? DBNull.Value });
                updateCourse.Parameters.Add(new NpgsqlParameter("level_of_education", NpgsqlDbType.Varchar) { Value = (object?)cicloNome ?? DBNull.Value });
                updateCourse.Parameters.Add(new NpgsqlParameter("num_max_students", NpgsqlDbType.Integer) { Value = (object?)maxStudents ?? DBNull.Value });
                updateCourse.Parameters.AddWithValue("num_min_students", minStudents);
                await updateCourse.ExecuteNonQueryAsync();
            }

            await using (var disablePrices = conn.CreateCommand())
            {
                disablePrices.Transaction = tx;
                disablePrices.CommandText = @"
UPDATE public.course_prices
SET active = FALSE,
    updated_at = now()
WHERE id_course = @id_course
  AND active = TRUE;";
                disablePrices.Parameters.AddWithValue("id_course", courseId!.Value);
                await disablePrices.ExecuteNonQueryAsync();
            }

            await using (var insertPrice = conn.CreateCommand())
            {
                insertPrice.Transaction = tx;
                insertPrice.CommandText = @"
INSERT INTO public.course_prices (
    id_course,
    session_price,
    price_per_student,
    number_students,
    active,
    created_at,
    updated_at
)
VALUES (
    @id_course,
    @session_price,
    @price_per_student,
    @number_students,
    TRUE,
    now(),
    now()
);";
                insertPrice.Parameters.AddWithValue("id_course", courseId.Value);
                insertPrice.Parameters.AddWithValue("session_price", input.SessionPrice);
                insertPrice.Parameters.Add(new NpgsqlParameter("price_per_student", NpgsqlDbType.Numeric) { Value = isIndividual ? input.SessionPrice : DBNull.Value });
                insertPrice.Parameters.AddWithValue("number_students", isIndividual ? 1 : minStudents);
                await insertPrice.ExecuteNonQueryAsync();
            }

            Guid adId;
            await using (var upsertAd = conn.CreateCommand())
            {
                upsertAd.Transaction = tx;
                upsertAd.CommandText = "SELECT public.usp_professor_ads_upsert01(@id_professor, @id_course, @photo_url, @status);";
                upsertAd.Parameters.AddWithValue("id_professor", idProfessor);
                upsertAd.Parameters.AddWithValue("id_course", courseId.Value);
                upsertAd.Parameters.Add(new NpgsqlParameter("photo_url", NpgsqlDbType.Varchar) { Value = (object?)Normalize(input.PhotoUrl) ?? DBNull.Value });
                upsertAd.Parameters.AddWithValue("status", string.IsNullOrWhiteSpace(input.Status) ? "published" : input.Status.Trim());
                var adScalar = await upsertAd.ExecuteScalarAsync();
                adId = adScalar == null || adScalar == DBNull.Value ? Guid.Empty : (Guid)adScalar;
            }

            await tx.CommitAsync();

            var ad = await GetProfessorAdByIdInternalAsync(conn, null, adId, idProfessor);
            if (ad == null)
            {
                throw new InvalidOperationException("Não foi possível carregar o anúncio após a gravação.");
            }

            return ad;
        }

        public async Task<int> DeleteProfessorAdAsync(Guid idProfessorAd, Guid idProfessor)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_professor_ads_delete01(@id_professor_ad, @id_professor);";
            cmd.Parameters.AddWithValue("id_professor_ad", idProfessorAd);
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? 0 : Convert.ToInt32(result);
        }

        public async Task<ProfessorAd?> UpdateProfessorAdStatusAsync(Guid idProfessorAd, Guid idProfessor, string status)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
UPDATE public.professor_ads
SET status = @status,
    updated_at = now()
WHERE id_professor_ad = @id_professor_ad
  AND id_professor = @id_professor;";
            cmd.Parameters.AddWithValue("status", status);
            cmd.Parameters.AddWithValue("id_professor_ad", idProfessorAd);
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            var rows = await cmd.ExecuteNonQueryAsync();

            if (rows == 0)
            {
                return null;
            }

            return await GetProfessorAdByIdInternalAsync(conn, null, idProfessorAd, idProfessor);
        }

        private async Task<ProfessorAd?> GetProfessorAdByIdInternalAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction? tx,
            Guid idProfessorAd,
            Guid idProfessor)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = SelectAdsSql + " WHERE pa.id_professor_ad = @id_professor_ad AND pa.id_professor = @id_professor LIMIT 1;";
            cmd.Parameters.AddWithValue("id_professor_ad", idProfessorAd);
            cmd.Parameters.AddWithValue("id_professor", idProfessor);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapProfessorAd(reader);
        }

        private async Task<(Guid IdDisciplina, string? DisciplinaNome, Guid? IdCicloEstudo, string? CicloEstudos)?> ResolveProfessorDisciplineAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid idProfessor,
            Guid idDisciplina)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
SELECT
    pd.id_disciplina,
    d.nome AS disciplina_nome,
    pd.id_ciclo_estudo,
    ce.nome AS ciclo_estudos
FROM public.professor_disciplina pd
JOIN public.disciplinas d ON d.id_disciplina = pd.id_disciplina
LEFT JOIN public.ciclos_estudo ce ON ce.id_ciclo_estudo = pd.id_ciclo_estudo
WHERE pd.id_professor = @id_professor
  AND pd.id_disciplina = @id_disciplina
  AND COALESCE(pd.is_active, TRUE) = TRUE
LIMIT 1;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            cmd.Parameters.AddWithValue("id_disciplina", idDisciplina);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return (
                reader.GetGuid(reader.GetOrdinal("id_disciplina")),
                GetNullableString(reader, "disciplina_nome"),
                GetNullableGuid(reader, "id_ciclo_estudo"),
                GetNullableString(reader, "ciclo_estudos"));
        }

        private async Task<string?> ResolveTutoringTypeNameAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid idTutoringType)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
SELECT name
FROM public.tutoring_types
WHERE id_tutoring_type = @id_tutoring_type
LIMIT 1;";
            cmd.Parameters.AddWithValue("id_tutoring_type", idTutoringType);
            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? null : result.ToString();
        }

        private async Task<Guid?> ResolveDefaultPricingModelIdAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
SELECT pm.id_pricing_model
FROM public.pricing_models pm
ORDER BY
    CASE
        WHEN LOWER(BTRIM(pm.name)) IN ('preço por sessão', 'preco por sessao', 'preço sessão', 'preco sessao') THEN 0
        ELSE 1
    END,
    pm.created_at NULLS LAST,
    pm.id_pricing_model
LIMIT 1;";
            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? null : (Guid)result;
        }

        private async Task<Guid?> ResolveExistingCourseIdAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid idProfessor,
            Guid idDisciplina,
            Guid idTutoringType)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
SELECT c.id_course
FROM public.courses c
WHERE c.id_professor = @id_professor
  AND c.id_disciplina = @id_disciplina
  AND c.id_tutoring_type = @id_tutoring_type
ORDER BY c.updated_at DESC NULLS LAST, c.created_at DESC NULLS LAST
LIMIT 1;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);
            cmd.Parameters.AddWithValue("id_disciplina", idDisciplina);
            cmd.Parameters.AddWithValue("id_tutoring_type", idTutoringType);
            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? null : (Guid)result;
        }

        private ProfessorAd MapProfessorAd(NpgsqlDataReader reader)
        {
            return new ProfessorAd
            {
                IdProfessorAd = reader.GetGuid(reader.GetOrdinal("id_professor_ad")),
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                IdCourse = reader.GetGuid(reader.GetOrdinal("id_course")),
                IdDisciplina = GetNullableGuid(reader, "id_disciplina"),
                DisciplinaNome = GetNullableString(reader, "disciplina_nome"),
                IdCicloEstudo = GetNullableGuid(reader, "id_ciclo_estudo"),
                CicloEstudos = GetNullableString(reader, "ciclo_estudos"),
                IdTutoringType = GetNullableGuid(reader, "id_tutoring_type"),
                TutoringTypeName = GetNullableString(reader, "tutoring_type_name"),
                CourseName = GetNullableString(reader, "course_name") ?? string.Empty,
                Description = GetNullableString(reader, "description"),
                LevelOfEducation = GetNullableString(reader, "level_of_education"),
                SessionPrice = GetNullableDecimal(reader, "session_price"),
                PhotoUrl = GetNullableString(reader, "photo_url"),
                Status = GetNullableString(reader, "status") ?? "published",
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at"),
            };
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetGuid(ordinal);
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetString(ordinal);
        }

        private static decimal? GetNullableDecimal(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetDecimal(ordinal);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetDateTime(ordinal);
        }

        private static string? Normalize(string? value)
        {
            if (string.IsNullOrWhiteSpace(value)) return null;
            return value.Trim();
        }

        private const string SelectAdsSql = @"
SELECT
    pa.id_professor_ad,
    pa.id_professor,
    pa.id_course,
    c.id_disciplina,
    d.nome AS disciplina_nome,
    c.id_ciclo_estudo,
    COALESCE(ce.nome, c.level_of_education) AS ciclo_estudos,
    c.id_tutoring_type,
    tt.name AS tutoring_type_name,
    c.name AS course_name,
    c.description,
    c.level_of_education,
    cp.session_price,
    pa.photo_url,
    pa.status,
    pa.created_at,
    pa.updated_at
FROM public.professor_ads pa
JOIN public.courses c ON c.id_course = pa.id_course
LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
LEFT JOIN public.ciclos_estudo ce ON ce.id_ciclo_estudo = c.id_ciclo_estudo
LEFT JOIN public.tutoring_types tt ON tt.id_tutoring_type = c.id_tutoring_type
LEFT JOIN LATERAL (
    SELECT cp1.session_price
    FROM public.course_prices cp1
    WHERE cp1.id_course = c.id_course
      AND cp1.active = TRUE
    ORDER BY cp1.updated_at DESC NULLS LAST, cp1.created_at DESC NULLS LAST
    LIMIT 1
) cp ON TRUE";
    }
}