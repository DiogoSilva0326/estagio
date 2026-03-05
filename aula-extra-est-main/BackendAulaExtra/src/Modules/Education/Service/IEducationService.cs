using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Education.Models;

namespace ConfidantPostgreSQL.Modules.Education.Service
{
    public interface IEducationService
    {
        Task<IEnumerable<Disciplina>> GetDisciplinasAllAsync();
        Task<Disciplina?> GetDisciplinaByIdAsync(Guid idDisciplina);
        Task<Guid> InsertDisciplinaAsync(Disciplina disciplina);
        Task<int> UpdateDisciplinaAsync(Disciplina disciplina);
        Task<int> DeleteDisciplinaAsync(Guid idDisciplina);

        Task<IEnumerable<Area>> GetAreasAllAsync();
        Task<Area?> GetAreaByIdAsync(Guid idArea);
        Task<Guid> InsertAreaAsync(Area area);
        Task<int> UpdateAreaAsync(Area area);
        Task<int> DeleteAreaAsync(Guid idArea);

        Task<IEnumerable<Disciplina>> GetDisciplinasByAreaIdAsync(Guid idArea);

        Task<IEnumerable<Disciplina>> GetMyDisciplinasAsync(Guid userId);
        Task<int> SetMyDisciplinasAsync(Guid userId, Guid[] ids);
        Task<int> RemoveMyDisciplinaAsync(Guid userId, Guid idDisciplina);
        Task<int> RemoveMyDisciplinasByAreaAsync(Guid userId, Guid idArea);

        Task<IEnumerable<AnoEscolaridade>> GetAnosEscolaridadeAllAsync();
        Task<AnoEscolaridade?> GetAnoEscolaridadeByIdAsync(Guid idAnoEscolaridade);
        Task<Guid> InsertAnoEscolaridadeAsync(AnoEscolaridade ano);
        Task<int> UpdateAnoEscolaridadeAsync(AnoEscolaridade ano);
        Task<int> DeleteAnoEscolaridadeAsync(Guid idAnoEscolaridade);

        Task<IEnumerable<CicloEstudo>> GetCiclosEstudoAllAsync();
        Task<CicloEstudo?> GetCicloEstudoByIdAsync(Guid idCicloEstudo);
        Task<Guid> InsertCicloEstudoAsync(CicloEstudo ciclo);
        Task<int> UpdateCicloEstudoAsync(CicloEstudo ciclo);
        Task<int> DeleteCicloEstudoAsync(Guid idCicloEstudo);

        Task<IEnumerable<CicloEstudoAno>> GetCiclosEstudoAnosAllAsync();
        Task<CicloEstudoAno?> GetCicloEstudoAnoByIdAsync(Guid id);
        Task<Guid> InsertCicloEstudoAnoAsync(CicloEstudoAno rel);
        Task<int> UpdateCicloEstudoAnoAsync(CicloEstudoAno rel);
        Task<int> DeleteCicloEstudoAnoAsync(Guid id);
    }
}
