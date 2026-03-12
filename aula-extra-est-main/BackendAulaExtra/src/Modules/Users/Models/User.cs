using System;
using System.Collections.Generic;
using System.Text.Json.Serialization;

namespace ConfidantPostgreSQL.Modules.Users.Models
{
    public class User
    {
        public Guid? Id { get; set; }
        public string? Email { get; set; }
        [JsonIgnore]
        public string? Password { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? EducationLevel { get; set; }
        public string? Biography { get; set; }
        public string? BirthDate { get; set; }
        public string? AuthMessage { get; set; }
        public string? Username { get; set; }
        public string? DisplayName { get; set; }
        public string? CompanyName { get; set; }
        public string? MobileNumber { get; set; }
        public string? PhoneNumber { get; set; }
        public string? Nif { get; set; }
        public string? Website { get; set; }
        public string? MoloniCustomerId { get; set; }
        public string? NacexCustomerId { get; set; }
        public string? StripeCustomerId { get; set; }
        public Guid? StoreId { get; set; }
        public bool? Inactive { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? LastUpdate { get; set; }
        public Guid? LastUserId { get; set; }
    }

    // DTOs moved to DTOs folder
}
