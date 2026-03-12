using System;
using ConfidantPostgreSQL.Modules.Users.Models;

namespace ConfidantPostgreSQL.Modules.Users.DTOs
{
    public class RegisterModel
    {
        public string? Email { get; set; }
        public string? Password { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? BirthDate { get; set; }
        public string? StoreId { get; set; }
        public string? Nif { get; set; }
        public string? MobileNumber { get; set; }
        public string? PhoneNumber { get; set; }
        public string? CompanyName { get; set; }
        public string? Website { get; set; }
    }

    public class LoginModel
    {
        public string? Email { get; set; }
        public string? Password { get; set; }
    }

    public class AuthResult
    {
        public string? Token { get; set; }
        public User? User { get; set; }
        public IReadOnlyList<string>? Roles { get; set; }
    }
}
