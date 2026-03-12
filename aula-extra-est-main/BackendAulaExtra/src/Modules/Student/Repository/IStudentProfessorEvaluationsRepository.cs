using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;

namespace ConfidantPostgreSQL.Modules.Student.Repository
{
    public interface IStudentProfessorEvaluationsRepository
    {
        Task<IReadOnlyList<SubmittedProfessorEvaluationDto>> GetSubmittedAsync(Guid studentUserId);
        Task<IReadOnlyList<PendingProfessorEvaluationDto>> GetPendingAsync(Guid studentUserId);
        Task<PendingProfessorEvaluationDto?> GetPendingByProfessorIdAsync(Guid studentUserId, Guid professorId);
        Task<Guid> InsertProfessorFeedbackAsync(Guid studentUserId, Guid professorId, int rating, string? comments);
    }
}
