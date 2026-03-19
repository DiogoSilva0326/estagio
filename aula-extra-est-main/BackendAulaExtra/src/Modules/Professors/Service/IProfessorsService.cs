using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Professors.Models;

namespace ConfidantPostgreSQL.Modules.Professors.Service
{
    public interface IProfessorsService
    {
        Task<IEnumerable<Professor>> GetProfessorsAllAsync();
        Task<Professor?> GetProfessorByIdAsync(Guid idProfessor);
        Task<Professor?> GetProfessorByUserIdAsync(Guid idUser);
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
        Task<Guid> InsertCertificateAsync(Certificate cert);
        Task<int> UpdateCertificateAsync(Certificate cert);
        Task<int> DeleteCertificateAsync(Guid idCertificate);
        Task<int> DeleteCertificatesByProfessorIdAsync(Guid idProfessor);

        Task<IEnumerable<ProfessorRoom>> GetProfessorRoomsAllAsync();
        Task<ProfessorRoom?> GetProfessorRoomByIdAsync(Guid id);
        Task<Guid> InsertProfessorRoomAsync(ProfessorRoom room);
        Task<int> UpdateProfessorRoomAsync(ProfessorRoom room);
        Task<int> DeleteProfessorRoomAsync(Guid id);

        Task<IEnumerable<ProfessorStudentDto>> GetAlunosByProfessorIdAsync(Guid professorUserId);
    }
}