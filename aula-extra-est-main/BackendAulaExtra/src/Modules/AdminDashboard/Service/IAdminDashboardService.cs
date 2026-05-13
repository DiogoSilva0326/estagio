using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.AdminDashboard.Models;

namespace ConfidantPostgreSQL.Modules.AdminDashboard.Service
{
    public interface IAdminDashboardService
    {
        Task<AdminDashboardResponse> GetAsync();
        Task<IReadOnlyList<AdminSessionLogItem>> GetSessionLogsAsync();
        Task<AdminEvaluationsResponse> GetEvaluationsAsync();
        Task<int> ModerateEvaluationAsync(string kind, Guid evaluationId, bool isValid);
    }
}