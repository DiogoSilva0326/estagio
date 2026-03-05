using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Users.Service;
using Microsoft.AspNetCore.Mvc;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Users.Controller
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class UserRolesController : ControllerBase
    {
        private readonly string _connStr;
        private readonly IUserService _users;

        public UserRolesController(IUserService users)
        {
            _users = users;
            var host = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
            var port = Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";
            var user = Environment.GetEnvironmentVariable("DB_USER") ?? "sa";
            var pass = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "";
            var db = Environment.GetEnvironmentVariable("DB_NAME") ?? "ConfidantsDB";
            _connStr = $"Host={host};Port={port};Username={user};Password={pass};Database={db}";
        }

        private bool TryGetAuthenticatedUserId(out Guid userId)
        {
            userId = Guid.Empty;
            if (HttpContext?.Items == null) return false;
            if (!HttpContext.Items.TryGetValue("UserId", out var raw) || raw == null) return false;
            if (raw is Guid g)
            {
                userId = g;
                return userId != Guid.Empty;
            }

            return Guid.TryParse(raw.ToString(), out userId) && userId != Guid.Empty;
        }

        private async Task<bool> CurrentUserIsAdminAsync(Guid userId)
        {
            var auth = await _users.IssueTokenAsync(userId);
            if (auth?.Roles == null) return false;
            return auth.Roles.Any(r => string.Equals(r?.Trim(), "admin", StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// GET /api/UserRoles/{userId} - Get roles for a user
        /// </summary>
        [HttpGet("{userId:guid}")]
        public async Task<IActionResult> Get(Guid userId, [FromHeader] string? token = null, [FromHeader] string? culture = null)
        {
            try
            {
                RequestContext.ApplyCultureFromHeader(Request);

                if (!TryGetAuthenticatedUserId(out var actorUserId))
                    return Unauthorized();
                if (!await CurrentUserIsAdminAsync(actorUserId))
                    return Forbid();

                var roleIds = new List<int>();
                
                await using var conn = new NpgsqlConnection(_connStr);
                await conn.OpenAsync();
                
                await using var cmd = new NpgsqlCommand(
                    "SELECT role_id FROM user_role WHERE user_id = @userId", conn);
                cmd.Parameters.AddWithValue("userId", userId);
                
                await using var reader = await cmd.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    roleIds.Add(reader.GetInt32(0));
                }

                return Ok(new { userId, roleIds });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }

        public class SetUserRoleDto 
        { 
            public int RoleId { get; set; } 
        }

        /// <summary>
        /// PUT /api/UserRoles/{userId} - Set role for a user (replaces existing)
        /// </summary>
        [HttpPut("{userId:guid}")]
        public async Task<IActionResult> Set(Guid userId, [FromBody] SetUserRoleDto dto, [FromHeader] string? token = null, [FromHeader] string? culture = null)
        {
            try
            {
                RequestContext.ApplyCultureFromHeader(Request);

                if (!TryGetAuthenticatedUserId(out var actorUserId))
                    return Unauthorized();
                if (!await CurrentUserIsAdminAsync(actorUserId))
                    return Forbid();

                await using var conn = new NpgsqlConnection(_connStr);
                await conn.OpenAsync();

                // Delete existing roles for user
                await using (var delCmd = new NpgsqlCommand(
                    "DELETE FROM user_role WHERE user_id = @userId", conn))
                {
                    delCmd.Parameters.AddWithValue("userId", userId);
                    await delCmd.ExecuteNonQueryAsync();
                }

                // Insert new role
                await using (var insCmd = new NpgsqlCommand(
                    "INSERT INTO user_role (role_id, user_id) VALUES (@roleId, @userId)", conn))
                {
                    insCmd.Parameters.AddWithValue("roleId", dto.RoleId);
                    insCmd.Parameters.AddWithValue("userId", userId);
                    await insCmd.ExecuteNonQueryAsync();
                }

                return Ok(new { userId, roleId = dto.RoleId });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }
}
