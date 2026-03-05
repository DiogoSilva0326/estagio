using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Complaints.Models;
using ConfidantPostgreSQL.Modules.Complaints.Repository;

namespace ConfidantPostgreSQL.Modules.Complaints.Service
{
    public class ComplaintsService : IComplaintsService
    {
        private readonly IComplaintsRepository _repo;

        public ComplaintsService(IComplaintsRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Complaint>> GetComplaintsAllAsync() => _repo.GetComplaintsAllAsync();
        public Task<Complaint?> GetComplaintByIdAsync(Guid idComplaint) => _repo.GetComplaintByIdAsync(idComplaint);
        public Task<Guid> InsertComplaintAsync(Complaint complaint) => _repo.InsertComplaintAsync(complaint);
        public Task<int> UpdateComplaintAsync(Complaint complaint) => _repo.UpdateComplaintAsync(complaint);
        public Task<int> DeleteComplaintAsync(Guid idComplaint) => _repo.DeleteComplaintAsync(idComplaint);

        public Task<IEnumerable<ComplaintResolution>> GetComplaintResolutionsAllAsync() => _repo.GetComplaintResolutionsAllAsync();
        public Task<ComplaintResolution?> GetComplaintResolutionByIdAsync(Guid idComplaintResolution) => _repo.GetComplaintResolutionByIdAsync(idComplaintResolution);
        public Task<Guid> InsertComplaintResolutionAsync(ComplaintResolution resolution) => _repo.InsertComplaintResolutionAsync(resolution);
        public Task<int> UpdateComplaintResolutionAsync(ComplaintResolution resolution) => _repo.UpdateComplaintResolutionAsync(resolution);
        public Task<int> DeleteComplaintResolutionAsync(Guid idComplaintResolution) => _repo.DeleteComplaintResolutionAsync(idComplaintResolution);
    }
}
