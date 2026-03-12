using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Schedule.Models;
using ConfidantPostgreSQL.Modules.Schedule.Repository;

namespace ConfidantPostgreSQL.Modules.Schedule.Service
{
    public class ScheduleService : IScheduleService
    {
        private readonly IScheduleRepository _repo;

        public ScheduleService(IScheduleRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Day>> GetDaysAllAsync() => _repo.GetDaysAllAsync();
        public Task<Day?> GetDayByIdAsync(Guid idDay) => _repo.GetDayByIdAsync(idDay);
        public Task<Guid> InsertDayAsync(Day day) => _repo.InsertDayAsync(day);
        public Task<int> UpdateDayAsync(Day day) => _repo.UpdateDayAsync(day);
        public Task<int> DeleteDayAsync(Guid idDay) => _repo.DeleteDayAsync(idDay);

        public Task<IEnumerable<ScheduleBlock>> GetScheduleBlocksAllAsync() => _repo.GetScheduleBlocksAllAsync();
        public Task<ScheduleBlock?> GetScheduleBlockByIdAsync(Guid idScheduleBlock) => _repo.GetScheduleBlockByIdAsync(idScheduleBlock);
        public Task<Guid> InsertScheduleBlockAsync(ScheduleBlock block) => _repo.InsertScheduleBlockAsync(block);
        public Task<int> UpdateScheduleBlockAsync(ScheduleBlock block) => _repo.UpdateScheduleBlockAsync(block);
        public Task<int> DeleteScheduleBlockAsync(Guid idScheduleBlock) => _repo.DeleteScheduleBlockAsync(idScheduleBlock);

        public Task<IEnumerable<BlockPart>> GetBlockPartsAllAsync() => _repo.GetBlockPartsAllAsync();
        public Task<BlockPart?> GetBlockPartByIdAsync(Guid idBlockPart) => _repo.GetBlockPartByIdAsync(idBlockPart);
        public Task<Guid> InsertBlockPartAsync(BlockPart part) => _repo.InsertBlockPartAsync(part);
        public Task<int> UpdateBlockPartAsync(BlockPart part) => _repo.UpdateBlockPartAsync(part);
        public Task<int> DeleteBlockPartAsync(Guid idBlockPart) => _repo.DeleteBlockPartAsync(idBlockPart);
    }
}
