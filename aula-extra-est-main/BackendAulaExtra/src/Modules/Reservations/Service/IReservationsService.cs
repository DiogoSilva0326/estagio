using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Reservations.Models;

namespace ConfidantPostgreSQL.Modules.Reservations.Service
{
    public interface IReservationsService
    {
        Task<IEnumerable<Reservation>> GetReservationsAllAsync();
        Task<Reservation?> GetReservationByIdAsync(Guid idReservation);
        Task<Reservation?> GetReservationByLessonAndUserAsync(Guid idLesson, Guid idUser);
        Task<Guid> InsertReservationAsync(Reservation reservation);
        Task<int> UpdateReservationAsync(Reservation reservation);
        Task<int> DeleteReservationAsync(Guid idReservation);
        Task<IEnumerable<Reservation>> GetReservationsByLessonAsync(Guid idLesson);

        Task<IEnumerable<StudentCalendarItem>> GetMyWeekAsync(Guid studentUserId, DateTime weekStart, DateTime weekEnd);
        Task<IEnumerable<StudentCalendarItem>> GetMyUpcomingAsync(Guid studentUserId, DateTime from, int limit);
        Task<AreaLessonSummary> GetMyAreaLessonSummaryAsync(Guid studentUserId, Guid areaId, DateTime from);
        Task<IEnumerable<ProfessorCalendarItem>> GetProfessorWeekAsync(Guid professorId, DateTime weekStart, DateTime weekEnd, string? targetRole = null);
        Task<IEnumerable<ProfessorCalendarItem>> GetProfessorUpcomingAsync(Guid professorId, DateTime from, int limit, string? targetRole = null);

        Task<IEnumerable<ExceptionRule>> GetExceptionRulesAllAsync();
        Task<ExceptionRule?> GetExceptionRuleByIdAsync(Guid idExceptionRule);
        Task<Guid> InsertExceptionRuleAsync(ExceptionRule rule);
        Task<int> UpdateExceptionRuleAsync(ExceptionRule rule);
        Task<int> DeleteExceptionRuleAsync(Guid idExceptionRule);

        Task<IEnumerable<ExceptionRequest>> GetExceptionRequestsAllAsync();
        Task<ExceptionRequest?> GetExceptionRequestByIdAsync(Guid idExceptionRequest);
        Task<Guid> InsertExceptionRequestAsync(ExceptionRequest request);
        Task<int> UpdateExceptionRequestAsync(ExceptionRequest request);
        Task<int> DeleteExceptionRequestAsync(Guid idExceptionRequest);
    }
}
