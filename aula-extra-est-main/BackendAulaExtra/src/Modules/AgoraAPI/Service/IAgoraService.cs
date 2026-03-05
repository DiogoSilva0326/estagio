using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.AgoraAPI.Models;

namespace ConfidantPostgreSQL.Modules.AgoraAPI.Service
{
    public interface IAgoraService
    {
        Task<IEnumerable<VideoCall>> GetCallsAllAsync();
        Task<VideoCall?> GetCallByIdAsync(Guid id);
        Task<Guid> InsertCallAsync(VideoCall call);
        Task<int> UpdateCallAsync(VideoCall call);
        Task<int> DeleteCallAsync(Guid id);

        Task<IEnumerable<VideoCallParticipant>> GetParticipantsAllAsync();
        Task<VideoCallParticipant?> GetParticipantByIdAsync(Guid id);
        Task<Guid> InsertParticipantAsync(VideoCallParticipant participant);
        Task<int> UpdateParticipantAsync(VideoCallParticipant participant);
        Task<int> DeleteParticipantAsync(Guid id);
    }
}
