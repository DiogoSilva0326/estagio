using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Lessons.Models;

namespace ConfidantPostgreSQL.Modules.Lessons.Repository
{
    public interface ILessonsRepository
    {
        Task<IEnumerable<Lesson>> GetLessonsAllAsync();
        Task<Lesson?> GetLessonByIdAsync(Guid idLesson);
        Task<Guid> InsertLessonAsync(Lesson lesson);
        Task<int> UpdateLessonAsync(Lesson lesson);
        Task<int> DeleteLessonAsync(Guid idLesson);

        Task<IEnumerable<LessonFeedback>> GetLessonFeedbackAllAsync();
        Task<LessonFeedback?> GetLessonFeedbackByIdAsync(Guid idLessonFeedback);
        Task<Guid> InsertLessonFeedbackAsync(LessonFeedback feedback);
        Task<int> UpdateLessonFeedbackAsync(LessonFeedback feedback);
        Task<int> DeleteLessonFeedbackAsync(Guid idLessonFeedback);

        Task<IEnumerable<LessonPrice>> GetLessonPricesAllAsync();
        Task<LessonPrice?> GetLessonPriceByIdAsync(Guid idLessonPrice);
        Task<Guid> InsertLessonPriceAsync(LessonPrice price);
        Task<int> UpdateLessonPriceAsync(LessonPrice price);
        Task<int> DeleteLessonPriceAsync(Guid idLessonPrice);

        Task<IEnumerable<LessonScheduleBlock>> GetLessonScheduleBlocksAllAsync();
        Task<LessonScheduleBlock?> GetLessonScheduleBlockByIdAsync(Guid idLessonScheduleBlock);
        Task<Guid> InsertLessonScheduleBlockAsync(LessonScheduleBlock block);
        Task<int> UpdateLessonScheduleBlockAsync(LessonScheduleBlock block);
        Task<int> DeleteLessonScheduleBlockAsync(Guid idLessonScheduleBlock);

        Task<IEnumerable<Enrollment>> GetEnrollmentsAllAsync();
        Task<Enrollment?> GetEnrollmentByIdAsync(Guid idEnrollment);
        Task<Enrollment?> GetEnrollmentByLessonAndUserAsync(Guid idLesson, Guid idUser);
        Task<Guid> InsertEnrollmentAsync(Enrollment enrollment);
        Task<int> UpdateEnrollmentAsync(Enrollment enrollment);
        Task<int> DeleteEnrollmentAsync(Guid idEnrollment);
        Task<IEnumerable<Enrollment>> GetEnrollmentsByLessonAsync(Guid idLesson);
    }
}
