using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.SystemSettings.Models;

namespace ConfidantPostgreSQL.Modules.SystemSettings.Repository;

public interface ISystemSettingsRepository
{
    Task<Guid> InsertAsync(SystemSetting setting, CancellationToken cancellationToken = default);
    Task<int> UpdateAsync(SystemSetting setting, CancellationToken cancellationToken = default);
    Task<int> DeleteAsync(Guid id, CancellationToken cancellationToken = default);
    Task<SystemSetting?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<SystemSetting?> GetByKeyAsync(string settingsKey, CancellationToken cancellationToken = default);
    Task<List<SystemSetting>> GetSummaryAsync(string orderColumns, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<List<SystemSetting>> SearchAsync(string search, string orderColumns, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
}