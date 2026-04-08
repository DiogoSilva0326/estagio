namespace Synget_R2.Integrator.Models;

public sealed record DeleteFileResponse(
    string Key,
    bool Deleted,
    string Message);