using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.ContactsForm.Models;
using ConfidantPostgreSQL.Modules.ContactsForm.Repository;

namespace ConfidantPostgreSQL.Modules.ContactsForm.Service
{
    public class ContactsFormService : IContactsFormService
    {
        private readonly IContactsFormRepository _repo;

        public ContactsFormService(IContactsFormRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<ContactFormCategory>> GetContactFormCategoriesAllAsync() => _repo.GetContactFormCategoriesAllAsync();
        public Task<ContactFormCategory?> GetContactFormCategoryByIdAsync(Guid idContactFormCategory) => _repo.GetContactFormCategoryByIdAsync(idContactFormCategory);
        public Task<Guid> InsertContactFormCategoryAsync(ContactFormCategory category) => _repo.InsertContactFormCategoryAsync(category);
        public Task<int> UpdateContactFormCategoryAsync(ContactFormCategory category) => _repo.UpdateContactFormCategoryAsync(category);
        public Task<int> DeleteContactFormCategoryAsync(Guid idContactFormCategory) => _repo.DeleteContactFormCategoryAsync(idContactFormCategory);

        public Task<IEnumerable<ContactFormSubmission>> GetContactFormSubmissionsAllAsync(string? status = null) => _repo.GetContactFormSubmissionsAllAsync(status);
        public Task<ContactFormSubmission?> GetContactFormSubmissionByIdAsync(Guid idContactFormSubmission) => _repo.GetContactFormSubmissionByIdAsync(idContactFormSubmission);
        public Task<Guid> InsertContactFormSubmissionAsync(ContactFormSubmission submission) => _repo.InsertContactFormSubmissionAsync(submission);
        public Task<int> UpdateContactFormSubmissionAsync(ContactFormSubmission submission) => _repo.UpdateContactFormSubmissionAsync(submission);
        public Task<int> DeleteContactFormSubmissionAsync(Guid idContactFormSubmission) => _repo.DeleteContactFormSubmissionAsync(idContactFormSubmission);
    }
}
