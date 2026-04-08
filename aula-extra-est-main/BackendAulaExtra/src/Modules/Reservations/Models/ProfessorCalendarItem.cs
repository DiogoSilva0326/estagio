using System;

namespace ConfidantPostgreSQL.Modules.Reservations.Models
{
    public class ProfessorCalendarItem
    {
        public Guid IdReservation { get; set; }
        public Guid IdLesson { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string? Status { get; set; }
        public string? LessonTitle { get; set; }
        public string? StudentName { get; set; }
        public string? DisciplinaName { get; set; }
    }
}