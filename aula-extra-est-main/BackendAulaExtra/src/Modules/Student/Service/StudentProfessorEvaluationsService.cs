using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;
using ConfidantPostgreSQL.Modules.Student.Repository;

namespace ConfidantPostgreSQL.Modules.Student.Service
{
    public class StudentProfessorEvaluationsService : IStudentProfessorEvaluationsService
    {
        private readonly IStudentProfessorEvaluationsRepository _repo;

        public StudentProfessorEvaluationsService(IStudentProfessorEvaluationsRepository repo)
        {
            _repo = repo;
        }

        public Task<IReadOnlyList<SubmittedProfessorEvaluationDto>> GetSubmittedAsync(Guid studentUserId)
            => _repo.GetSubmittedAsync(studentUserId);

        public Task<IReadOnlyList<PendingProfessorEvaluationDto>> GetPendingAsync(Guid studentUserId)
            => _repo.GetPendingAsync(studentUserId);

        public async Task<(Guid professorFeedbackId, PendingProfessorEvaluationDto pending)> SubmitAsync(
            Guid studentUserId,
            Guid professorId,
            int rating,
            string? comments)
        {
            var pending = await _repo.GetPendingByProfessorIdAsync(studentUserId, professorId);
            if (pending == null)
                return (Guid.Empty, new PendingProfessorEvaluationDto());

            var id = await _repo.InsertProfessorFeedbackAsync(studentUserId, professorId, rating, comments);
            return (id, pending);
        }
    }
}
