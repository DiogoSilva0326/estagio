using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.SystemSettings.Models;
using ConfidantPostgreSQL.Modules.SystemSettings.Repository;

namespace ConfidantPostgreSQL.Modules.SystemSettings.Service;

public class SystemSettingsService : ISystemSettingsService
{
    private readonly ISystemSettingsRepository _repository;

    public SystemSettingsService(ISystemSettingsRepository repository)
    {
        _repository = repository;
    }

    public Task<SystemSetting?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
        => _repository.GetByIdAsync(id, cancellationToken);

    public Task<SystemSetting?> GetByKeyAsync(string settingsKey, CancellationToken cancellationToken = default)
        => _repository.GetByKeyAsync(settingsKey, cancellationToken);

    public Task<List<SystemSetting>> GetSummaryAsync(string orderColumns, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => _repository.GetSummaryAsync(orderColumns, pageNumber, pageSize, cancellationToken);

    public Task<List<SystemSetting>> SearchAsync(string search, string orderColumns, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
        => _repository.SearchAsync(search, orderColumns, pageNumber, pageSize, cancellationToken);

    public Task<int> DeleteAsync(Guid id, CancellationToken cancellationToken = default)
        => _repository.DeleteAsync(id, cancellationToken);

    public Task<Guid> InsertAsync(InsertSystemSettingRequest request, CancellationToken cancellationToken = default)
    {
        Validate(request.SettingsKey, request.DataType, request.Description);
        return _repository.InsertAsync(
            new SystemSetting
            {
                SettingsKey = request.SettingsKey.Trim(),
                SettingsValue = request.SettingsValue?.Trim(),
                DataType = request.DataType?.Trim(),
                Description = request.Description?.Trim(),
            },
            cancellationToken);
    }

    public async Task<SystemSetting?> UpdateAsync(UpdateSystemSettingRequest request, CancellationToken cancellationToken = default)
    {
        if (request.Id == Guid.Empty)
        {
            throw new InvalidOperationException("O identificador da configuração é obrigatório.");
        }

        var current = await _repository.GetByIdAsync(request.Id, cancellationToken);
        if (current == null)
        {
            return null;
        }

        var next = new SystemSetting
        {
            Id = request.Id,
            SettingsKey = (request.SettingsKey ?? current.SettingsKey).Trim(),
            SettingsValue = request.SettingsValue ?? current.SettingsValue,
            DataType = request.DataType ?? current.DataType,
            Description = request.Description ?? current.Description,
        };

        Validate(next.SettingsKey, next.DataType, next.Description);
        var rows = await _repository.UpdateAsync(next, cancellationToken);
        return rows > 0 ? await _repository.GetByIdAsync(request.Id, cancellationToken) : null;
    }

    private static void Validate(string? settingsKey, string? dataType, string? description)
    {
        if (string.IsNullOrWhiteSpace(settingsKey))
        {
            throw new InvalidOperationException("A chave da configuração é obrigatória.");
        }

        if (settingsKey.Trim().Length > 100)
        {
            throw new InvalidOperationException("A chave da configuração não pode exceder 100 caracteres.");
        }

        if (!string.IsNullOrWhiteSpace(dataType) && dataType.Trim().Length > 50)
        {
            throw new InvalidOperationException("O tipo de dados não pode exceder 50 caracteres.");
        }

        if (!string.IsNullOrWhiteSpace(description) && description.Trim().Length > 500)
        {
            throw new InvalidOperationException("A descrição não pode exceder 500 caracteres.");
        }
    }
}