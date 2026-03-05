using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Users.Models;
using ConfidantPostgreSQL.Modules.Users.DTOs;
using ConfidantPostgreSQL.Modules.Users.Repository;
using ConfidantPostgreSQL.Modules.Users.Auth;
using Microsoft.IdentityModel.Tokens;

namespace ConfidantPostgreSQL.Modules.Users.Service
{
    public class UserService : IUserService
    {
        private readonly IUserRepository _repo;

        private readonly string _jwtSecret;
        private readonly int _jwtExpiryMinutes;

        public UserService(IUserRepository repo)
        {
            _repo = repo;
            _jwtSecret = Environment.GetEnvironmentVariable("JWT_SECRET") ?? "replace_this_dev_secret";
            _jwtExpiryMinutes = int.TryParse(Environment.GetEnvironmentVariable("JWT_EXP_MIN"), out var m) ? m : 60;
        }

        public Task<Guid> InsertAsync(User user) => _repo.InsertAsync(user);
        public Task<int> UpdateAsync(User user) => _repo.UpdateAsync(user);
        public Task<int> DeleteAsync(Guid id) => _repo.DeleteAsync(id);
        public Task<User?> GetByIdAsync(Guid id) => _repo.GetByIdAsync(id);
        public Task<IEnumerable<User>> GetAllAsync() => _repo.GetAllAsync();
        public Task<User?> GetByEmailAsync(string email) => _repo.GetByEmailAsync(email);
        public Task UpdateRolesAsync(Guid userId, IEnumerable<int> roleIds) => _repo.UpdateRolesAsync(userId, roleIds);

        public async Task<bool> SetInactiveAsync(Guid userId, bool inactive, Guid? lastUserId = null)
        {
            var user = await _repo.GetByIdAsync(userId);
            if (user == null) return false;

            user.Inactive = inactive;
            user.LastUserId = lastUserId;

            var res = await _repo.UpdateAsync(user);
            return res > 0;
        }

        public async Task<Guid> RegisterAsync(User user, string password)
        {
            if (string.IsNullOrEmpty(password)) throw new ArgumentException("Password required", nameof(password));
            var hash = PasswordHasher.Hash(password);
            user.Password = hash;
            return await _repo.InsertAsync(user);
        }

        public async Task<AuthResult?> AuthenticateAsync(string email, string password)
        {
            var user = await _repo.GetByEmailAsync(email);
            if (user == null) return null;
            if (string.IsNullOrEmpty(user.Password) || !PasswordHasher.Verify(password, user.Password)) return null;

            var userId = user.Id ?? Guid.Empty;
            var roles = userId == Guid.Empty
                ? Array.Empty<string>()
                : (await _repo.GetRoleDescriptionsAsync(userId)).ToArray();

            var token = GenerateJwt(user, roles);
            return new AuthResult { Token = token, User = user, Roles = roles };
        }

        public async Task<AuthResult?> IssueTokenAsync(Guid userId)
        {
            if (userId == Guid.Empty) return null;

            var user = await _repo.GetByIdAsync(userId);
            if (user == null) return null;

            var roles = (await _repo.GetRoleDescriptionsAsync(userId)).ToArray();
            var token = GenerateJwt(user, roles);

            return new AuthResult { Token = token, User = user, Roles = roles };
        }

        public Task<bool> EnsureRoleAsync(Guid userId, string roleDescription)
            => _repo.EnsureRoleAsync(userId, roleDescription);

        public async Task UpdatePasswordAsync(Guid userId, string newPassword)
        {
            if (string.IsNullOrEmpty(newPassword)) throw new ArgumentException("Password required", nameof(newPassword));
            var user = await _repo.GetByIdAsync(userId);
            if (user == null) throw new KeyNotFoundException($"User with ID {userId} not found");
            
            var hash = PasswordHasher.Hash(newPassword);
            user.Password = hash;
            await _repo.UpdateAsync(user);
        }

        private string GenerateJwt(User user, IReadOnlyList<string> roles)
        {
            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtSecret));
            var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new List<Claim>
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Id?.ToString() ?? ""),
                new Claim(JwtRegisteredClaimNames.Email, user.Email ?? "")
            };

            if (roles != null && roles.Count > 0)
            {
                claims.Add(new Claim("roles", string.Join(",", roles)));
                foreach (var r in roles)
                {
                    if (!string.IsNullOrWhiteSpace(r))
                        claims.Add(new Claim(ClaimTypes.Role, r));
                }
            }

            var token = new JwtSecurityToken(
                claims: claims,
                expires: DateTime.UtcNow.AddMinutes(_jwtExpiryMinutes),
                signingCredentials: creds
            );

            return new JwtSecurityTokenHandler().WriteToken(token);
        }
    }
}
