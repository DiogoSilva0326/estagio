using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Complaints.Models;

namespace ConfidantPostgreSQL.Modules.Complaints.Repository
{
    public interface IComplaintsRepository
    {
        Task<IEnumerable<Complaint>> GetComplaintsAllAsync();
        Task<Complaint?> GetComplaintByIdAsync(Guid idComplaint);
        Task<Guid> InsertComplaintAsync(Complaint complaint);
        Task<int> UpdateComplaintAsync(Complaint complaint);
        Task<int> DeleteComplaintAsync(Guid idComplaint);

        Task<IEnumerable<ComplaintResolution>> GetComplaintResolutionsAllAsync();
        Task<ComplaintResolution?> GetComplaintResolutionByIdAsync(Guid idComplaintResolution);
        Task<Guid> InsertComplaintResolutionAsync(ComplaintResolution resolution);
        Task<int> UpdateComplaintResolutionAsync(ComplaintResolution resolution);
        Task<int> DeleteComplaintResolutionAsync(Guid idComplaintResolution);
    }
}
