using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Users.Models;

namespace ConfidantPostgreSQL.Modules.Users.Repository
{
    public interface IUserRepository
    {
        Task<Guid> InsertAsync(User user);
        Task<int> UpdateAsync(User user);
        Task<int> DeleteAsync(Guid id);
        Task<User?> GetByIdAsync(Guid id);
        Task<IEnumerable<User>> GetAllAsync();
        Task<User?> GetByEmailAsync(string email);
        Task UpdateRolesAsync(Guid userId, IEnumerable<int> roleIds);
        Task<IReadOnlyList<string>> GetRoleDescriptionsAsync(Guid userId);
        Task<bool> EnsureRoleAsync(Guid userId, string roleDescription);
    }
}
