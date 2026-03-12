using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;
using ConfidantPostgreSQL.Modules.Student.Repository;

namespace ConfidantPostgreSQL.Modules.Student.Service
{
    public class StudentEvaluationsService : IStudentEvaluationsService
    {
        private readonly IStudentEvaluationsRepository _repo;

        public StudentEvaluationsService(IStudentEvaluationsRepository repo)
        {
            _repo = repo;
        }

        public Task<IReadOnlyList<SubmittedEvaluationDto>> GetSubmittedAsync(Guid studentUserId)
        {
            if (studentUserId == Guid.Empty)
                return Task.FromResult<IReadOnlyList<SubmittedEvaluationDto>>(Array.Empty<SubmittedEvaluationDto>());

            return _repo.GetSubmittedAsync(studentUserId);
        }

        public Task<IReadOnlyList<PendingEvaluationDto>> GetPendingAsync(Guid studentUserId)
        {
            if (studentUserId == Guid.Empty)
                return Task.FromResult<IReadOnlyList<PendingEvaluationDto>>(Array.Empty<PendingEvaluationDto>());

            return _repo.GetPendingLatestPerProfessorAsync(studentUserId);
        }

        public async Task<(Guid lessonFeedbackId, PendingEvaluationDto pending)> SubmitAsync(Guid studentUserId, Guid lessonId, int rating, string? comments)
        {
            if (studentUserId == Guid.Empty) return (Guid.Empty, null!);
            if (lessonId == Guid.Empty) return (Guid.Empty, null!);

            var pending = await _repo.GetPendingByLessonIdAsync(studentUserId, lessonId);
            if (pending == null) return (Guid.Empty, null!);

            var id = await _repo.InsertLessonFeedbackAsync(studentUserId, lessonId, rating, comments);
            return (id, pending);
        }
    }
}
