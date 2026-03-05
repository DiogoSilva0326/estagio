using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Courses.Models;
using ConfidantPostgreSQL.Modules.Courses.Repository;

namespace ConfidantPostgreSQL.Modules.Courses.Service
{
    public class CoursesService : ICoursesService
    {
        private readonly ICoursesRepository _repo;

        public CoursesService(ICoursesRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<TutoringType>> GetTutoringTypesAllAsync() => _repo.GetTutoringTypesAllAsync();
        public Task<TutoringType?> GetTutoringTypeByIdAsync(Guid idTutoringType) => _repo.GetTutoringTypeByIdAsync(idTutoringType);
        public Task<Guid> InsertTutoringTypeAsync(TutoringType tutoringType) => _repo.InsertTutoringTypeAsync(tutoringType);
        public Task<int> UpdateTutoringTypeAsync(TutoringType tutoringType) => _repo.UpdateTutoringTypeAsync(tutoringType);
        public Task<int> DeleteTutoringTypeAsync(Guid idTutoringType) => _repo.DeleteTutoringTypeAsync(idTutoringType);

        public Task<IEnumerable<PricingModel>> GetPricingModelsAllAsync() => _repo.GetPricingModelsAllAsync();
        public Task<PricingModel?> GetPricingModelByIdAsync(Guid idPricingModel) => _repo.GetPricingModelByIdAsync(idPricingModel);
        public Task<Guid> InsertPricingModelAsync(PricingModel pricingModel) => _repo.InsertPricingModelAsync(pricingModel);
        public Task<int> UpdatePricingModelAsync(PricingModel pricingModel) => _repo.UpdatePricingModelAsync(pricingModel);
        public Task<int> DeletePricingModelAsync(Guid idPricingModel) => _repo.DeletePricingModelAsync(idPricingModel);

        public Task<IEnumerable<Course>> GetCoursesAllAsync() => _repo.GetCoursesAllAsync();
        public Task<Course?> GetCourseByIdAsync(Guid idCourse) => _repo.GetCourseByIdAsync(idCourse);
        public Task<Guid> InsertCourseAsync(Course course) => _repo.InsertCourseAsync(course);
        public Task<int> UpdateCourseAsync(Course course) => _repo.UpdateCourseAsync(course);
        public Task<int> DeleteCourseAsync(Guid idCourse) => _repo.DeleteCourseAsync(idCourse);

        public Task<IEnumerable<CoursePrice>> GetCoursePricesAllAsync() => _repo.GetCoursePricesAllAsync();
        public Task<CoursePrice?> GetCoursePriceByIdAsync(Guid idCoursePrice) => _repo.GetCoursePriceByIdAsync(idCoursePrice);
        public Task<Guid> InsertCoursePriceAsync(CoursePrice coursePrice) => _repo.InsertCoursePriceAsync(coursePrice);
        public Task<int> UpdateCoursePriceAsync(CoursePrice coursePrice) => _repo.UpdateCoursePriceAsync(coursePrice);
        public Task<int> DeleteCoursePriceAsync(Guid idCoursePrice) => _repo.DeleteCoursePriceAsync(idCoursePrice);
    }
}
