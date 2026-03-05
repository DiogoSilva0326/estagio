using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Users.Models;
using ConfidantPostgreSQL.Modules.Users.DTOs;

namespace ConfidantPostgreSQL.Modules.Users.Service
{
    public interface IUserService
    {
        Task<Guid> InsertAsync(User user);
        Task<int> UpdateAsync(User user);
        Task<int> DeleteAsync(Guid id);
        Task<User?> GetByIdAsync(Guid id);
        Task<IEnumerable<User>> GetAllAsync();
        Task<User?> GetByEmailAsync(string email);
        Task<Guid> RegisterAsync(User user, string password);
        Task<AuthResult?> AuthenticateAsync(string email, string password);
        Task<AuthResult?> IssueTokenAsync(Guid userId);
        Task<bool> EnsureRoleAsync(Guid userId, string roleDescription);
        Task UpdateRolesAsync(Guid userId, IEnumerable<int> roleIds);
        Task<bool> SetInactiveAsync(Guid userId, bool inactive, Guid? lastUserId = null);
        Task UpdatePasswordAsync(Guid userId, string newPassword);
    }
}
