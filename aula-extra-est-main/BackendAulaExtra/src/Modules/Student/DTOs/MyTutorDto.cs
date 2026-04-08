using System;

namespace ConfidantPostgreSQL.Modules.Student.DTOs
{
    public class MyTutorDto
    {
        public Guid ProfessorId { get; set; }
        public Guid TutorUserId { get; set; }
        public string? TutorUsername { get; set; }
        public string TutorName { get; set; } = "";
        public string? AvatarUrl { get; set; }
        public List<string> Subjects { get; set; } = new();
        public string? LastLessonSubject { get; set; }
        public DateTime? LastLessonStart { get; set; }
        public double? Rating { get; set; } // 0..5 average professor rating
        public int ReviewCount { get; set; }
        public double Progress { get; set; } // 0..1
    }
}
