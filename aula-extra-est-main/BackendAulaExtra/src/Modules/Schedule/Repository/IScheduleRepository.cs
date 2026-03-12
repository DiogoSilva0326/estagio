using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Schedule.Models;

namespace ConfidantPostgreSQL.Modules.Schedule.Repository
{
    public interface IScheduleRepository
    {
        Task<IEnumerable<Day>> GetDaysAllAsync();
        Task<Day?> GetDayByIdAsync(Guid idDay);
        Task<Guid> InsertDayAsync(Day day);
        Task<int> UpdateDayAsync(Day day);
        Task<int> DeleteDayAsync(Guid idDay);

        Task<IEnumerable<ScheduleBlock>> GetScheduleBlocksAllAsync();
        Task<ScheduleBlock?> GetScheduleBlockByIdAsync(Guid idScheduleBlock);
        Task<Guid> InsertScheduleBlockAsync(ScheduleBlock block);
        Task<int> UpdateScheduleBlockAsync(ScheduleBlock block);
        Task<int> DeleteScheduleBlockAsync(Guid idScheduleBlock);

        Task<IEnumerable<BlockPart>> GetBlockPartsAllAsync();
        Task<BlockPart?> GetBlockPartByIdAsync(Guid idBlockPart);
        Task<Guid> InsertBlockPartAsync(BlockPart part);
        Task<int> UpdateBlockPartAsync(BlockPart part);
        Task<int> DeleteBlockPartAsync(Guid idBlockPart);
    }
}
