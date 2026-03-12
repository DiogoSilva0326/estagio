using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Courses.Models;

namespace ConfidantPostgreSQL.Modules.Courses.Service
{
    public interface ICoursesService
    {
        Task<IEnumerable<TutoringType>> GetTutoringTypesAllAsync();
        Task<TutoringType?> GetTutoringTypeByIdAsync(Guid idTutoringType);
        Task<Guid> InsertTutoringTypeAsync(TutoringType tutoringType);
        Task<int> UpdateTutoringTypeAsync(TutoringType tutoringType);
        Task<int> DeleteTutoringTypeAsync(Guid idTutoringType);

        Task<IEnumerable<PricingModel>> GetPricingModelsAllAsync();
        Task<PricingModel?> GetPricingModelByIdAsync(Guid idPricingModel);
        Task<Guid> InsertPricingModelAsync(PricingModel pricingModel);
        Task<int> UpdatePricingModelAsync(PricingModel pricingModel);
        Task<int> DeletePricingModelAsync(Guid idPricingModel);

        Task<IEnumerable<Course>> GetCoursesAllAsync();
        Task<Course?> GetCourseByIdAsync(Guid idCourse);
        Task<Guid> InsertCourseAsync(Course course);
        Task<int> UpdateCourseAsync(Course course);
        Task<int> DeleteCourseAsync(Guid idCourse);

        Task<IEnumerable<CoursePrice>> GetCoursePricesAllAsync();
        Task<CoursePrice?> GetCoursePriceByIdAsync(Guid idCoursePrice);
        Task<Guid> InsertCoursePriceAsync(CoursePrice coursePrice);
        Task<int> UpdateCoursePriceAsync(CoursePrice coursePrice);
        Task<int> DeleteCoursePriceAsync(Guid idCoursePrice);
    }
}
