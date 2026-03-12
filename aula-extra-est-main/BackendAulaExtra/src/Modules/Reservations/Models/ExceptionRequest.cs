using System;

namespace ConfidantPostgreSQL.Modules.Reservations.Models
{
    public class ExceptionRequest
    {
        public Guid IdExceptionRequest { get; set; }
        public Guid? IdUser { get; set; }
        public Guid? IdReservation { get; set; }
        public Guid? IdProfessor { get; set; }
        public string? RequestType { get; set; }
        public Guid? IdExceptionRule { get; set; }
        public int? RequestedDurationMinutes { get; set; }
        public DateTime? RequestedStart { get; set; }
        public DateTime? RequestedEnd { get; set; }
        public string? Status { get; set; }
        public string? Reason { get; set; }
        public DateTime? CreatedAt { get; set; }
    }
}
