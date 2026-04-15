using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Faq.Models;
using ConfidantPostgreSQL.Modules.Faq.Repository;

namespace ConfidantPostgreSQL.Modules.Faq.Service
{
    public class FaqService : IFaqService
    {
        private readonly IFaqRepository _repo;

        public FaqService(IFaqRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<FaqEntry>> GetPublicFaqsAsync(Guid? idFaqCategory = null, string? query = null)
            => _repo.GetPublicFaqsAsync(idFaqCategory, query);

        public Task<IEnumerable<FaqCategorySummary>> GetPublicCategoriesAsync()
            => _repo.GetPublicCategoriesAsync();

        public Task<IEnumerable<FaqEntry>> GetFaqsAllAsync() => _repo.GetFaqsAllAsync();
        public Task<FaqEntry?> GetFaqByIdAsync(Guid idFaq) => _repo.GetFaqByIdAsync(idFaq);
        public Task<Guid> InsertFaqAsync(FaqEntry faq) => _repo.InsertFaqAsync(faq);
        public Task<int> UpdateFaqAsync(FaqEntry faq) => _repo.UpdateFaqAsync(faq);
        public Task<int> DeleteFaqAsync(Guid idFaq) => _repo.DeleteFaqAsync(idFaq);

        public Task<IEnumerable<FaqCategory>> GetCategoriesAllAsync() => _repo.GetCategoriesAllAsync();
        public Task<FaqCategory?> GetCategoryByIdAsync(Guid idFaqCategory) => _repo.GetCategoryByIdAsync(idFaqCategory);
        public Task<Guid> InsertCategoryAsync(FaqCategory category) => _repo.InsertCategoryAsync(category);
        public Task<int> UpdateCategoryAsync(FaqCategory category) => _repo.UpdateCategoryAsync(category);
        public Task<int> DeleteCategoryAsync(Guid idFaqCategory) => _repo.DeleteCategoryAsync(idFaqCategory);
    }
}
