using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;

namespace ConfidantPostgreSQL.Modules.Student.Service
{
    public interface IMyTutorsService
    {
        Task<IReadOnlyList<MyTutorDto>> GetMyTutorsAsync(Guid studentUserId, Guid? areaId = null);
    }
}
