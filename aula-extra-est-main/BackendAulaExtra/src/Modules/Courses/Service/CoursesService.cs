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

        public Task<IEnumerable<LessonPack>> GetLessonPacksAllAsync() => _repo.GetLessonPacksAllAsync();
        public Task<LessonPack?> GetLessonPackByIdAsync(Guid idLessonPack) => _repo.GetLessonPackByIdAsync(idLessonPack);
        public Task<IEnumerable<LessonPack>> GetLessonPacksByCourseIdAsync(Guid idCourse) => _repo.GetLessonPacksByCourseIdAsync(idCourse);
        public Task<Guid> InsertLessonPackAsync(LessonPack lessonPack) => _repo.InsertLessonPackAsync(lessonPack);
        public Task<int> UpdateLessonPackAsync(LessonPack lessonPack) => _repo.UpdateLessonPackAsync(lessonPack);
        public Task<int> DeleteLessonPackAsync(Guid idLessonPack) => _repo.DeleteLessonPackAsync(idLessonPack);

        public Task<IEnumerable<UserLessonPack>> GetUserLessonPacksAllAsync() => _repo.GetUserLessonPacksAllAsync();
        public Task<UserLessonPack?> GetUserLessonPackByIdAsync(Guid idUserLessonPack) => _repo.GetUserLessonPackByIdAsync(idUserLessonPack);
        public Task<IEnumerable<UserLessonPack>> GetUserLessonPacksByUserIdAsync(Guid idUser) => _repo.GetUserLessonPacksByUserIdAsync(idUser);
        public Task<Guid> InsertUserLessonPackAsync(UserLessonPack userLessonPack) => _repo.InsertUserLessonPackAsync(userLessonPack);
        public Task<int> UpdateUserLessonPackAsync(UserLessonPack userLessonPack) => _repo.UpdateUserLessonPackAsync(userLessonPack);
        public Task<int> DeleteUserLessonPackAsync(Guid idUserLessonPack) => _repo.DeleteUserLessonPackAsync(idUserLessonPack);

        public Task<IEnumerable<PackTransaction>> GetPackTransactionsAllAsync() => _repo.GetPackTransactionsAllAsync();
        public Task<PackTransaction?> GetPackTransactionByIdAsync(Guid idPackTransaction) => _repo.GetPackTransactionByIdAsync(idPackTransaction);
        public Task<IEnumerable<PackTransaction>> GetPackTransactionsByUserLessonPackIdAsync(Guid idUserLessonPack) => _repo.GetPackTransactionsByUserLessonPackIdAsync(idUserLessonPack);
        public Task<Guid> InsertPackTransactionAsync(PackTransaction packTransaction) => _repo.InsertPackTransactionAsync(packTransaction);
        public Task<int> DeletePackTransactionAsync(Guid idPackTransaction) => _repo.DeletePackTransactionAsync(idPackTransaction);
    }
}
