using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Courses.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Courses.Repository
{
    public class CoursesRepository : ICoursesRepository
    {
        private readonly string _connectionString;

        public CoursesRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        public async Task<IEnumerable<TutoringType>> GetTutoringTypesAllAsync()
        {
            var list = new List<TutoringType>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_tutoring_types_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new TutoringType
                {
                    IdTutoringType = reader.GetGuid(reader.GetOrdinal("id_tutoring_type")),
                    Name = reader.GetString(reader.GetOrdinal("name")),
                    Description = GetNullableString(reader, "description"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<TutoringType?> GetTutoringTypeByIdAsync(Guid idTutoringType)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_tutoring_types_select_details01(@id_tutoring_type);";
            cmd.Parameters.AddWithValue("id_tutoring_type", idTutoringType);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new TutoringType
            {
                IdTutoringType = reader.GetGuid(reader.GetOrdinal("id_tutoring_type")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Description = GetNullableString(reader, "description"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertTutoringTypeAsync(TutoringType tutoringType)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_tutoring_types_insert(@name, @description, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("name", tutoringType.Name);
            cmd.Parameters.AddWithValue("description", (object?)tutoringType.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)tutoringType.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)tutoringType.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateTutoringTypeAsync(TutoringType tutoringType)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_tutoring_types_update(@id_tutoring_type, @name, @description);";
            cmd.Parameters.AddWithValue("id_tutoring_type", tutoringType.IdTutoringType);
            cmd.Parameters.AddWithValue("name", tutoringType.Name);
            cmd.Parameters.AddWithValue("description", (object?)tutoringType.Description ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return Convert.ToInt32(res);
        }

        public async Task<int> DeleteTutoringTypeAsync(Guid idTutoringType)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_tutoring_types_delete(@id_tutoring_type);";
            cmd.Parameters.AddWithValue("id_tutoring_type", idTutoringType);
            var res = await cmd.ExecuteScalarAsync();
            return Convert.ToInt32(res);
        }

        public async Task<IEnumerable<PricingModel>> GetPricingModelsAllAsync()
        {
            var list = new List<PricingModel>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_pricing_models_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new PricingModel
                {
                    IdPricingModel = reader.GetGuid(reader.GetOrdinal("id_pricing_model")),
                    Name = reader.GetString(reader.GetOrdinal("name")),
                    Description = GetNullableString(reader, "description"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<PricingModel?> GetPricingModelByIdAsync(Guid idPricingModel)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_pricing_models_select_details01(@id_pricing_model);";
            cmd.Parameters.AddWithValue("id_pricing_model", idPricingModel);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new PricingModel
            {
                IdPricingModel = reader.GetGuid(reader.GetOrdinal("id_pricing_model")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Description = GetNullableString(reader, "description"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertPricingModelAsync(PricingModel pricingModel)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_pricing_models_insert(@name, @description, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("name", pricingModel.Name);
            cmd.Parameters.AddWithValue("description", (object?)pricingModel.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)pricingModel.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)pricingModel.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdatePricingModelAsync(PricingModel pricingModel)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_pricing_models_update(@id_pricing_model, @name, @description);";
            cmd.Parameters.AddWithValue("id_pricing_model", pricingModel.IdPricingModel);
            cmd.Parameters.AddWithValue("name", pricingModel.Name);
            cmd.Parameters.AddWithValue("description", (object?)pricingModel.Description ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return Convert.ToInt32(res);
        }

        public async Task<int> DeletePricingModelAsync(Guid idPricingModel)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_pricing_models_delete(@id_pricing_model);";
            cmd.Parameters.AddWithValue("id_pricing_model", idPricingModel);
            var res = await cmd.ExecuteScalarAsync();
            return Convert.ToInt32(res);
        }

        public async Task<IEnumerable<Course>> GetCoursesAllAsync()
        {
            var list = new List<Course>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_courses_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new Course
                {
                    IdCourse = reader.GetGuid(reader.GetOrdinal("id_course")),
                    IdProfessor = GetNullableGuid(reader, "id_professor"),
                    IdPricingModel = GetNullableGuid(reader, "id_pricing_model"),
                    IdTutoringType = GetNullableGuid(reader, "id_tutoring_type"),
                    IdDisciplina = GetNullableGuid(reader, "id_disciplina"),
                    IdAnoEscolaridade = GetNullableGuid(reader, "id_ano_escolaridade"),
                    IdCicloEstudo = GetNullableGuid(reader, "id_ciclo_estudo"),
                    Name = reader.GetString(reader.GetOrdinal("name")),
                    Description = GetNullableString(reader, "description"),
                    LevelOfEducation = GetNullableString(reader, "level_of_education"),
                    NumMaxStudents = GetNullableInt(reader, "num_max_students"),
                    NumMinStudents = GetNullableInt(reader, "num_min_students"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<Course?> GetCourseByIdAsync(Guid idCourse)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_courses_select_details01(@id_course);";
            cmd.Parameters.AddWithValue("id_course", idCourse);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new Course
            {
                IdCourse = reader.GetGuid(reader.GetOrdinal("id_course")),
                IdProfessor = GetNullableGuid(reader, "id_professor"),
                IdPricingModel = GetNullableGuid(reader, "id_pricing_model"),
                IdTutoringType = GetNullableGuid(reader, "id_tutoring_type"),
                IdDisciplina = GetNullableGuid(reader, "id_disciplina"),
                IdAnoEscolaridade = GetNullableGuid(reader, "id_ano_escolaridade"),
                IdCicloEstudo = GetNullableGuid(reader, "id_ciclo_estudo"),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Description = GetNullableString(reader, "description"),
                LevelOfEducation = GetNullableString(reader, "level_of_education"),
                NumMaxStudents = GetNullableInt(reader, "num_max_students"),
                NumMinStudents = GetNullableInt(reader, "num_min_students"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertCourseAsync(Course course)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"SELECT public.usp_courses_insert(
    @id_professor,
    @id_pricing_model,
    @id_tutoring_type,
    @id_disciplina,
    @id_ano_escolaridade,
    @id_ciclo_estudo,
    @name,
    @description,
    @level_of_education,
    @num_max_students,
    @num_min_students,
    @created_at,
    @updated_at
);";

            cmd.Parameters.AddWithValue("id_professor", (object?)course.IdProfessor ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_pricing_model", (object?)course.IdPricingModel ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_tutoring_type", (object?)course.IdTutoringType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_disciplina", (object?)course.IdDisciplina ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_ano_escolaridade", (object?)course.IdAnoEscolaridade ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_ciclo_estudo", (object?)course.IdCicloEstudo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("name", course.Name);
            cmd.Parameters.AddWithValue("description", (object?)course.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("level_of_education", (object?)course.LevelOfEducation ?? DBNull.Value);
            cmd.Parameters.AddWithValue("num_max_students", (object?)course.NumMaxStudents ?? DBNull.Value);
            cmd.Parameters.AddWithValue("num_min_students", (object?)course.NumMinStudents ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)course.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)course.UpdatedAt ?? DBNull.Value);

            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateCourseAsync(Course course)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_courses_update(
  @id_course,
  @id_professor,
  @id_pricing_model,
  @id_tutoring_type,
  @id_disciplina,
  @id_ano_escolaridade,
  @id_ciclo_estudo,
  @name,
  @description,
  @level_of_education,
  @num_max_students,
  @num_min_students
);";

            cmd.Parameters.AddWithValue("id_course", course.IdCourse);
            cmd.Parameters.AddWithValue("id_professor", (object?)course.IdProfessor ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_pricing_model", (object?)course.IdPricingModel ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_tutoring_type", (object?)course.IdTutoringType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_disciplina", (object?)course.IdDisciplina ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_ano_escolaridade", (object?)course.IdAnoEscolaridade ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_ciclo_estudo", (object?)course.IdCicloEstudo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("name", course.Name);
            cmd.Parameters.AddWithValue("description", (object?)course.Description ?? DBNull.Value);
            cmd.Parameters.AddWithValue("level_of_education", (object?)course.LevelOfEducation ?? DBNull.Value);
            cmd.Parameters.AddWithValue("num_max_students", (object?)course.NumMaxStudents ?? DBNull.Value);
            cmd.Parameters.AddWithValue("num_min_students", (object?)course.NumMinStudents ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return Convert.ToInt32(res);
        }

        public async Task<int> DeleteCourseAsync(Guid idCourse)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_courses_delete(@id_course);";
            cmd.Parameters.AddWithValue("id_course", idCourse);
            var res = await cmd.ExecuteScalarAsync();
            return Convert.ToInt32(res);
        }

        public async Task<IEnumerable<CoursePrice>> GetCoursePricesAllAsync()
        {
            var list = new List<CoursePrice>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_course_prices_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new CoursePrice
                {
                    IdCoursePrice = reader.GetGuid(reader.GetOrdinal("id_course_price")),
                    IdCourse = reader.GetGuid(reader.GetOrdinal("id_course")),
                    SessionPrice = GetNullableDecimal(reader, "session_price"),
                    PricePerStudent = GetNullableDecimal(reader, "price_per_student"),
                    NumberStudents = GetNullableInt(reader, "number_students"),
                    Active = GetBoolDefaultFalse(reader, "active"),
                    CreatedAt = GetNullableDateTime(reader, "created_at"),
                    UpdatedAt = GetNullableDateTime(reader, "updated_at")
                });
            }
            return list;
        }

        public async Task<CoursePrice?> GetCoursePriceByIdAsync(Guid idCoursePrice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_course_prices_select_details01(@id_course_price);";
            cmd.Parameters.AddWithValue("id_course_price", idCoursePrice);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return new CoursePrice
            {
                IdCoursePrice = reader.GetGuid(reader.GetOrdinal("id_course_price")),
                IdCourse = reader.GetGuid(reader.GetOrdinal("id_course")),
                SessionPrice = GetNullableDecimal(reader, "session_price"),
                PricePerStudent = GetNullableDecimal(reader, "price_per_student"),
                NumberStudents = GetNullableInt(reader, "number_students"),
                Active = GetBoolDefaultFalse(reader, "active"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        public async Task<Guid> InsertCoursePriceAsync(CoursePrice coursePrice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = @"SELECT public.usp_course_prices_insert(
    @id_course,
    @session_price,
    @price_per_student,
    @number_students,
    @active,
    @created_at,
    @updated_at
);";

            cmd.Parameters.AddWithValue("id_course", coursePrice.IdCourse);
            cmd.Parameters.AddWithValue("session_price", (object?)coursePrice.SessionPrice ?? DBNull.Value);
            cmd.Parameters.AddWithValue("price_per_student", (object?)coursePrice.PricePerStudent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("number_students", (object?)coursePrice.NumberStudents ?? DBNull.Value);
            cmd.Parameters.AddWithValue("active", coursePrice.Active);
            cmd.Parameters.AddWithValue("created_at", (object?)coursePrice.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)coursePrice.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateCoursePriceAsync(CoursePrice coursePrice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_course_prices_update(
  @id_course_price,
  @id_course,
  @session_price,
  @price_per_student,
  @number_students,
  @active
);";

            cmd.Parameters.AddWithValue("id_course_price", coursePrice.IdCoursePrice);
            cmd.Parameters.AddWithValue("id_course", coursePrice.IdCourse);
            cmd.Parameters.AddWithValue("session_price", (object?)coursePrice.SessionPrice ?? DBNull.Value);
            cmd.Parameters.AddWithValue("price_per_student", (object?)coursePrice.PricePerStudent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("number_students", (object?)coursePrice.NumberStudents ?? DBNull.Value);
            cmd.Parameters.AddWithValue("active", coursePrice.Active);
            var res = await cmd.ExecuteScalarAsync();
            return Convert.ToInt32(res);
        }

        public async Task<int> DeleteCoursePriceAsync(Guid idCoursePrice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_course_prices_delete(@id_course_price);";
            cmd.Parameters.AddWithValue("id_course_price", idCoursePrice);
            var res = await cmd.ExecuteScalarAsync();
            return Convert.ToInt32(res);
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

        private static decimal? GetNullableDecimal(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetFieldValue<decimal>(idx);
        }

        private static bool GetBoolDefaultFalse(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? false : reader.GetBoolean(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try { return reader.GetFieldValue<DateTime>(idx); } catch { return null; }
        }
    }
}
