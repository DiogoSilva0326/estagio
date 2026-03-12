using System;

namespace ConfidantPostgreSQL.Modules.Student.DTOs
{
    public class MyTutorDto
    {
        public Guid ProfessorId { get; set; }
        public Guid TutorUserId { get; set; }
        public string TutorName { get; set; } = "";
        public string? LastLessonSubject { get; set; }
        public DateTime? LastLessonStart { get; set; }
        public double? Rating { get; set; } // 0..5 (null when not rated)
        public double Progress { get; set; } // 0..1
    }
}
