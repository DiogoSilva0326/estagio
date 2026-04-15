using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Faq.Models;

namespace ConfidantPostgreSQL.Modules.Faq.Service
{
    public interface IFaqService
    {
        Task<IEnumerable<FaqEntry>> GetPublicFaqsAsync(Guid? idFaqCategory = null, string? query = null);
        Task<IEnumerable<FaqCategorySummary>> GetPublicCategoriesAsync();

        Task<IEnumerable<FaqEntry>> GetFaqsAllAsync();
        Task<FaqEntry?> GetFaqByIdAsync(Guid idFaq);
        Task<Guid> InsertFaqAsync(FaqEntry faq);
        Task<int> UpdateFaqAsync(FaqEntry faq);
        Task<int> DeleteFaqAsync(Guid idFaq);

        Task<IEnumerable<FaqCategory>> GetCategoriesAllAsync();
        Task<FaqCategory?> GetCategoryByIdAsync(Guid idFaqCategory);
        Task<Guid> InsertCategoryAsync(FaqCategory category);
        Task<int> UpdateCategoryAsync(FaqCategory category);
        Task<int> DeleteCategoryAsync(Guid idFaqCategory);
    }
}
