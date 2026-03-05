using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Student.DTOs;
using ConfidantPostgreSQL.Modules.Student.Repository;

namespace ConfidantPostgreSQL.Modules.Student.Service
{
    public class MyTutorsService : IMyTutorsService
    {
        private readonly IMyTutorsRepository _repo;

        public MyTutorsService(IMyTutorsRepository repo)
        {
            _repo = repo;
        }

        public Task<IReadOnlyList<MyTutorDto>> GetMyTutorsAsync(Guid studentUserId)
        {
            if (studentUserId == Guid.Empty)
                return Task.FromResult<IReadOnlyList<MyTutorDto>>(Array.Empty<MyTutorDto>());

            return _repo.GetMyTutorsAsync(studentUserId);
        }
    }
}
