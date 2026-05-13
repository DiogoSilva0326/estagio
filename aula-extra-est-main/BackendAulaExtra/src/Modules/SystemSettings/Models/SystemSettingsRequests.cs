using System;

namespace ConfidantPostgreSQL.Modules.SystemSettings.Models;

public class InsertSystemSettingRequest
{
    public string SettingsKey { get; set; } = string.Empty;
    public string? SettingsValue { get; set; }
    public string? DataType { get; set; }
    public string? Description { get; set; }
}

public class UpdateSystemSettingRequest
{
    public Guid Id { get; set; }
    public string? SettingsKey { get; set; }
    public string? SettingsValue { get; set; }
    public string? DataType { get; set; }
    public string? Description { get; set; }
}