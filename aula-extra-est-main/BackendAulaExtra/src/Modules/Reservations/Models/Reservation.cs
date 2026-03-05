using System;

namespace ConfidantPostgreSQL.Modules.Reservations.Models
{
    public class Reservation
    {
        public Guid IdReservation { get; set; }
        public Guid IdUser { get; set; }
        public Guid IdLesson { get; set; }
        public Guid? IdLessonScheduleBlock { get; set; }
        public Guid? IdScheduleBlock { get; set; }
        public Guid? IdBlockPart { get; set; }
        public int? MinStudentsAtBooking { get; set; }
        public DateTime? StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public string? Status { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
