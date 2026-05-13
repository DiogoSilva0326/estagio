using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Integrations.Email;
using ConfidantPostgreSQL.Modules.ContactsForm.Models;
using ConfidantPostgreSQL.Modules.ContactsForm.Repository;

namespace ConfidantPostgreSQL.Modules.ContactsForm.Service
{
    public class ContactsFormService : IContactsFormService
    {
        private readonly IContactsFormRepository _repo;
        private readonly IPostmarkService _postmarkService;

        public ContactsFormService(IContactsFormRepository repo, IPostmarkService postmarkService)
        {
            _repo = repo;
            _postmarkService = postmarkService;
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
        public async Task<bool> ReplyToContactFormSubmissionAsync(Guid idContactFormSubmission, Guid? responderUserId, string? responseMessage, string? status)
        {
            var submission = await _repo.GetContactFormSubmissionByIdAsync(idContactFormSubmission);
            if (submission == null)
            {
                return false;
            }

            var normalizedStatus = NormalizeReplyStatus(status, hasResponseMessage: !string.IsNullOrWhiteSpace(responseMessage));
            var trimmedResponse = responseMessage?.Trim();

            if (!string.IsNullOrWhiteSpace(trimmedResponse))
            {
                if (string.IsNullOrWhiteSpace(submission.Email))
                {
                    throw new InvalidOperationException("O formulário não tem email disponível.");
                }

                var subject = string.IsNullOrWhiteSpace(submission.Subject)
                    ? "Resposta ao seu formulário de contacto"
                    : $"Resposta ao seu formulário: {submission.Subject.Trim()}";
                var originalMessage = string.IsNullOrWhiteSpace(submission.Message)
                    ? "Sem mensagem original disponível."
                    : submission.Message.Trim();
                var plainBody =
                    $"Recebemos o seu formulário de contacto na Aula Extra.\n\n" +
                    $"Assunto: {(submission.Subject?.Trim() ?? "Sem assunto")}\n\n" +
                    $"Resposta da equipa:\n{trimmedResponse}\n\n" +
                    $"Mensagem original:\n{originalMessage}";

                var dto = new EmailSenderDto
                {
                    To = submission.Email,
                    Subject = subject,
                    TextBody = plainBody,
                    HtmlBody = EmailTemplates.Jacurvas(subject, plainBody),
                    Tag = "contact-form-reply",
                    MessageStream = "outbound"
                };

                var sent = await _postmarkService.SendEmailAsync(dto);
                if (!sent)
                {
                    throw new InvalidOperationException("Não foi possível enviar a resposta por email.");
                }
            }

            submission.Status = normalizedStatus;
            submission.UserIdResponse = normalizedStatus == "respondida"
                ? responderUserId ?? submission.UserIdResponse
                : submission.UserIdResponse;
            submission.UpdatedAt = DateTimeOffset.UtcNow;

            var rows = await _repo.UpdateContactFormSubmissionAsync(submission);
            return rows > 0;
        }
        public Task<int> DeleteContactFormSubmissionAsync(Guid idContactFormSubmission) => _repo.DeleteContactFormSubmissionAsync(idContactFormSubmission);

        private static string NormalizeReplyStatus(string? status, bool hasResponseMessage)
        {
            var normalized = (status ?? string.Empty).Trim().ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(normalized))
            {
                return hasResponseMessage ? "respondida" : "lida";
            }

            return normalized switch
            {
                "lida" => "lida",
                "respondida" => "respondida",
                _ => throw new ArgumentException("O estado indicado é inválido.")
            };
        }
    }
}
