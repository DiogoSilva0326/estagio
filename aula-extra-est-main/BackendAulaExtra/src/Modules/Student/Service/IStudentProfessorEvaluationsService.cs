using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;

namespace ConfidantPostgreSQL.Modules.Student.Service
{
    public interface IStudentProfessorEvaluationsService
    {
        Task<IReadOnlyList<SubmittedProfessorEvaluationDto>> GetSubmittedAsync(Guid studentUserId);
        Task<IReadOnlyList<PendingProfessorEvaluationDto>> GetPendingAsync(Guid studentUserId);
        Task<(Guid professorFeedbackId, PendingProfessorEvaluationDto pending)> SubmitAsync(Guid studentUserId, Guid professorId, int rating, string? comments);
    }
}
