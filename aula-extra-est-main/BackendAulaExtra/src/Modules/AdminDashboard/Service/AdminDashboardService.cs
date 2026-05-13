using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.AdminDashboard.Models;
using ConfidantPostgreSQL.Modules.AdminDashboard.Repository;

namespace ConfidantPostgreSQL.Modules.AdminDashboard.Service
{
    public class AdminDashboardService : IAdminDashboardService
    {
        private readonly IAdminDashboardRepository _repository;

        public AdminDashboardService(IAdminDashboardRepository repository)
        {
            _repository = repository;
        }

        public Task<AdminDashboardResponse> GetAsync() => _repository.GetAsync();

        public Task<IReadOnlyList<AdminSessionLogItem>> GetSessionLogsAsync() =>
            _repository.GetSessionLogsAsync();

        public Task<AdminEvaluationsResponse> GetEvaluationsAsync() =>
            _repository.GetEvaluationsAsync();

        public Task<int> ModerateEvaluationAsync(string kind, Guid evaluationId, bool isValid) =>
            _repository.ModerateEvaluationAsync(kind, evaluationId, isValid);
    }
}