using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Reservations.Models;
using ConfidantPostgreSQL.Modules.Reservations.Repository;

namespace ConfidantPostgreSQL.Modules.Reservations.Service
{
    public class ReservationsService : IReservationsService
    {
        private readonly IReservationsRepository _repo;

        public ReservationsService(IReservationsRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Reservation>> GetReservationsAllAsync() => _repo.GetReservationsAllAsync();
        public Task<Reservation?> GetReservationByIdAsync(Guid idReservation) => _repo.GetReservationByIdAsync(idReservation);
        public Task<Reservation?> GetReservationByLessonAndUserAsync(Guid idLesson, Guid idUser) =>
            _repo.GetReservationByLessonAndUserAsync(idLesson, idUser);
        public Task<IEnumerable<Reservation>> GetReservationsByLessonAsync(Guid idLesson) => _repo.GetReservationsByLessonAsync(idLesson);
        public Task<Guid> InsertReservationAsync(Reservation reservation) => _repo.InsertReservationAsync(reservation);
        public Task<int> UpdateReservationAsync(Reservation reservation) => _repo.UpdateReservationAsync(reservation);
        public Task<int> DeleteReservationAsync(Guid idReservation) => _repo.DeleteReservationAsync(idReservation);

        public Task<IEnumerable<StudentCalendarItem>> GetMyWeekAsync(Guid studentUserId, DateTime weekStart, DateTime weekEnd) =>
            _repo.GetStudentCalendarAsync(studentUserId, weekStart, weekEnd);

        public Task<IEnumerable<StudentCalendarItem>> GetMyUpcomingAsync(Guid studentUserId, DateTime from, int limit) =>
            _repo.GetStudentUpcomingCalendarAsync(studentUserId, from, limit);

        public Task<AreaLessonSummary> GetMyAreaLessonSummaryAsync(Guid studentUserId, Guid areaId, DateTime from) =>
            _repo.GetStudentAreaLessonSummaryAsync(studentUserId, areaId, from);

        public Task<IEnumerable<ProfessorCalendarItem>> GetProfessorWeekAsync(Guid professorId, DateTime weekStart, DateTime weekEnd) =>
            _repo.GetProfessorCalendarAsync(professorId, weekStart, weekEnd);

        public Task<IEnumerable<ProfessorCalendarItem>> GetProfessorUpcomingAsync(Guid professorId, DateTime from, int limit) =>
            _repo.GetProfessorUpcomingCalendarAsync(professorId, from, limit);

        public Task<IEnumerable<ExceptionRule>> GetExceptionRulesAllAsync() => _repo.GetExceptionRulesAllAsync();
        public Task<ExceptionRule?> GetExceptionRuleByIdAsync(Guid idExceptionRule) => _repo.GetExceptionRuleByIdAsync(idExceptionRule);
        public Task<Guid> InsertExceptionRuleAsync(ExceptionRule rule) => _repo.InsertExceptionRuleAsync(rule);
        public Task<int> UpdateExceptionRuleAsync(ExceptionRule rule) => _repo.UpdateExceptionRuleAsync(rule);
        public Task<int> DeleteExceptionRuleAsync(Guid idExceptionRule) => _repo.DeleteExceptionRuleAsync(idExceptionRule);

        public Task<IEnumerable<ExceptionRequest>> GetExceptionRequestsAllAsync() => _repo.GetExceptionRequestsAllAsync();
        public Task<ExceptionRequest?> GetExceptionRequestByIdAsync(Guid idExceptionRequest) => _repo.GetExceptionRequestByIdAsync(idExceptionRequest);
        public Task<Guid> InsertExceptionRequestAsync(ExceptionRequest request) => _repo.InsertExceptionRequestAsync(request);
        public Task<int> UpdateExceptionRequestAsync(ExceptionRequest request) => _repo.UpdateExceptionRequestAsync(request);
        public Task<int> DeleteExceptionRequestAsync(Guid idExceptionRequest) => _repo.DeleteExceptionRequestAsync(idExceptionRequest);
    }
}
