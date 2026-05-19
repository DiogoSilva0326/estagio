using System.Collections.Generic;
using System.Threading.Tasks;
using System;
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
        Task<IEnumerable<AdminStudentDirectoryItem>> GetAdminStudentDirectoryAsync();
        Task<User?> GetByEmailAsync(string email);
        Task<User?> GetByGoogleSubjectAsync(string googleSubject);
        Task<User?> GetByUsernameAsync(string username);
        Task<Guid> RegisterAsync(User user, string password);
        Task<AuthResult?> AuthenticateAsync(string email, string password);
        Task<AuthResult?> IssueTokenAsync(Guid userId);
        Task<bool> SetGoogleSubjectAsync(Guid userId, string googleSubject);
        Task<bool> EnsureRoleAsync(Guid userId, string roleDescription);
        Task<bool> RemoveRoleAsync(Guid userId, string roleDescription);
        Task UpdateRolesAsync(Guid userId, IEnumerable<int> roleIds);
        Task<bool> SetInactiveAsync(Guid userId, bool inactive, Guid? lastUserId = null);
        Task UpdatePasswordAsync(Guid userId, string newPassword);
        Task<IReadOnlyList<UserNotificationDto>> GetNotificationsByUserIdAsync(Guid userId);
        Task<bool> MarkNotificationAsReadAsync(Guid userId, Guid notificationId);
        Task<int> MarkAllNotificationsAsReadAsync(Guid userId);
        Task<int> MarkLessonRequestNotificationsAsReadAsync(Guid userId, Guid reservationId);
    }
}
