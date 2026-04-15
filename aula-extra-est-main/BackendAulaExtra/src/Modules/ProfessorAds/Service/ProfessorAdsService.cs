using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.ProfessorAds.Models;
using ConfidantPostgreSQL.Modules.ProfessorAds.Repository;

namespace ConfidantPostgreSQL.Modules.ProfessorAds.Service
{
    public class ProfessorAdsService : IProfessorAdsService
    {
        private readonly IProfessorAdsRepository _repo;

        public ProfessorAdsService(IProfessorAdsRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<ProfessorAd>> GetProfessorAdsByProfessorIdAsync(Guid idProfessor) =>
            _repo.GetProfessorAdsByProfessorIdAsync(idProfessor);

        public Task<ProfessorAd?> GetProfessorAdByIdAsync(Guid idProfessorAd, Guid idProfessor) =>
            _repo.GetProfessorAdByIdAsync(idProfessorAd, idProfessor);

        public Task<ProfessorAd> UpsertProfessorAdAsync(Guid idProfessor, ProfessorAdUpsert input) =>
            _repo.UpsertProfessorAdAsync(idProfessor, input);

        public Task<ProfessorAd?> UpdateProfessorAdStatusAsync(Guid idProfessorAd, Guid idProfessor, string status) =>
            _repo.UpdateProfessorAdStatusAsync(idProfessorAd, idProfessor, status);

        public Task<int> DeleteProfessorAdAsync(Guid idProfessorAd, Guid idProfessor) =>
            _repo.DeleteProfessorAdAsync(idProfessorAd, idProfessor);
    }
}
