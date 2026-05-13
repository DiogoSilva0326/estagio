using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Integrations.Email;
using ConfidantPostgreSQL.Modules.Complaints.Models;
using ConfidantPostgreSQL.Modules.Complaints.Repository;
using ConfidantPostgreSQL.Modules.Professors.Service;
using ConfidantPostgreSQL.Modules.Student.Service;
using ConfidantPostgreSQL.Modules.Users.Models;
using ConfidantPostgreSQL.Modules.Users.Service;

namespace ConfidantPostgreSQL.Modules.Complaints.Service
{
    public class ComplaintsService : IComplaintsService
    {
        private readonly IComplaintsRepository _repo;
        private readonly IMyTutorsService _myTutorsService;
        private readonly IProfessorsService _professorsService;
        private readonly IUserService _usersService;
        private readonly IPostmarkService _postmarkService;

        public ComplaintsService(
            IComplaintsRepository repo,
            IMyTutorsService myTutorsService,
            IProfessorsService professorsService,
            IUserService usersService,
            IPostmarkService postmarkService)
        {
            _repo = repo;
            _myTutorsService = myTutorsService;
            _professorsService = professorsService;
            _usersService = usersService;
            _postmarkService = postmarkService;
        }

        public Task<IEnumerable<Complaint>> GetComplaintsAllAsync() => _repo.GetComplaintsAllAsync();
        public Task<Complaint?> GetComplaintByIdAsync(Guid idComplaint) => _repo.GetComplaintByIdAsync(idComplaint);
        public Task<Guid> InsertComplaintAsync(Complaint complaint) => _repo.InsertComplaintAsync(complaint);
        public async Task<Complaint> CreateComplaintAgainstRelatedUserAsync(Guid senderUserId, CreateRelatedComplaintRequest request)
        {
            if (senderUserId == Guid.Empty)
            {
                throw new ArgumentException("Utilizador inválido.");
            }

            if (request == null)
            {
                throw new ArgumentException("Pedido inválido.");
            }

            if (!Guid.TryParse(request.TargetUserId?.Trim(), out var targetUserId) || targetUserId == Guid.Empty)
            {
                throw new ArgumentException("O utilizador alvo é inválido.");
            }

            if (targetUserId == senderUserId)
            {
                throw new ArgumentException("Não podes submeter uma reclamação sobre ti próprio.");
            }

            var complaintType = NormalizeRequired(request.ComplaintType, "tipo de reclamação", 100);
            var subject = NormalizeRequired(request.Subject, "assunto", 160);
            var message = NormalizeRequired(request.Message, "mensagem", 1000);
            var relationshipType = (request.RelationshipType ?? string.Empty).Trim().ToLowerInvariant();

            var senderUser = await _usersService.GetByIdAsync(senderUserId);
            if (senderUser == null)
            {
                throw new InvalidOperationException("Não foi possível identificar o utilizador autenticado.");
            }

            var senderDisplayName = BuildDisplayName(senderUser);
            var now = DateTime.UtcNow;

            Complaint complaint;
            switch (relationshipType)
            {
                case "student":
                {
                    var students = await _professorsService.GetAlunosByProfessorIdAsync(senderUserId);
                    var student = students.FirstOrDefault(item => item.Id == targetUserId);
                    if (student == null)
                    {
                        throw new InvalidOperationException("Só podes submeter reclamações sobre um dos teus alunos.");
                    }

                    complaint = new Complaint
                    {
                        SenderUserId = senderUserId,
                        ReceiverUserId = targetUserId,
                        ComplaintType = complaintType,
                        ComplaintSubject = subject,
                        ComplaintMessage = message,
                        Status = "pending",
                        IsRead = false,
                        SenderDisplayName = senderDisplayName,
                        ReceiverDisplayName = BuildDisplayName(student.FirstName, student.LastName, student.Name, student.Username),
                        SenderRole = "teacher",
                        ReceiverRole = "student",
                        RelationshipContext = "teacher_student",
                        CreatedAt = now,
                        UpdatedAt = now,
                    };
                    break;
                }
                case "professor":
                {
                    var tutors = await _myTutorsService.GetMyTutorsAsync(senderUserId);
                    var tutor = tutors.FirstOrDefault(item => item.TutorUserId == targetUserId);
                    if (tutor == null)
                    {
                        throw new InvalidOperationException("Só podes submeter reclamações sobre um dos teus professores.");
                    }

                    complaint = new Complaint
                    {
                        SenderUserId = senderUserId,
                        ReceiverUserId = targetUserId,
                        ComplaintType = complaintType,
                        ComplaintSubject = subject,
                        ComplaintMessage = message,
                        Status = "pending",
                        IsRead = false,
                        SenderDisplayName = senderDisplayName,
                        ReceiverDisplayName = string.IsNullOrWhiteSpace(tutor.TutorName)
                            ? (tutor.TutorUsername?.Trim() ?? "Professor")
                            : tutor.TutorName.Trim(),
                        SenderRole = "student",
                        ReceiverRole = "teacher",
                        RelationshipContext = "student_teacher",
                        CreatedAt = now,
                        UpdatedAt = now,
                    };
                    break;
                }
                default:
                    throw new ArgumentException("O tipo de relação indicado é inválido.");
            }

            var id = await _repo.InsertRelatedUserComplaintAsync(complaint);
            complaint.IdComplaint = id;
            return complaint;
        }
        public Task<int> UpdateComplaintAsync(Complaint complaint) => _repo.UpdateComplaintAsync(complaint);
        public async Task<bool> ReplyToComplaintAsync(Guid idComplaint, Guid? responderUserId, string? responseMessage, string? status)
        {
            var complaint = await _repo.GetComplaintByIdAsync(idComplaint);
            if (complaint == null)
            {
                return false;
            }

            var normalizedStatus = NormalizeReplyStatus(status, hasResponseMessage: !string.IsNullOrWhiteSpace(responseMessage));
            var trimmedResponse = responseMessage?.Trim();

            if (!string.IsNullOrWhiteSpace(trimmedResponse))
            {
                if (string.IsNullOrWhiteSpace(complaint.SenderEmail))
                {
                    throw new InvalidOperationException("A reclamação não tem email de remetente disponível.");
                }

                var subject = string.IsNullOrWhiteSpace(complaint.ComplaintSubject)
                    ? "Resposta à sua reclamação"
                    : $"Resposta à sua reclamação: {complaint.ComplaintSubject.Trim()}";
                var originalMessage = string.IsNullOrWhiteSpace(complaint.ComplaintMessage)
                    ? "Sem mensagem original disponível."
                    : complaint.ComplaintMessage.Trim();
                var plainBody =
                    $"Recebemos a sua reclamação na Aula Extra.\n\n" +
                    $"Assunto: {(complaint.ComplaintSubject?.Trim() ?? "Sem assunto")}\n\n" +
                    $"Resposta da equipa:\n{trimmedResponse}\n\n" +
                    $"Mensagem original:\n{originalMessage}";

                var dto = new EmailSenderDto
                {
                    To = complaint.SenderEmail,
                    Subject = subject,
                    TextBody = plainBody,
                    HtmlBody = EmailTemplates.Jacurvas(subject, plainBody),
                    Tag = "complaint-reply",
                    MessageStream = "outbound"
                };

                var sent = await _postmarkService.SendEmailAsync(dto);
                if (!sent)
                {
                    throw new InvalidOperationException("Não foi possível enviar a resposta por email.");
                }
            }

            complaint.Status = normalizedStatus;
            complaint.IsRead = normalizedStatus is "lida" or "respondida" or "resolved";
            complaint.UpdatedAt = DateTime.UtcNow;

            var rows = await _repo.UpdateComplaintAsync(complaint);
            return rows > 0;
        }
        public Task<int> DeleteComplaintAsync(Guid idComplaint) => _repo.DeleteComplaintAsync(idComplaint);

        public Task<IEnumerable<ComplaintResolution>> GetComplaintResolutionsAllAsync() => _repo.GetComplaintResolutionsAllAsync();
        public Task<ComplaintResolution?> GetComplaintResolutionByIdAsync(Guid idComplaintResolution) => _repo.GetComplaintResolutionByIdAsync(idComplaintResolution);
        public Task<Guid> InsertComplaintResolutionAsync(ComplaintResolution resolution) => _repo.InsertComplaintResolutionAsync(resolution);
        public Task<int> UpdateComplaintResolutionAsync(ComplaintResolution resolution) => _repo.UpdateComplaintResolutionAsync(resolution);
        public Task<int> DeleteComplaintResolutionAsync(Guid idComplaintResolution) => _repo.DeleteComplaintResolutionAsync(idComplaintResolution);

        private static string NormalizeRequired(string? value, string fieldName, int maxLength)
        {
            var normalized = (value ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(normalized))
            {
                throw new ArgumentException($"O campo {fieldName} é obrigatório.");
            }

            if (normalized.Length > maxLength)
            {
                throw new ArgumentException($"O campo {fieldName} excede o limite de {maxLength} caracteres.");
            }

            return normalized;
        }

        private static string BuildDisplayName(User user)
        {
            return BuildDisplayName(user.FirstName, user.LastName, user.DisplayName, user.Username);
        }

        private static string BuildDisplayName(string? firstName, string? lastName, string? displayName, string? username)
        {
            if (!string.IsNullOrWhiteSpace(displayName))
            {
                return displayName.Trim();
            }

            var fullName = string.Join(" ", new[] { firstName?.Trim(), lastName?.Trim() }
                .Where(value => !string.IsNullOrWhiteSpace(value))).Trim();

            if (!string.IsNullOrWhiteSpace(fullName))
            {
                return fullName;
            }

            return !string.IsNullOrWhiteSpace(username) ? username.Trim() : "Utilizador";
        }

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
                "resolved" => "resolved",
                _ => throw new ArgumentException("O estado indicado é inválido.")
            };
        }
    }
}
