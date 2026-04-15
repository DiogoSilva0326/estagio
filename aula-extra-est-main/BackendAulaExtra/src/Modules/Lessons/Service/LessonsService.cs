using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Lessons.Models;
using ConfidantPostgreSQL.Modules.Lessons.Repository;

namespace ConfidantPostgreSQL.Modules.Lessons.Service
{
    public class LessonsService : ILessonsService
    {
        private readonly ILessonsRepository _repo;

        public LessonsService(ILessonsRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Lesson>> GetLessonsAllAsync() => _repo.GetLessonsAllAsync();
        public Task<Lesson?> GetLessonByIdAsync(Guid idLesson) => _repo.GetLessonByIdAsync(idLesson);
        public Task<Guid> InsertLessonAsync(Lesson lesson) => _repo.InsertLessonAsync(lesson);
        public Task<int> UpdateLessonAsync(Lesson lesson) => _repo.UpdateLessonAsync(lesson);
        public Task<int> DeleteLessonAsync(Guid idLesson) => _repo.DeleteLessonAsync(idLesson);

        public Task<IEnumerable<LessonFeedback>> GetLessonFeedbackAllAsync() => _repo.GetLessonFeedbackAllAsync();
        public Task<LessonFeedback?> GetLessonFeedbackByIdAsync(Guid idLessonFeedback) => _repo.GetLessonFeedbackByIdAsync(idLessonFeedback);
        public Task<Guid> InsertLessonFeedbackAsync(LessonFeedback feedback) => _repo.InsertLessonFeedbackAsync(feedback);
        public Task<int> UpdateLessonFeedbackAsync(LessonFeedback feedback) => _repo.UpdateLessonFeedbackAsync(feedback);
        public Task<int> DeleteLessonFeedbackAsync(Guid idLessonFeedback) => _repo.DeleteLessonFeedbackAsync(idLessonFeedback);

        public Task<IEnumerable<LessonPrice>> GetLessonPricesAllAsync() => _repo.GetLessonPricesAllAsync();
        public Task<LessonPrice?> GetLessonPriceByIdAsync(Guid idLessonPrice) => _repo.GetLessonPriceByIdAsync(idLessonPrice);
        public Task<Guid> InsertLessonPriceAsync(LessonPrice price) => _repo.InsertLessonPriceAsync(price);
        public Task<int> UpdateLessonPriceAsync(LessonPrice price) => _repo.UpdateLessonPriceAsync(price);
        public Task<int> DeleteLessonPriceAsync(Guid idLessonPrice) => _repo.DeleteLessonPriceAsync(idLessonPrice);

        public Task<IEnumerable<LessonScheduleBlock>> GetLessonScheduleBlocksAllAsync() => _repo.GetLessonScheduleBlocksAllAsync();
        public Task<LessonScheduleBlock?> GetLessonScheduleBlockByIdAsync(Guid idLessonScheduleBlock) => _repo.GetLessonScheduleBlockByIdAsync(idLessonScheduleBlock);
        public Task<Guid> InsertLessonScheduleBlockAsync(LessonScheduleBlock block) => _repo.InsertLessonScheduleBlockAsync(block);
        public Task<int> UpdateLessonScheduleBlockAsync(LessonScheduleBlock block) => _repo.UpdateLessonScheduleBlockAsync(block);
        public Task<int> DeleteLessonScheduleBlockAsync(Guid idLessonScheduleBlock) => _repo.DeleteLessonScheduleBlockAsync(idLessonScheduleBlock);

        public Task<IEnumerable<Enrollment>> GetEnrollmentsAllAsync() => _repo.GetEnrollmentsAllAsync();
        public Task<Enrollment?> GetEnrollmentByIdAsync(Guid idEnrollment) => _repo.GetEnrollmentByIdAsync(idEnrollment);
        public Task<Enrollment?> GetEnrollmentByLessonAndUserAsync(Guid idLesson, Guid idUser) =>
            _repo.GetEnrollmentByLessonAndUserAsync(idLesson, idUser);
        public Task<IEnumerable<Enrollment>> GetEnrollmentsByLessonAsync(Guid idLesson) =>
            _repo.GetEnrollmentsByLessonAsync(idLesson);
        public Task<Guid> InsertEnrollmentAsync(Enrollment enrollment) => _repo.InsertEnrollmentAsync(enrollment);
        public Task<int> UpdateEnrollmentAsync(Enrollment enrollment) => _repo.UpdateEnrollmentAsync(enrollment);
        public Task<int> DeleteEnrollmentAsync(Guid idEnrollment) => _repo.DeleteEnrollmentAsync(idEnrollment);
    }
}
