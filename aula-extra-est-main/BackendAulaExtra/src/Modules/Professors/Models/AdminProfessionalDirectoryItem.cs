using System;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class AdminProfessionalDirectoryItem
    {
        public Guid IdProfessor { get; set; }
        public string Category { get; set; } = "explicadores";
        public string Name { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string? Phone { get; set; }
        public string? PhotoUrl { get; set; }
        public string AreaName { get; set; } = "Sem área";
        public string PrimarySubject { get; set; } = string.Empty;
        public decimal? PricePerHour { get; set; }
        public decimal AverageRating { get; set; }
        public int ReviewCount { get; set; }
        public string StatusLabel { get; set; } = "INATIVO";
        public bool IsActive { get; set; }
        public bool IsVerified { get; set; }
        public bool IsRejected { get; set; }
        public string? CurrentSchool { get; set; }
        public string? Biography { get; set; }
        public int YearsExperience { get; set; }
    }
}