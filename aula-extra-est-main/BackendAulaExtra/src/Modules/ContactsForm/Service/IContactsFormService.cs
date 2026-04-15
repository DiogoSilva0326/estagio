using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.ContactsForm.Models;

namespace ConfidantPostgreSQL.Modules.ContactsForm.Service
{
    public interface IContactsFormService
    {
        Task<IEnumerable<ContactFormCategory>> GetContactFormCategoriesAllAsync();
        Task<ContactFormCategory?> GetContactFormCategoryByIdAsync(Guid idContactFormCategory);
        Task<Guid> InsertContactFormCategoryAsync(ContactFormCategory category);
        Task<int> UpdateContactFormCategoryAsync(ContactFormCategory category);
        Task<int> DeleteContactFormCategoryAsync(Guid idContactFormCategory);

        Task<IEnumerable<ContactFormSubmission>> GetContactFormSubmissionsAllAsync(string? status = null);
        Task<ContactFormSubmission?> GetContactFormSubmissionByIdAsync(Guid idContactFormSubmission);
        Task<Guid> InsertContactFormSubmissionAsync(ContactFormSubmission submission);
        Task<int> UpdateContactFormSubmissionAsync(ContactFormSubmission submission);
        Task<int> DeleteContactFormSubmissionAsync(Guid idContactFormSubmission);
    }
}
