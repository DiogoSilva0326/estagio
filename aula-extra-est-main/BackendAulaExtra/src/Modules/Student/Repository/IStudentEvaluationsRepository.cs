using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;

namespace ConfidantPostgreSQL.Modules.Student.Repository
{
    public interface IStudentEvaluationsRepository
    {
        Task<IReadOnlyList<SubmittedEvaluationDto>> GetSubmittedAsync(Guid studentUserId);
        Task<IReadOnlyList<PendingEvaluationDto>> GetPendingLatestPerProfessorAsync(Guid studentUserId);
        Task<PendingEvaluationDto?> GetPendingByLessonIdAsync(Guid studentUserId, Guid lessonId);
        Task<Guid> InsertLessonFeedbackAsync(Guid studentUserId, Guid lessonId, int rating, string? comments);
    }
}
