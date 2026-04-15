using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Education.Models;
using Npgsql;
using NpgsqlTypes;

namespace ConfidantPostgreSQL.Modules.Education.Repository
{
    public class EducationRepository : IEducationRepository
    {
        private readonly string _connectionString;

        public EducationRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<Disciplina>> GetDisciplinasAllAsync()
        {
            var list = new List<Disciplina>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_disciplinas_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Disciplina
                {
                    IdDisciplina = reader.GetGuid(reader.GetOrdinal("id_disciplina")),
                    IdArea = GetNullableGuid(reader, "id_area"),
                    Nome = reader.GetString(reader.GetOrdinal("nome")),
                    Descricao = GetNullableString(reader, "descricao"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<IEnumerable<Disciplina>> GetPublicDisciplinasWithProfessorsAsync()
        {
            var list = new List<Disciplina>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    d.id_disciplina,
    d.id_area,
    a.nome AS area_nome,
    d.nome,
    d.descricao,
    NULL::uuid AS id_ciclo_estudo,
    NULL::text AS ciclo_estudos,
    COUNT(DISTINCT pd.id_professor)::int AS active_students_count,
    TRUE AS is_active,
    d.created_at,
    d.updated_at
FROM public.professor_disciplina pd
JOIN public.professors p ON p.id_professor = pd.id_professor
JOIN public.disciplinas d ON d.id_disciplina = pd.id_disciplina
LEFT JOIN public.areas a ON a.id_area = d.id_area
WHERE COALESCE(pd.is_active, TRUE) = TRUE
  AND COALESCE(p.is_active, TRUE) = TRUE
  AND COALESCE(p.is_verified, FALSE) = TRUE
GROUP BY
    d.id_disciplina,
    d.id_area,
    a.nome,
    d.nome,
    d.descricao,
    d.created_at,
    d.updated_at
ORDER BY d.nome ASC;";

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Disciplina
                {
                    IdDisciplina = reader.GetGuid(reader.GetOrdinal("id_disciplina")),
                    IdArea = GetNullableGuid(reader, "id_area"),
                    AreaNome = GetNullableString(reader, "area_nome"),
                    Nome = reader.GetString(reader.GetOrdinal("nome")),
                    Descricao = GetNullableString(reader, "descricao"),
                    IdCicloEstudo = GetNullableGuid(reader, "id_ciclo_estudo"),
                    CicloEstudos = GetNullableString(reader, "ciclo_estudos"),
                    ActiveStudentsCount = GetNullableInt(reader, "active_students_count") ?? 0,
                    IsActive = true,
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }

            return list;
        }

        public async Task<Disciplina?> GetDisciplinaByIdAsync(Guid idDisciplina)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_disciplinas_select_details01(@id_disciplina);";
            cmd.Parameters.AddWithValue("id_disciplina", idDisciplina);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new Disciplina
            {
                IdDisciplina = reader.GetGuid(reader.GetOrdinal("id_disciplina")),
                IdArea = GetNullableGuid(reader, "id_area"),
                Nome = reader.GetString(reader.GetOrdinal("nome")),
                Descricao = GetNullableString(reader, "descricao"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertDisciplinaAsync(Disciplina disciplina)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_disciplinas_insert(@id_area, @nome, @descricao, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("id_area", (object?)disciplina.IdArea ?? DBNull.Value);
            cmd.Parameters.AddWithValue("nome", disciplina.Nome);
            cmd.Parameters.AddWithValue("descricao", (object?)disciplina.Descricao ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)disciplina.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)disciplina.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateDisciplinaAsync(Disciplina disciplina)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_disciplinas_update(@id_disciplina, @id_area, @nome, @descricao);";
            cmd.Parameters.AddWithValue("id_disciplina", disciplina.IdDisciplina);
            cmd.Parameters.AddWithValue("id_area", (object?)disciplina.IdArea ?? DBNull.Value);
            cmd.Parameters.AddWithValue("nome", disciplina.Nome);
            cmd.Parameters.AddWithValue("descricao", (object?)disciplina.Descricao ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Disciplina>> GetDisciplinasByAreaIdAsync(Guid idArea)
        {
            var list = new List<Disciplina>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_disciplinas_select_by_area01(@id_area);";
            cmd.Parameters.AddWithValue("id_area", idArea);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Disciplina
                {
                    IdDisciplina = reader.GetGuid(reader.GetOrdinal("id_disciplina")),
                    IdArea = GetNullableGuid(reader, "id_area"),
                    Nome = reader.GetString(reader.GetOrdinal("nome")),
                    Descricao = GetNullableString(reader, "descricao"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }

            return list;
        }

        public async Task<IEnumerable<Area>> GetAreasAllAsync()
        {
            var list = new List<Area>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
SELECT
    a.id_area,
    a.nome,
    a.descricao,
    a.created_at,
    a.updated_at,
    COALESCE(pc.professor_count, 0) AS professor_count
FROM areas a
LEFT JOIN (
    SELECT
        d.id_area,
        COUNT(DISTINCT pd.id_professor) AS professor_count
    FROM professor_disciplina pd
    JOIN disciplinas d ON d.id_disciplina = pd.id_disciplina
    JOIN professors p ON p.id_professor = pd.id_professor
    WHERE pd.id_professor IS NOT NULL
        AND d.id_area IS NOT NULL
        AND COALESCE(pd.is_active, TRUE) = TRUE
        AND COALESCE(p.is_active, TRUE) = TRUE
        AND COALESCE(p.is_verified, FALSE) = TRUE
    GROUP BY d.id_area
) pc ON pc.id_area = a.id_area
ORDER BY a.nome;";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Area
                {
                    IdArea = reader.GetGuid(reader.GetOrdinal("id_area")),
                    Nome = reader.GetString(reader.GetOrdinal("nome")),
                    Descricao = GetNullableString(reader, "descricao"),
                    ProfessorCount = GetNullableInt(reader, "professor_count") ?? 0,
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<Area?> GetAreaByIdAsync(Guid idArea)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_areas_select_details01(@id_area);";
            cmd.Parameters.AddWithValue("id_area", idArea);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new Area
            {
                IdArea = reader.GetGuid(reader.GetOrdinal("id_area")),
                Nome = reader.GetString(reader.GetOrdinal("nome")),
                Descricao = GetNullableString(reader, "descricao"),
                ProfessorCount = 0,
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertAreaAsync(Area area)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_areas_insert01(@nome, @descricao);";
            cmd.Parameters.AddWithValue("nome", area.Nome);
            cmd.Parameters.AddWithValue("descricao", (object?)area.Descricao ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateAreaAsync(Area area)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_areas_update01(@id_area, @nome, @descricao);";
            cmd.Parameters.AddWithValue("id_area", area.IdArea);
            cmd.Parameters.AddWithValue("nome", area.Nome);
            cmd.Parameters.AddWithValue("descricao", (object?)area.Descricao ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteAreaAsync(Guid idArea)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_areas_delete01(@id_area);";
            cmd.Parameters.AddWithValue("id_area", idArea);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteDisciplinaAsync(Guid idDisciplina)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_disciplinas_delete(@id_disciplina);";
            cmd.Parameters.AddWithValue("id_disciplina", idDisciplina);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Disciplina>> GetDisciplinasByUserIdAsync(Guid userId)
        {
            var list = new List<Disciplina>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_user_disciplinas_select_by_user01(@id_user);";
            cmd.Parameters.AddWithValue("id_user", userId);

            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Disciplina
                {
                    IdDisciplina = reader.GetGuid(reader.GetOrdinal("id_disciplina")),
                    IdArea = GetNullableGuid(reader, "id_area"),
                    Nome = reader.GetString(reader.GetOrdinal("nome")),
                    Descricao = GetNullableString(reader, "descricao"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }

            return list;
        }

        public async Task<int> SetDisciplinasForUserAsync(Guid userId, Guid[] ids)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_user_disciplinas_set_for_user01(@id_user, @ids);";

            cmd.Parameters.AddWithValue("id_user", userId);

            var idsParam = cmd.Parameters.Add("ids", NpgsqlDbType.Array | NpgsqlDbType.Uuid);
            idsParam.Value = (object?)ids ?? Array.Empty<Guid>();

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> RemoveDisciplinaForUserAsync(Guid userId, Guid idDisciplina)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_user_disciplinas_delete_for_user01(@id_user, @id_disciplina);";
            cmd.Parameters.AddWithValue("id_user", userId);
            cmd.Parameters.AddWithValue("id_disciplina", idDisciplina);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> RemoveDisciplinasForUserByAreaAsync(Guid userId, Guid idArea)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_user_disciplinas_delete_for_user_by_area01(@id_user, @id_area);";
            cmd.Parameters.AddWithValue("id_user", userId);
            cmd.Parameters.AddWithValue("id_area", idArea);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var ordinal = reader.GetOrdinal(column);
            return reader.IsDBNull(ordinal) ? null : reader.GetGuid(ordinal);
        }

        public async Task<IEnumerable<AnoEscolaridade>> GetAnosEscolaridadeAllAsync()
        {
            var list = new List<AnoEscolaridade>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_anos_escolaridade_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new AnoEscolaridade
                {
                    IdAnoEscolaridade = reader.GetGuid(reader.GetOrdinal("id_ano_escolaridade")),
                    Nome = GetNullableString(reader, "nome"),
                    AnoIndex = GetNullableInt(reader, "ano_index"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<AnoEscolaridade?> GetAnoEscolaridadeByIdAsync(Guid idAnoEscolaridade)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_anos_escolaridade_select_details01(@id_ano_escolaridade);";
            cmd.Parameters.AddWithValue("id_ano_escolaridade", idAnoEscolaridade);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new AnoEscolaridade
            {
                IdAnoEscolaridade = reader.GetGuid(reader.GetOrdinal("id_ano_escolaridade")),
                Nome = GetNullableString(reader, "nome"),
                AnoIndex = GetNullableInt(reader, "ano_index"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertAnoEscolaridadeAsync(AnoEscolaridade ano)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_anos_escolaridade_insert(@nome, @ano_index, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("nome", (object?)ano.Nome ?? DBNull.Value);
            cmd.Parameters.AddWithValue("ano_index", (object?)ano.AnoIndex ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)ano.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)ano.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateAnoEscolaridadeAsync(AnoEscolaridade ano)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_anos_escolaridade_update(@id_ano_escolaridade, @nome, @ano_index);";
            cmd.Parameters.AddWithValue("id_ano_escolaridade", ano.IdAnoEscolaridade);
            cmd.Parameters.AddWithValue("nome", (object?)ano.Nome ?? DBNull.Value);
            cmd.Parameters.AddWithValue("ano_index", (object?)ano.AnoIndex ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteAnoEscolaridadeAsync(Guid idAnoEscolaridade)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_anos_escolaridade_delete(@id_ano_escolaridade);";
            cmd.Parameters.AddWithValue("id_ano_escolaridade", idAnoEscolaridade);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<CicloEstudo>> GetCiclosEstudoAllAsync()
        {
            var list = new List<CicloEstudo>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_ciclos_estudo_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CicloEstudo
                {
                    IdCicloEstudo = reader.GetGuid(reader.GetOrdinal("id_ciclo_estudo")),
                    Nome = reader.GetString(reader.GetOrdinal("nome")),
                    Descricao = GetNullableString(reader, "descricao"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<CicloEstudo?> GetCicloEstudoByIdAsync(Guid idCicloEstudo)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_ciclos_estudo_select_details01(@id_ciclo_estudo);";
            cmd.Parameters.AddWithValue("id_ciclo_estudo", idCicloEstudo);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new CicloEstudo
            {
                IdCicloEstudo = reader.GetGuid(reader.GetOrdinal("id_ciclo_estudo")),
                Nome = reader.GetString(reader.GetOrdinal("nome")),
                Descricao = GetNullableString(reader, "descricao"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertCicloEstudoAsync(CicloEstudo ciclo)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_ciclos_estudo_insert(@nome, @descricao, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("nome", ciclo.Nome);
            cmd.Parameters.AddWithValue("descricao", (object?)ciclo.Descricao ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)ciclo.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)ciclo.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateCicloEstudoAsync(CicloEstudo ciclo)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_ciclos_estudo_update(@id_ciclo_estudo, @nome, @descricao);";
            cmd.Parameters.AddWithValue("id_ciclo_estudo", ciclo.IdCicloEstudo);
            cmd.Parameters.AddWithValue("nome", ciclo.Nome);
            cmd.Parameters.AddWithValue("descricao", (object?)ciclo.Descricao ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteCicloEstudoAsync(Guid idCicloEstudo)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_ciclos_estudo_delete(@id_ciclo_estudo);";
            cmd.Parameters.AddWithValue("id_ciclo_estudo", idCicloEstudo);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<IEnumerable<CicloEstudoAno>> GetCiclosEstudoAnosAllAsync()
        {
            var list = new List<CicloEstudoAno>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_ciclos_estudo_anos_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CicloEstudoAno
                {
                    IdCicloEstudoAnoEscolaridade = reader.GetGuid(reader.GetOrdinal("id_ciclo_estudo_ano_escolaridade")),
                    IdCicloEstudo = reader.GetGuid(reader.GetOrdinal("id_ciclo_estudo")),
                    IdAnoEscolaridade = reader.GetGuid(reader.GetOrdinal("id_ano_escolaridade")),
                    CreatedAt = GetNullableDateTime(reader, "created_at")
                });
            }
            return list;
        }

        public async Task<CicloEstudoAno?> GetCicloEstudoAnoByIdAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_ciclos_estudo_anos_select_details01(@id);";
            cmd.Parameters.AddWithValue("id", id);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new CicloEstudoAno
            {
                IdCicloEstudoAnoEscolaridade = reader.GetGuid(reader.GetOrdinal("id_ciclo_estudo_ano_escolaridade")),
                IdCicloEstudo = reader.GetGuid(reader.GetOrdinal("id_ciclo_estudo")),
                IdAnoEscolaridade = reader.GetGuid(reader.GetOrdinal("id_ano_escolaridade")),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        public async Task<Guid> InsertCicloEstudoAnoAsync(CicloEstudoAno rel)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_ciclos_estudo_anos_insert(@id_ciclo_estudo, @id_ano_escolaridade, @created_at);";
            cmd.Parameters.AddWithValue("id_ciclo_estudo", rel.IdCicloEstudo);
            cmd.Parameters.AddWithValue("id_ano_escolaridade", rel.IdAnoEscolaridade);
            cmd.Parameters.AddWithValue("created_at", (object?)rel.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateCicloEstudoAnoAsync(CicloEstudoAno rel)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_ciclos_estudo_anos_update(@id, @id_ciclo_estudo, @id_ano_escolaridade);";
            cmd.Parameters.AddWithValue("id", rel.IdCicloEstudoAnoEscolaridade);
            cmd.Parameters.AddWithValue("id_ciclo_estudo", rel.IdCicloEstudo);
            cmd.Parameters.AddWithValue("id_ano_escolaridade", rel.IdAnoEscolaridade);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteCicloEstudoAnoAsync(Guid id)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_ciclos_estudo_anos_delete(@id);";
            cmd.Parameters.AddWithValue("id", id);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetString(idx);
        }

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetInt32(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try { return reader.GetFieldValue<DateTime>(idx); } catch { return null; }
        }
    }
}
