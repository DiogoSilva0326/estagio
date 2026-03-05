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
        public Task<Guid> InsertReservationAsync(Reservation reservation) => _repo.InsertReservationAsync(reservation);
        public Task<int> UpdateReservationAsync(Reservation reservation) => _repo.UpdateReservationAsync(reservation);
        public Task<int> DeleteReservationAsync(Guid idReservation) => _repo.DeleteReservationAsync(idReservation);

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
