using System.Collections.Generic;
using System.Threading.Tasks;
using System;
using ConfidantPostgreSQL.Modules.Users.Models;
using ConfidantPostgreSQL.Modules.Users.DTOs;

namespace ConfidantPostgreSQL.Modules.Users.Repository
{
    public interface IUserRepository
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
        Task<bool> SetGoogleSubjectAsync(Guid userId, string googleSubject);
        Task UpdateRolesAsync(Guid userId, IEnumerable<int> roleIds);
        Task<IReadOnlyList<string>> GetRoleDescriptionsAsync(Guid userId);
        Task<bool> EnsureRoleAsync(Guid userId, string roleDescription);
        Task<bool> RemoveRoleAsync(Guid userId, string roleDescription);
        Task<IReadOnlyList<UserNotificationDto>> GetNotificationsByUserIdAsync(Guid userId);
        Task<bool> MarkNotificationAsReadAsync(Guid userId, Guid notificationId);
        Task<int> MarkAllNotificationsAsReadAsync(Guid userId);
        Task<int> MarkLessonRequestNotificationsAsReadAsync(Guid userId, Guid reservationId);
    }
}
