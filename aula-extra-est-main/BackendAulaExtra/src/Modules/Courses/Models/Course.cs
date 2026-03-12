using System;

namespace ConfidantPostgreSQL.Modules.Courses.Models
{
    public class Course
    {
        public Guid IdCourse { get; set; }
        public Guid? IdProfessor { get; set; }
        public Guid? IdPricingModel { get; set; }
        public Guid? IdTutoringType { get; set; }
        public Guid? IdDisciplina { get; set; }
        public Guid? IdAnoEscolaridade { get; set; }
        public Guid? IdCicloEstudo { get; set; }
        public string Name { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? LevelOfEducation { get; set; }
        public int? NumMaxStudents { get; set; }
        public int? NumMinStudents { get; set; }
        public DateTime? CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }
}
