using System;
using System.Collections.Generic;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class TutorBrowseItem
    {
        public Guid IdProfessor { get; set; }
        public string Name { get; set; } = string.Empty;
        public string Subtitle { get; set; } = string.Empty;
        public string? Photo { get; set; }
        public string PrimarySubject { get; set; } = string.Empty;
        public int? YearsExperience { get; set; }
        public decimal Rating { get; set; }
        public int ReviewCount { get; set; }
        public string Description { get; set; } = string.Empty;
        public int LessonsCount { get; set; }
        public decimal MinPrice { get; set; }
        public List<string> Tags { get; set; } = new List<string>();
        public List<string> EducationLevels { get; set; } = new List<string>();
    }
}
