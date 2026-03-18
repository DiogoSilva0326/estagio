using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Courses.Models;

namespace ConfidantPostgreSQL.Modules.Courses.Repository
{
    public interface ICoursesRepository
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

        Task<IEnumerable<LessonPack>> GetLessonPacksAllAsync();
        Task<LessonPack?> GetLessonPackByIdAsync(Guid idLessonPack);
        Task<IEnumerable<LessonPack>> GetLessonPacksByCourseIdAsync(Guid idCourse);
        Task<Guid> InsertLessonPackAsync(LessonPack lessonPack);
        Task<int> UpdateLessonPackAsync(LessonPack lessonPack);
        Task<int> DeleteLessonPackAsync(Guid idLessonPack);

        Task<IEnumerable<UserLessonPack>> GetUserLessonPacksAllAsync();
        Task<UserLessonPack?> GetUserLessonPackByIdAsync(Guid idUserLessonPack);
        Task<IEnumerable<UserLessonPack>> GetUserLessonPacksByUserIdAsync(Guid idUser);
        Task<Guid> InsertUserLessonPackAsync(UserLessonPack userLessonPack);
        Task<int> UpdateUserLessonPackAsync(UserLessonPack userLessonPack);
        Task<int> DeleteUserLessonPackAsync(Guid idUserLessonPack);

        Task<IEnumerable<PackTransaction>> GetPackTransactionsAllAsync();
        Task<PackTransaction?> GetPackTransactionByIdAsync(Guid idPackTransaction);
        Task<IEnumerable<PackTransaction>> GetPackTransactionsByUserLessonPackIdAsync(Guid idUserLessonPack);
        Task<Guid> InsertPackTransactionAsync(PackTransaction packTransaction);
        Task<int> DeletePackTransactionAsync(Guid idPackTransaction);
    }
}
