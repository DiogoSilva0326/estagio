using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.UserProfile.Models;
using ConfidantPostgreSQL.Modules.UserProfile.Repository;

namespace ConfidantPostgreSQL.Modules.UserProfile.Service;

public interface IUserProfileService
{
    Task<Models.UserProfile?> GetByUserIdAsync(Guid userId);
    Task<Models.UserProfile?> GetByVerificationTokenAsync(string token);
    Task<Models.UserProfile?> GetByResetTokenAsync(string token);
    Task<List<Models.UserProfile>> GetAllAsync();
    Task<Models.UserProfile> GetOrCreateAsync(Guid userId);
    Task<Guid> InsertAsync(InsertUserProfileRequest request);
    Task<int> UpdateAsync(UpdateUserProfileRequest request);
}

public class UserProfileService : IUserProfileService
{
    private readonly IUserProfileRepository _repository;

    public UserProfileService(IUserProfileRepository repository)
    {
        _repository = repository;
    }

    public Task<Models.UserProfile?> GetByUserIdAsync(Guid userId)
    {
        return _repository.GetByUserIdAsync(userId);
    }

    public Task<Models.UserProfile?> GetByVerificationTokenAsync(string token)
    {
        return _repository.GetByVerificationTokenAsync(token);
    }

    public Task<Models.UserProfile?> GetByResetTokenAsync(string token)
    {
        return _repository.GetByResetTokenAsync(token);
    }

    public Task<List<Models.UserProfile>> GetAllAsync()
    {
        return _repository.GetAllAsync();
    }

    public async Task<Models.UserProfile> GetOrCreateAsync(Guid userId)
    {
        var profile = await _repository.GetByUserIdAsync(userId);
        
        if (profile == null)
        {
            // Auto-create profile if not exists
            var request = new InsertUserProfileRequest
            {
                UserId = userId,
                TotalSpent = 0,
                PreferedLanguage = "pt-PT",
                Status = "active"
            };
            
            await _repository.InsertAsync(request);
            profile = await _repository.GetByUserIdAsync(userId);
            
            if (profile == null)
            {
                throw new InvalidOperationException($"Failed to create UserProfile for userId={userId}");
            }
        }
        
        return profile;
    }

    public Task<Guid> InsertAsync(InsertUserProfileRequest request)
    {
        return _repository.InsertAsync(request);
    }

    public Task<int> UpdateAsync(UpdateUserProfileRequest request)
    {
        return _repository.UpdateAsync(request);
    }
}
