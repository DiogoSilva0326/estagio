using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Education.Models;
using ConfidantPostgreSQL.Modules.Professors.Models;
using ConfidantPostgreSQL.Modules.Professors.Repository;

namespace ConfidantPostgreSQL.Modules.Professors.Service
{
    public class ProfessorsService : IProfessorsService
    {
        private readonly IProfessorsRepository _repo;

        public ProfessorsService(IProfessorsRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Professor>> GetProfessorsAllAsync() => _repo.GetProfessorsAllAsync();
        public Task<TutorBrowseResponse> BrowseTutorsAsync(TutorBrowseQuery query) => _repo.BrowseTutorsAsync(query);
        public Task<Professor?> GetProfessorByIdAsync(Guid idProfessor) => _repo.GetProfessorByIdAsync(idProfessor);
        public Task<Professor?> GetProfessorByUserIdAsync(Guid idUser) => _repo.GetProfessorByUserIdAsync(idUser);
        public Task<Guid> InsertProfessorAsync(Professor professor) => _repo.InsertProfessorAsync(professor);
        public Task<int> UpdateProfessorAsync(Professor professor) => _repo.UpdateProfessorAsync(professor);
        public Task<int> DeleteProfessorAsync(Guid idProfessor) => _repo.DeleteProfessorAsync(idProfessor);

        public Task<IEnumerable<ProfessorFeedback>> GetProfessorFeedbackAllAsync() => _repo.GetProfessorFeedbackAllAsync();
        public Task<ProfessorFeedback?> GetProfessorFeedbackByIdAsync(Guid idProfessorFeedback) => _repo.GetProfessorFeedbackByIdAsync(idProfessorFeedback);
        public Task<Guid> InsertProfessorFeedbackAsync(ProfessorFeedback feedback) => _repo.InsertProfessorFeedbackAsync(feedback);
        public Task<int> UpdateProfessorFeedbackAsync(ProfessorFeedback feedback) => _repo.UpdateProfessorFeedbackAsync(feedback);
        public Task<int> DeleteProfessorFeedbackAsync(Guid idProfessorFeedback) => _repo.DeleteProfessorFeedbackAsync(idProfessorFeedback);

        public Task<IEnumerable<Certificate>> GetCertificatesAllAsync() => _repo.GetCertificatesAllAsync();
        public Task<Certificate?> GetCertificateByIdAsync(Guid idCertificate) => _repo.GetCertificateByIdAsync(idCertificate);
        public Task<IEnumerable<Certificate>> GetCertificatesByProfessorIdAsync(Guid idProfessor) => _repo.GetCertificatesByProfessorIdAsync(idProfessor);
        public Task<Guid> InsertCertificateAsync(Certificate cert) => _repo.InsertCertificateAsync(cert);
        public Task<int> UpdateCertificateAsync(Certificate cert) => _repo.UpdateCertificateAsync(cert);
        public Task<int> DeleteCertificateAsync(Guid idCertificate) => _repo.DeleteCertificateAsync(idCertificate);
        public Task<int> DeleteCertificatesByProfessorIdAsync(Guid idProfessor) => _repo.DeleteCertificatesByProfessorIdAsync(idProfessor);

        public Task<IEnumerable<ProfessorRoom>> GetProfessorRoomsAllAsync() => _repo.GetProfessorRoomsAllAsync();
        public Task<ProfessorRoom?> GetProfessorRoomByIdAsync(Guid id) => _repo.GetProfessorRoomByIdAsync(id);
        public Task<ProfessorRoom?> GetProfessorRoomByProfessorIdAsync(Guid professorId) => _repo.GetProfessorRoomByProfessorIdAsync(professorId);
        public Task<Guid> InsertProfessorRoomAsync(ProfessorRoom room) => _repo.InsertProfessorRoomAsync(room);
        public Task<int> UpdateProfessorRoomAsync(ProfessorRoom room) => _repo.UpdateProfessorRoomAsync(room);
        public Task<int> DeleteProfessorRoomAsync(Guid id) => _repo.DeleteProfessorRoomAsync(id);

        public Task<IEnumerable<ProfessorStudentDto>> GetAlunosByProfessorIdAsync(Guid professorUserId) => _repo.GetAlunosByProfessorIdAsync(professorUserId);

        public Task<IEnumerable<Disciplina>> GetDisciplinasByProfessorIdAsync(Guid idProfessor) =>
            _repo.GetDisciplinasByProfessorIdAsync(idProfessor);

        public Task<int> UpsertDisciplinaForProfessorAsync(Guid idProfessor, ProfessorDisciplinaUpsert input, Guid? currentIdDisciplina = null) =>
            _repo.UpsertDisciplinaForProfessorAsync(idProfessor, input, currentIdDisciplina);

        public Task<int> SetDisciplinasForProfessorAsync(Guid idProfessor, Guid[] ids) =>
            _repo.SetDisciplinasForProfessorAsync(idProfessor, ids);

        public Task<int> RemoveDisciplinaForProfessorAsync(Guid idProfessor, Guid idDisciplina) =>
            _repo.RemoveDisciplinaForProfessorAsync(idProfessor, idDisciplina);

        public Task<IEnumerable<ProfessorLanguage>> GetLanguagesCatalogAsync() =>
            _repo.GetLanguagesCatalogAsync();

        public Task<IEnumerable<ProfessorLanguage>> GetLanguagesByProfessorIdAsync(Guid idProfessor) =>
            _repo.GetLanguagesByProfessorIdAsync(idProfessor);

        public Task<int> SetLanguagesForProfessorAsync(Guid idProfessor, ProfessorLanguage[] items) =>
            _repo.SetLanguagesForProfessorAsync(idProfessor, items);

        public Task<int> RemoveLanguageForProfessorAsync(Guid idProfessor, Guid idLanguage) =>
            _repo.RemoveLanguageForProfessorAsync(idProfessor, idLanguage);

        public Task<ProfessorStats> GetProfessorStatsAsync(Guid idProfessor) =>
            _repo.GetProfessorStatsAsync(idProfessor);
    }
}
