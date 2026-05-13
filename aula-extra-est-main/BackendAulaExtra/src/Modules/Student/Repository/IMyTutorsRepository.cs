using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;

namespace ConfidantPostgreSQL.Modules.Student.Repository
{
    public interface IMyTutorsRepository
    {
        Task<IReadOnlyList<MyTutorDto>> GetMyTutorsAsync(Guid studentUserId, Guid? areaId = null, string? role = null);
    }
}
