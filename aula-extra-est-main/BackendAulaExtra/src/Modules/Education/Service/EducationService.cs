using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Education.Models;
using ConfidantPostgreSQL.Modules.Education.Repository;

namespace ConfidantPostgreSQL.Modules.Education.Service
{
    public class EducationService : IEducationService
    {
        private readonly IEducationRepository _repo;

        public EducationService(IEducationRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Disciplina>> GetDisciplinasAllAsync() => _repo.GetDisciplinasAllAsync();
        public Task<Disciplina?> GetDisciplinaByIdAsync(Guid idDisciplina) => _repo.GetDisciplinaByIdAsync(idDisciplina);
        public Task<Guid> InsertDisciplinaAsync(Disciplina disciplina) => _repo.InsertDisciplinaAsync(disciplina);
        public Task<int> UpdateDisciplinaAsync(Disciplina disciplina) => _repo.UpdateDisciplinaAsync(disciplina);
        public Task<int> DeleteDisciplinaAsync(Guid idDisciplina) => _repo.DeleteDisciplinaAsync(idDisciplina);

        public Task<IEnumerable<Area>> GetAreasAllAsync() => _repo.GetAreasAllAsync();
        public Task<Area?> GetAreaByIdAsync(Guid idArea) => _repo.GetAreaByIdAsync(idArea);
        public Task<Guid> InsertAreaAsync(Area area) => _repo.InsertAreaAsync(area);
        public Task<int> UpdateAreaAsync(Area area) => _repo.UpdateAreaAsync(area);
        public Task<int> DeleteAreaAsync(Guid idArea) => _repo.DeleteAreaAsync(idArea);

        public Task<IEnumerable<Disciplina>> GetDisciplinasByAreaIdAsync(Guid idArea) => _repo.GetDisciplinasByAreaIdAsync(idArea);

        public Task<IEnumerable<Disciplina>> GetMyDisciplinasAsync(Guid userId) => _repo.GetDisciplinasByUserIdAsync(userId);
        public Task<int> SetMyDisciplinasAsync(Guid userId, Guid[] ids) => _repo.SetDisciplinasForUserAsync(userId, ids);
        public Task<int> RemoveMyDisciplinaAsync(Guid userId, Guid idDisciplina) => _repo.RemoveDisciplinaForUserAsync(userId, idDisciplina);
        public Task<int> RemoveMyDisciplinasByAreaAsync(Guid userId, Guid idArea) => _repo.RemoveDisciplinasForUserByAreaAsync(userId, idArea);

        public Task<IEnumerable<AnoEscolaridade>> GetAnosEscolaridadeAllAsync() => _repo.GetAnosEscolaridadeAllAsync();
        public Task<AnoEscolaridade?> GetAnoEscolaridadeByIdAsync(Guid idAnoEscolaridade) => _repo.GetAnoEscolaridadeByIdAsync(idAnoEscolaridade);
        public Task<Guid> InsertAnoEscolaridadeAsync(AnoEscolaridade ano) => _repo.InsertAnoEscolaridadeAsync(ano);
        public Task<int> UpdateAnoEscolaridadeAsync(AnoEscolaridade ano) => _repo.UpdateAnoEscolaridadeAsync(ano);
        public Task<int> DeleteAnoEscolaridadeAsync(Guid idAnoEscolaridade) => _repo.DeleteAnoEscolaridadeAsync(idAnoEscolaridade);

        public Task<IEnumerable<CicloEstudo>> GetCiclosEstudoAllAsync() => _repo.GetCiclosEstudoAllAsync();
        public Task<CicloEstudo?> GetCicloEstudoByIdAsync(Guid idCicloEstudo) => _repo.GetCicloEstudoByIdAsync(idCicloEstudo);
        public Task<Guid> InsertCicloEstudoAsync(CicloEstudo ciclo) => _repo.InsertCicloEstudoAsync(ciclo);
        public Task<int> UpdateCicloEstudoAsync(CicloEstudo ciclo) => _repo.UpdateCicloEstudoAsync(ciclo);
        public Task<int> DeleteCicloEstudoAsync(Guid idCicloEstudo) => _repo.DeleteCicloEstudoAsync(idCicloEstudo);

        public Task<IEnumerable<CicloEstudoAno>> GetCiclosEstudoAnosAllAsync() => _repo.GetCiclosEstudoAnosAllAsync();
        public Task<CicloEstudoAno?> GetCicloEstudoAnoByIdAsync(Guid id) => _repo.GetCicloEstudoAnoByIdAsync(id);
        public Task<Guid> InsertCicloEstudoAnoAsync(CicloEstudoAno rel) => _repo.InsertCicloEstudoAnoAsync(rel);
        public Task<int> UpdateCicloEstudoAnoAsync(CicloEstudoAno rel) => _repo.UpdateCicloEstudoAnoAsync(rel);
        public Task<int> DeleteCicloEstudoAnoAsync(Guid id) => _repo.DeleteCicloEstudoAnoAsync(id);
    }
}
