using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Education.Models;
using ConfidantPostgreSQL.Modules.Professors.Models;

namespace ConfidantPostgreSQL.Modules.Professors.Service
{
    public interface IProfessorsService
    {
        Task<IEnumerable<Professor>> GetProfessorsAllAsync();
        Task<IEnumerable<AdminProfessionalDirectoryItem>> GetAdminProfessionalDirectoryAsync(string? category);
        Task<TutorBrowseResponse> BrowseTutorsAsync(TutorBrowseQuery query);
        Task<Professor?> GetProfessorByIdAsync(Guid idProfessor);
        Task<Professor?> GetProfessorByUserIdAsync(Guid idUser);
        Task SyncSupportRequestsAsync(Guid idProfessor, IEnumerable<string> supportTypes);
        Task<IReadOnlyList<string>> GetSupportRequestsAsync(Guid idProfessor);
        Task ApproveSupportRequestAsync(Guid idProfessor, string supportType, Guid? approvedByUserId);
        Task RemoveSupportRequestAsync(Guid idProfessor, string supportType);
        Task ClearSupportRequestsAsync(Guid idProfessor);
        Task<Guid> InsertProfessorAsync(Professor professor);
        Task<int> UpdateProfessorAsync(Professor professor);
        Task<int> DeleteProfessorAsync(Guid idProfessor);

        Task<IEnumerable<ProfessorFeedback>> GetProfessorFeedbackAllAsync();
        Task<ProfessorFeedback?> GetProfessorFeedbackByIdAsync(Guid idProfessorFeedback);
        Task<Guid> InsertProfessorFeedbackAsync(ProfessorFeedback feedback);
        Task<int> UpdateProfessorFeedbackAsync(ProfessorFeedback feedback);
        Task<int> DeleteProfessorFeedbackAsync(Guid idProfessorFeedback);

        Task<IEnumerable<Certificate>> GetCertificatesAllAsync();
        Task<Certificate?> GetCertificateByIdAsync(Guid idCertificate);
        Task<IEnumerable<Certificate>> GetCertificatesByProfessorIdAsync(Guid idProfessor);
        Task<Guid> InsertCertificateAsync(Certificate cert);
        Task<int> UpdateCertificateAsync(Certificate cert);
        Task<int> DeleteCertificateAsync(Guid idCertificate);
        Task<int> DeleteCertificatesByProfessorIdAsync(Guid idProfessor);

        Task<IEnumerable<ProfessorRoom>> GetProfessorRoomsAllAsync();
        Task<ProfessorRoom?> GetProfessorRoomByIdAsync(Guid id);
        Task<ProfessorRoom?> GetProfessorRoomByProfessorIdAsync(Guid professorId);
        Task<Guid> InsertProfessorRoomAsync(ProfessorRoom room);
        Task<int> UpdateProfessorRoomAsync(ProfessorRoom room);
        Task<int> DeleteProfessorRoomAsync(Guid id);

        Task<IEnumerable<ProfessorStudentDto>> GetAlunosByProfessorIdAsync(Guid professorUserId, string? role = null);

        Task<IEnumerable<Disciplina>> GetDisciplinasByProfessorIdAsync(Guid idProfessor);
        Task<int> UpsertDisciplinaForProfessorAsync(Guid idProfessor, ProfessorDisciplinaUpsert input, Guid? currentIdDisciplina = null);
        Task<int> SetDisciplinasForProfessorAsync(Guid idProfessor, Guid[] ids);
        Task<int> RemoveDisciplinaForProfessorAsync(Guid idProfessor, Guid idDisciplina);

        Task<IEnumerable<ProfessorLanguage>> GetLanguagesCatalogAsync();
        Task<IEnumerable<ProfessorLanguage>> GetLanguagesByProfessorIdAsync(Guid idProfessor);
        Task<int> SetLanguagesForProfessorAsync(Guid idProfessor, ProfessorLanguage[] items);
        Task<int> RemoveLanguageForProfessorAsync(Guid idProfessor, Guid idLanguage);

        Task<ProfessorStats> GetProfessorStatsAsync(Guid idProfessor);
        Task<ProfessorGlobalRatingSummary> GetGlobalRatingSummaryAsync();
    }
}
