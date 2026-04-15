using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.ProfessorAds.Models;

namespace ConfidantPostgreSQL.Modules.ProfessorAds.Repository
{
    public interface IProfessorAdsRepository
    {
        Task<IEnumerable<ProfessorAd>> GetProfessorAdsByProfessorIdAsync(Guid idProfessor);
        Task<ProfessorAd?> GetProfessorAdByIdAsync(Guid idProfessorAd, Guid idProfessor);
        Task<ProfessorAd> UpsertProfessorAdAsync(Guid idProfessor, ProfessorAdUpsert input);
        Task<ProfessorAd?> UpdateProfessorAdStatusAsync(Guid idProfessorAd, Guid idProfessor, string status);
        Task<int> DeleteProfessorAdAsync(Guid idProfessorAd, Guid idProfessor);
    }
}
