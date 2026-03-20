using System;
using System.Collections.Generic;

namespace ConfidantPostgreSQL.Modules.Professors.Models
{
    public class ProfessorStudentDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? FirstName { get; set; } 
        public string? LastName { get; set; }
        public string AvatarUrl { get; set; } = string.Empty;
        public List<string> Subjects { get; set; } = new List<string>();
        public string LastLessonDate { get; set; } = string.Empty;
        public double Progress { get; set; }
    }
}