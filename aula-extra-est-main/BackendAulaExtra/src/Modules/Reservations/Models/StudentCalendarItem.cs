using System;

namespace ConfidantPostgreSQL.Modules.Reservations.Models
{
    public class StudentCalendarItem
    {
        public Guid IdReservation { get; set; }
        public Guid IdLesson { get; set; }
        public Guid? ProfessorUserId { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string? Status { get; set; }
        public string? LessonTitle { get; set; }
        public string? ProfessorName { get; set; }
        public string? DisciplinaName { get; set; }
    }
}
