using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.AgoraAPI.Models;
using ConfidantPostgreSQL.Modules.AgoraAPI.Repository;

namespace ConfidantPostgreSQL.Modules.AgoraAPI.Service
{
    public class AgoraService : IAgoraService
    {
        private readonly IAgoraRepository _repo;

        public AgoraService(IAgoraRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<VideoCall>> GetCallsAllAsync() => _repo.GetCallsAllAsync();
        public Task<VideoCall?> GetCallByIdAsync(Guid id) => _repo.GetCallByIdAsync(id);
        public Task<Guid> InsertCallAsync(VideoCall call) => _repo.InsertCallAsync(call);
        public Task<int> UpdateCallAsync(VideoCall call) => _repo.UpdateCallAsync(call);
        public Task<int> DeleteCallAsync(Guid id) => _repo.DeleteCallAsync(id);

        public Task<IEnumerable<VideoCallParticipant>> GetParticipantsAllAsync() => _repo.GetParticipantsAllAsync();
        public Task<VideoCallParticipant?> GetParticipantByIdAsync(Guid id) => _repo.GetParticipantByIdAsync(id);
        public Task<Guid> InsertParticipantAsync(VideoCallParticipant participant) => _repo.InsertParticipantAsync(participant);
        public Task<int> UpdateParticipantAsync(VideoCallParticipant participant) => _repo.UpdateParticipantAsync(participant);
        public Task<int> DeleteParticipantAsync(Guid id) => _repo.DeleteParticipantAsync(id);
    }
}
