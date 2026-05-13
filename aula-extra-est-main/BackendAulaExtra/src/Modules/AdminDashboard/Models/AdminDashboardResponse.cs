using System;
using System.Collections.Generic;

namespace ConfidantPostgreSQL.Modules.AdminDashboard.Models
{
    public class AdminDashboardResponse
    {
        public AdminDashboardKpis Kpis { get; set; } = new AdminDashboardKpis();
        public List<AdminDashboardSessionItem> RecentSessions { get; set; } = new List<AdminDashboardSessionItem>();
        public List<AdminDashboardServiceItem> Services { get; set; } = new List<AdminDashboardServiceItem>();
        public List<AdminDashboardSubjectItem> PopularSubjects { get; set; } = new List<AdminDashboardSubjectItem>();
    }

    public class AdminSessionLogItem
    {
        public Guid ReservationId { get; set; }
        public Guid LessonId { get; set; }
        public Guid? VideoCallId { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string TutorName { get; set; } = string.Empty;
        public string SubjectName { get; set; } = string.Empty;
        public DateTime? StartsAt { get; set; }
        public DateTime? EndsAt { get; set; }
        public int DurationMinutes { get; set; }
        public string ReservationStatus { get; set; } = string.Empty;
        public string? ChannelName { get; set; }
        public string? VideoCallStatus { get; set; }
        public DateTimeOffset? CallStartedAt { get; set; }
        public DateTimeOffset? CallEndedAt { get; set; }
        public int? CallDurationSeconds { get; set; }
        public string? RecordingUrl { get; set; }
    }

    public class AdminEvaluationsResponse
    {
        public AdminEvaluationsSummary Summary { get; set; } = new AdminEvaluationsSummary();
        public List<AdminEvaluationItem> LessonEvaluations { get; set; } = new List<AdminEvaluationItem>();
        public List<AdminEvaluationItem> ProfessorEvaluations { get; set; } = new List<AdminEvaluationItem>();
    }

    public class AdminEvaluationsSummary
    {
        public double AverageRating { get; set; }
        public int TotalEvaluations { get; set; }
        public int PendingModeration { get; set; }
        public int LessonEvaluations { get; set; }
        public int ProfessorEvaluations { get; set; }
    }

    public class AdminEvaluationItem
    {
        public Guid EvaluationId { get; set; }
        public string Kind { get; set; } = string.Empty;
        public Guid? LessonId { get; set; }
        public Guid? ProfessorId { get; set; }
        public Guid StudentUserId { get; set; }
        public string StudentName { get; set; } = string.Empty;
        public string TargetName { get; set; } = string.Empty;
        public string? SubjectName { get; set; }
        public int? Rating { get; set; }
        public string? Comment { get; set; }
        public DateTime? CreatedAt { get; set; }
        public bool? IsValid { get; set; }
    }

    public class AdminDashboardKpis
    {
        public int ActiveProfessionals { get; set; }
        public int TotalStudents { get; set; }
        public int MonthlySessions { get; set; }
        public decimal MonthlyRevenue { get; set; }
        public int PendingApplications { get; set; }
        public int PendingPayments { get; set; }
    }

    public class AdminDashboardSessionItem
    {
        public string StudentName { get; set; } = string.Empty;
        public string TutorName { get; set; } = string.Empty;
        public string SubjectName { get; set; } = string.Empty;
        public DateTime? StartsAt { get; set; }
        public DateTime? EndsAt { get; set; }
        public int DurationMinutes { get; set; }
        public string Status { get; set; } = string.Empty;
    }

    public class AdminDashboardServiceItem
    {
        public string Label { get; set; } = string.Empty;
        public string Kind { get; set; } = string.Empty;
        public bool Online { get; set; }
        public int Count { get; set; }
    }

    public class AdminDashboardSubjectItem
    {
        public string Label { get; set; } = string.Empty;
        public int ProfessionalCount { get; set; }
    }
}