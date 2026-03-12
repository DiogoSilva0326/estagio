using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;

namespace ConfidantPostgreSQL.Modules.Student.Service
{
    public interface IStudentEvaluationsService
    {
        Task<IReadOnlyList<SubmittedEvaluationDto>> GetSubmittedAsync(Guid studentUserId);
        Task<IReadOnlyList<PendingEvaluationDto>> GetPendingAsync(Guid studentUserId);
        Task<(Guid lessonFeedbackId, PendingEvaluationDto pending)> SubmitAsync(Guid studentUserId, Guid lessonId, int rating, string? comments);
    }
}
