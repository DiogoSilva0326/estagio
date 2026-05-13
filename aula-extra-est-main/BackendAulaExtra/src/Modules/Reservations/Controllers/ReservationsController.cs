using System;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Integrations.AgoraLessons;
using ConfidantPostgreSQL.Modules.Communication.Models;
using ConfidantPostgreSQL.Modules.Communication.Service;
using ConfidantPostgreSQL.Modules.Reservations.Models;
using ConfidantPostgreSQL.Modules.Reservations.Service;
using ConfidantPostgreSQL.Modules.Lessons.Service;
using ConfidantPostgreSQL.Modules.Payments.Service;
using ConfidantPostgreSQL.Modules.Professors.Models;
using ConfidantPostgreSQL.Modules.Professors.Service;
using ConfidantPostgreSQL.Modules.Users.Service;
using Microsoft.Extensions.Logging;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Reservations.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class ReservationsController : ControllerBase
    {
        private static readonly TimeZoneInfo LessonTimeZone = ResolveLessonTimeZone();

        private readonly IReservationsService _service;
        private readonly ILessonsService _lessons;
        private readonly IPaymentsService _payments;
        private readonly IProfessorsService _professors;
        private readonly ICommunicationService _communication;
        private readonly IUserService _users;
        private readonly IAgoraLessonIntegratorClient _agoraLessons;
        private readonly ILogger<ReservationsController> _logger;

        public ReservationsController(
            IReservationsService service,
            ILessonsService lessons,
            IPaymentsService payments,
            IProfessorsService professors,
            ICommunicationService communication,
            IUserService users,
            IAgoraLessonIntegratorClient agoraLessons,
            ILogger<ReservationsController> logger)
        {
            _service = service;
            _lessons = lessons;
            _payments = payments;
            _professors = professors;
            _communication = communication;
            _users = users;
            _agoraLessons = agoraLessons;
            _logger = logger;
        }

        private static string BuildDisplayName(string? displayName, string? firstName, string? lastName, string fallback)
        {
            if (!string.IsNullOrWhiteSpace(displayName)) return displayName.Trim();

            var fullName = string.Join(" ", new[] { firstName?.Trim(), lastName?.Trim() }
                .Where(value => !string.IsNullOrWhiteSpace(value))).Trim();

            return !string.IsNullOrWhiteSpace(fullName) ? fullName : fallback;
        }

        private static string NormalizeUsername(string? value)
        {
            if (string.IsNullOrWhiteSpace(value)) return string.Empty;
            return value.Trim().ToLowerInvariant();
        }

        private static string ExpectedProfessorRoomName(string username)
        {
            return $"professor_{NormalizeUsername(username)}";
        }

        private static TimeZoneInfo ResolveLessonTimeZone()
        {
            var candidates = new[] { "Europe/Lisbon", "GMT Standard Time" };
            foreach (var candidate in candidates)
            {
                try
                {
                    return TimeZoneInfo.FindSystemTimeZoneById(candidate);
                }
                catch (TimeZoneNotFoundException)
                {
                }
                catch (InvalidTimeZoneException)
                {
                }
            }

            return TimeZoneInfo.Local;
        }

        private static DateTime NormalizeEntryWindowDateTime(DateTime value)
        {
            if (value.Kind == DateTimeKind.Utc)
            {
                return TimeZoneInfo.ConvertTimeFromUtc(value, LessonTimeZone);
            }

            if (value.Kind == DateTimeKind.Local)
            {
                return TimeZoneInfo.ConvertTime(value, LessonTimeZone);
            }

            return DateTime.SpecifyKind(value, DateTimeKind.Unspecified);
        }

        private static DateTime GetLessonTimeNow()
        {
            return TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, LessonTimeZone);
        }

        private static bool IsWithinEntryWindow(DateTime? startTime, DateTime? endTime)
        {
            if (startTime == null || endTime == null) return false;

            var normalizedStart = NormalizeEntryWindowDateTime(startTime.Value);
            var normalizedEnd = NormalizeEntryWindowDateTime(endTime.Value);
            var now = GetLessonTimeNow();
            var enterFrom = normalizedStart.AddMinutes(-10);
            var enterUntil = normalizedEnd.AddMinutes(15);
            return now >= enterFrom && now <= enterUntil;
        }

        private static bool IsCancelledStatus(string? status)
        {
            var normalized = status?.Trim().ToLowerInvariant();
            return normalized == "cancelled" || normalized == "canceled" || normalized == "cancelada" || normalized == "cancelado";
        }

        private static bool IsPendingStatus(string? status)
        {
            var normalized = status?.Trim().ToLowerInvariant();
            return normalized == "pending" || normalized == "waiting" || normalized == "requested" || normalized == "pendingpayment" || normalized == "pending_payment" || normalized == "awaiting_payment";
        }

        private static bool IsAcceptedStatus(string? status)
        {
            var normalized = status?.Trim().ToLowerInvariant();
            return normalized == "accepted" || normalized == "active" || normalized == "scheduled" || normalized == "confirmed";
        }

        private static bool IsRejectedStatus(string? status)
        {
            var normalized = status?.Trim().ToLowerInvariant();
            return normalized == "rejected" || normalized == "declined" || normalized == "refused" || normalized == "recusada" || normalized == "recusado";
        }

        private static string FormatLessonWindow(DateTime? startTime, DateTime? endTime)
        {
            if (startTime == null || endTime == null) return "horário a confirmar";

            var start = NormalizeEntryWindowDateTime(startTime.Value);
            var end = NormalizeEntryWindowDateTime(endTime.Value);
            if (start.Date == end.Date)
            {
                return $"{start:dd/MM/yyyy}, das {start:HH:mm} às {end:HH:mm}";
            }

            return $"{start:dd/MM/yyyy HH:mm} até {end:dd/MM/yyyy HH:mm}";
        }

        private static string BuildNotificationMetadata(Guid reservationId, string teacherName, string subject, DateTime? startTime, DateTime? endTime)
        {
            var query = string.Join("&", new[]
            {
                $"reservationId={Uri.EscapeDataString(reservationId.ToString())}",
                $"teacherName={Uri.EscapeDataString(teacherName)}",
                $"subject={Uri.EscapeDataString(subject)}",
                $"start={Uri.EscapeDataString(startTime?.ToString("o") ?? string.Empty)}",
                $"end={Uri.EscapeDataString(endTime?.ToString("o") ?? string.Empty)}"
            });

            return $"[[{query}]]";
        }

        private static int ToAgoraUid(Guid reservationId, bool isHost)
        {
            unchecked
            {
                var hash = reservationId.GetHashCode();
                if (hash == int.MinValue) hash = 1;
                hash = Math.Abs(hash);

                var reservationSlot = (hash % 49) + 1;
                return isHost ? reservationSlot : reservationSlot + 50;
            }
        }

        private bool TryGetCurrentUserId(out Guid userId)
        {
            userId = Guid.Empty;
            if (HttpContext.Items.TryGetValue("UserId", out var val) && val is Guid guid && guid != Guid.Empty)
            {
                userId = guid;
                return true;
            }
            return false;
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        // RESERVATIONS
        [HttpGet]
        public async Task<IActionResult> GetAllReservations()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetReservationsAllAsync());
        }

        // GET /api/Reservations/me/week
        // Returns reservations for the authenticated student in the current (ISO) week.
        [HttpGet("me/week")]
        public async Task<IActionResult> GetMyWeek([FromQuery] DateTime? weekStart)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var studentUserId)) return Unauthorized(new { error = "token_invalid" });

            var reference = weekStart ?? DateTime.UtcNow;
            var referenceDate = new DateTime(reference.Year, reference.Month, reference.Day);
            var diff = ((int)referenceDate.DayOfWeek + 6) % 7; // Monday=0..Sunday=6
            var computedWeekStart = referenceDate.AddDays(-diff);
            var computedWeekEnd = computedWeekStart.AddDays(7);

            var items = await _service.GetMyWeekAsync(studentUserId, computedWeekStart, computedWeekEnd);
            return Ok(items);
        }

        // GET /api/Reservations/me/upcoming?limit=4
        [HttpGet("me/upcoming")]
        public async Task<IActionResult> GetMyUpcoming([FromQuery] int limit = 4)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var studentUserId)) return Unauthorized(new { error = "token_invalid" });

            var nowUtc = DateTime.UtcNow;
            var from = new DateTime(nowUtc.Year, nowUtc.Month, nowUtc.Day, nowUtc.Hour, nowUtc.Minute, nowUtc.Second);

            var items = await _service.GetMyUpcomingAsync(studentUserId, from, limit);
            return Ok(items);
        }

        [HttpGet("professor/week")]
        public async Task<IActionResult> GetProfessorWeek([FromQuery] DateTime? weekStart, [FromQuery(Name = "target_role")] string? targetRole = null)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized(new { error = "token_invalid" });

            var professor = await _professors.GetProfessorByUserIdAsync(userId);
            if (professor == null || professor.IdProfessor == Guid.Empty)
            {
                return NotFound(new { error = "professor_not_found" });
            }

            var reference = weekStart ?? DateTime.UtcNow;
            var referenceDate = new DateTime(reference.Year, reference.Month, reference.Day);
            var diff = ((int)referenceDate.DayOfWeek + 6) % 7;
            var computedWeekStart = referenceDate.AddDays(-diff);
            var computedWeekEnd = computedWeekStart.AddDays(7);

            var items = await _service.GetProfessorWeekAsync(professor.IdProfessor, computedWeekStart, computedWeekEnd, targetRole);
            return Ok(items);
        }

        [HttpGet("professor/upcoming")]
        public async Task<IActionResult> GetProfessorUpcoming([FromQuery] int limit = 4, [FromQuery(Name = "target_role")] string? targetRole = null)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var userId)) return Unauthorized(new { error = "token_invalid" });

            var professor = await _professors.GetProfessorByUserIdAsync(userId);
            if (professor == null || professor.IdProfessor == Guid.Empty)
            {
                return NotFound(new { error = "professor_not_found" });
            }

            var nowUtc = DateTime.UtcNow;
            var from = new DateTime(nowUtc.Year, nowUtc.Month, nowUtc.Day, nowUtc.Hour, nowUtc.Minute, nowUtc.Second);

            var items = await _service.GetProfessorUpcomingAsync(professor.IdProfessor, from, limit, targetRole);
            return Ok(items);
        }

        [HttpPost("{idReservation:guid}/classroom-entry")]
        public async Task<IActionResult> EnterClassroom(Guid idReservation)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var currentUserId)) return Unauthorized(new { error = "token_invalid" });

            var reservation = await _service.GetReservationByIdAsync(idReservation);
            if (reservation == null || reservation.IdReservation == Guid.Empty)
            {
                return NotFound(new { error = "reservation_not_found" });
            }

            var lesson = await _lessons.GetLessonByIdAsync(reservation.IdLesson);
            if (lesson == null || lesson.IdLesson == Guid.Empty || lesson.IdProfessor == null || lesson.IdProfessor == Guid.Empty)
            {
                return NotFound(new { error = "lesson_not_found" });
            }

            var professor = await _professors.GetProfessorByIdAsync(lesson.IdProfessor.Value);
            if (professor == null || professor.IdProfessor == Guid.Empty)
            {
                return NotFound(new { error = "professor_not_found" });
            }

            var professorUser = await _users.GetByIdAsync(professor.IdUser);
            var studentUser = await _users.GetByIdAsync(reservation.IdUser);
            if (professorUser?.Id == null || studentUser?.Id == null)
            {
                return NotFound(new { error = "reservation_participants_not_found" });
            }

            var isProfessorHost = currentUserId == professor.IdUser;
            var isReservationStudent = currentUserId == reservation.IdUser;
            if (!isProfessorHost && !isReservationStudent)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new
                {
                    error = "classroom_access_denied",
                    message = "Esta aula não pertence ao utilizador autenticado."
                });
            }

            if (IsCancelledStatus(reservation.Status))
            {
                return Conflict(new { error = "reservation_cancelled", message = "Esta aula foi cancelada." });
            }

            if (!IsWithinEntryWindow(reservation.StartTime, reservation.EndTime))
            {
                return Conflict(new { error = "outside_entry_window", message = "A entrada na aula só está disponível de 10 minutos antes até 15 minutos após o fim." });
            }

            var professorUsername = NormalizeUsername(professorUser.Username);
            var studentUsername = NormalizeUsername(studentUser.Username);
            if (string.IsNullOrWhiteSpace(professorUsername) || string.IsNullOrWhiteSpace(studentUsername))
            {
                return Conflict(new { error = "missing_username", message = "Professor e aluno precisam de username para entrar na aula." });
            }

            var professorDisplayName = BuildDisplayName(
                professorUser.DisplayName,
                professorUser.FirstName,
                professorUser.LastName,
                professorUsername);
            var studentDisplayName = BuildDisplayName(
                studentUser.DisplayName,
                studentUser.FirstName,
                studentUser.LastName,
                studentUsername);

            var expectedRoomName = ExpectedProfessorRoomName(professorUsername);
            var room = await _professors.GetProfessorRoomByProfessorIdAsync(professor.IdUser);
            if (room == null)
            {
                room = new ProfessorRoom
                {
                    ProfessorId = professor.IdUser,
                    ProfessorName = professorDisplayName,
                    RoomName = expectedRoomName,
                    Description = $"Sala do professor {professorDisplayName}",
                    IsActive = true,
                };

                var roomId = await _professors.InsertProfessorRoomAsync(room);
                room.Id = roomId;
            }
            else if (!string.Equals(room.RoomName, expectedRoomName, StringComparison.Ordinal))
            {
                room.ProfessorName = professorDisplayName;
                room.RoomName = expectedRoomName;
                room.IsActive = true;
                await _professors.UpdateProfessorRoomAsync(room);
            }

            try
            {
                var callerUsername = isProfessorHost ? professorUsername : studentUsername;
                var callerDisplayName = isProfessorHost ? professorDisplayName : studentDisplayName;
                var agoraUid = ToAgoraUid(reservation.IdReservation, isProfessorHost);

                var config = await _agoraLessons.GetClientConfigAsync();
                if (string.IsNullOrWhiteSpace(config.AgoraAppId))
                {
                    return StatusCode(503, new { error = "agora_not_configured", message = "O Agora Integrator não tem App ID configurado." });
                }

                if (isProfessorHost)
                {
                    await _agoraLessons.StartCallByUsernameAsync(expectedRoomName, professorUsername, professorDisplayName);
                }
                else
                {
                    try
                    {
                        await _agoraLessons.JoinCallByUsernameAsync(expectedRoomName, studentUsername, studentDisplayName);
                    }
                    catch (AgoraLessonIntegratorException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
                    {
                        return Conflict(new { error = "class_not_started", message = "Aguarde o professor entrar na sala antes de se juntar à aula." });
                    }
                }

                await _agoraLessons.JoinOrCreateSessionAsync(expectedRoomName, agoraUid.ToString(), callerDisplayName);
                var rtcToken = await _agoraLessons.GenerateRtcTokenAsync(expectedRoomName, agoraUid.ToString());
                var whiteboardToken = await _agoraLessons.GetWhiteboardTokenAsync(expectedRoomName, agoraUid);

                ReservationClassroomScreenShareResponse? screenShare = null;
                if (isProfessorHost)
                {
                    var screenShareToken = await _agoraLessons.GenerateScreenShareTokenAsync(expectedRoomName, (uint)agoraUid);
                    screenShare = new ReservationClassroomScreenShareResponse
                    {
                        Uid = (int)screenShareToken.ScreenShareUid,
                        Token = screenShareToken.Token,
                    };
                }

                var response = new ReservationClassroomEntryResponse
                {
                    ReservationId = reservation.IdReservation,
                    LessonId = lesson.IdLesson,
                    ChannelName = expectedRoomName,
                    LessonTitle = lesson.Title?.Trim() ?? string.Empty,
                    ProfessorUsername = professorUsername,
                    ProfessorDisplayName = professorDisplayName,
                    StudentUsername = studentUsername,
                    StudentDisplayName = studentDisplayName,
                    IsHost = isProfessorHost,
                    AgoraUid = agoraUid,
                    AgoraAppId = config.AgoraAppId,
                    RtcToken = rtcToken.Token,
                    StartTime = reservation.StartTime,
                    EndTime = reservation.EndTime,
                    ScreenShare = screenShare,
                    Whiteboard = new ReservationClassroomWhiteboardResponse
                    {
                        AppIdentifier = config.WhiteboardAppIdentifier,
                        Region = config.WhiteboardRegion,
                        Uuid = whiteboardToken.Uuid,
                        RoomToken = whiteboardToken.Token,
                    },
                };

                return Ok(response);
            }
            catch (AgoraLessonIntegratorException ex)
            {
                _logger.LogError(ex, "Failed to create classroom entry for reservation {ReservationId}", idReservation);
                return StatusCode(503, new { error = "agora_integrator_unavailable", message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Unexpected classroom entry error for reservation {ReservationId}", idReservation);
                return StatusCode(500, new { error = "classroom_entry_failed", message = "Não foi possível preparar a entrada na aula." });
            }
        }

        [HttpGet("me/area-summary")]
        public async Task<IActionResult> GetMyAreaSummary([FromQuery] Guid idArea)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var studentUserId)) return Unauthorized(new { error = "token_invalid" });
            if (idArea == Guid.Empty) return BadRequest(new { error = "id_area_invalid" });

            var nowUtc = DateTime.UtcNow;
            var from = new DateTime(nowUtc.Year, nowUtc.Month, nowUtc.Day, nowUtc.Hour, nowUtc.Minute, nowUtc.Second);

            var summary = await _service.GetMyAreaLessonSummaryAsync(studentUserId, idArea, from);
            return Ok(summary);
        }

        [HttpGet("{idReservation:guid}")]
        public async Task<IActionResult> GetReservation(Guid idReservation)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetReservationByIdAsync(idReservation);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost]
        public async Task<IActionResult> CreateReservation([FromBody] Reservation reservation)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;

            if (!TryGetCurrentUserId(out var studentUserId)) return Unauthorized(new { error = "token_invalid" });
            // Always bind the reservation to the authenticated user.
            reservation.IdUser = studentUserId;

            var id = await _service.InsertReservationAsync(reservation);
            reservation.IdReservation = id;

            // Best-effort: auto-create contacts (student <-> professor) when booking a lesson.
            try
            {
                var lesson = await _lessons.GetLessonByIdAsync(reservation.IdLesson);
                if (lesson?.IdProfessor != null && lesson.IdProfessor.Value != Guid.Empty)
                {
                    var professor = await _professors.GetProfessorByIdAsync(lesson.IdProfessor.Value);
                    var professorUserId = professor?.IdUser ?? Guid.Empty;

                    if (professorUserId != Guid.Empty && professorUserId != studentUserId)
                    {
                        await _communication.UpsertContactAsync(new Contact
                        {
                            OwnerUserId = studentUserId,
                            ContactUserId = professorUserId,
                            Status = "accepted"
                        });

                        await _communication.UpsertContactAsync(new Contact
                        {
                            OwnerUserId = professorUserId,
                            ContactUserId = studentUserId,
                            Status = "accepted"
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to auto-create contacts for reservation {ReservationId}", id);
            }

            return CreatedAtAction(nameof(GetReservation), new { idReservation = id }, reservation);
        }

        [HttpPut("{idReservation:guid}")]
        public async Task<IActionResult> UpdateReservation(Guid idReservation, [FromBody] Reservation reservation)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idReservation != reservation.IdReservation) return BadRequest();
            var rows = await _service.UpdateReservationAsync(reservation);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpPost("{idReservation:guid}/accept")]
        public async Task<IActionResult> AcceptReservation(Guid idReservation)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var currentUserId)) return Unauthorized(new { error = "token_invalid" });

            var reservation = await _service.GetReservationByIdAsync(idReservation);
            if (reservation == null || reservation.IdReservation == Guid.Empty)
            {
                return NotFound(new { error = "reservation_not_found" });
            }

            if (reservation.IdUser != currentUserId)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new
                {
                    error = "reservation_access_denied",
                    message = "Só o aluno desta explicação pode aceitá-la."
                });
            }

            if (IsCancelledStatus(reservation.Status))
            {
                return Conflict(new { error = "reservation_cancelled", message = "Esta aula foi cancelada." });
            }

            if (!IsPendingStatus(reservation.Status) && IsAcceptedStatus(reservation.Status))
            {
                await _users.MarkLessonRequestNotificationsAsReadAsync(currentUserId, reservation.IdReservation);
                return NoContent();
            }

            if (!IsPendingStatus(reservation.Status))
            {
                return Conflict(new { error = "reservation_not_pending", status = reservation.Status });
            }

            var paymentReview = await _payments.GetReservationPaymentReviewAsync(currentUserId, idReservation);
            if (paymentReview != null && paymentReview.Amount > 0m && !paymentReview.AlreadyPaid)
            {
                return Conflict(new
                {
                    error = "payment_required",
                    message = "É necessário pagar a aula antes de a confirmar.",
                    amount = paymentReview.Amount,
                    currency = paymentReview.Currency
                });
            }

            reservation.Status = "accepted";
            var reservationRows = await _service.UpdateReservationAsync(reservation);
            if (reservationRows == 0)
            {
                return NotFound(new { error = "reservation_not_found" });
            }

            await _users.MarkLessonRequestNotificationsAsReadAsync(currentUserId, reservation.IdReservation);

            var lesson = await _lessons.GetLessonByIdAsync(reservation.IdLesson);
            if (lesson != null)
            {
                var enrollment = await _lessons.GetEnrollmentByLessonAndUserAsync(reservation.IdLesson, reservation.IdUser);
                if (enrollment != null)
                {
                    enrollment.Status = "Active";
                    await _lessons.UpdateEnrollmentAsync(enrollment);
                }

                if (lesson.IdProfessor != null && lesson.IdProfessor != Guid.Empty)
                {
                    var professor = await _professors.GetProfessorByIdAsync(lesson.IdProfessor.Value);
                    if (professor != null && professor.IdUser != Guid.Empty)
                    {
                        try
                        {
                            var student = await _users.GetByIdAsync(currentUserId);
                            var studentName = BuildDisplayName(
                                student?.DisplayName,
                                student?.FirstName,
                                student?.LastName,
                                student?.Username ?? "Aluno");
                            await _communication.InsertNotificationAsync(new Notification
                            {
                                IdUser = professor.IdUser,
                                Type = "aula",
                                Message = $"O aluno {studentName} aceitou a aula {lesson.Title?.Trim() ?? "agendada"} marcada para {FormatLessonWindow(reservation.StartTime, reservation.EndTime)}.",
                                WasRead = false,
                                CreatedAt = DateTime.UtcNow,
                                UpdatedAt = DateTime.UtcNow,
                            });
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning(ex, "Failed to notify professor {ProfessorUserId} for accepted reservation {ReservationId}", professor.IdUser, reservation.IdReservation);
                        }
                    }
                }
            }

            return NoContent();
        }

        [HttpGet("{idReservation:guid}/payment-review")]
        public async Task<IActionResult> GetReservationPaymentReview(Guid idReservation)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var currentUserId)) return Unauthorized(new { error = "token_invalid" });

            var review = await _payments.GetReservationPaymentReviewAsync(currentUserId, idReservation);
            return review == null ? NotFound(new { error = "reservation_not_found" }) : Ok(review);
        }

        [HttpPost("{idReservation:guid}/pay-and-accept")]
        public async Task<IActionResult> PayAndAcceptReservation(Guid idReservation)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var currentUserId)) return Unauthorized(new { error = "token_invalid" });

            var reservation = await _service.GetReservationByIdAsync(idReservation);
            if (reservation == null || reservation.IdReservation == Guid.Empty)
            {
                return NotFound(new { error = "reservation_not_found" });
            }

            if (reservation.IdUser != currentUserId)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new
                {
                    error = "reservation_access_denied",
                    message = "Só o aluno desta explicação pode confirmá-la."
                });
            }

            if (IsCancelledStatus(reservation.Status))
            {
                return Conflict(new { error = "reservation_cancelled", message = "Esta aula foi cancelada." });
            }

            if (!IsPendingStatus(reservation.Status) && !IsAcceptedStatus(reservation.Status))
            {
                return Conflict(new { error = "reservation_not_pending", status = reservation.Status });
            }

            ConfidantPostgreSQL.Modules.Payments.Models.ReservationPaymentProcessResultDto paymentResult;
            try
            {
                paymentResult = await _payments.ProcessReservationPaymentAsync(currentUserId, idReservation);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { error = "payment_failed", message = ex.Message });
            }

            reservation.Status = "accepted";
            var reservationRows = await _service.UpdateReservationAsync(reservation);
            if (reservationRows == 0)
            {
                return NotFound(new { error = "reservation_not_found" });
            }

            await _users.MarkLessonRequestNotificationsAsReadAsync(currentUserId, reservation.IdReservation);

            var lesson = await _lessons.GetLessonByIdAsync(reservation.IdLesson);
            if (lesson != null)
            {
                var enrollment = await _lessons.GetEnrollmentByLessonAndUserAsync(reservation.IdLesson, reservation.IdUser);
                if (enrollment != null)
                {
                    enrollment.Status = "Active";
                    enrollment.PricePaid = paymentResult.Amount;
                    await _lessons.UpdateEnrollmentAsync(enrollment);
                }

                if (lesson.IdProfessor != null && lesson.IdProfessor != Guid.Empty)
                {
                    var professor = await _professors.GetProfessorByIdAsync(lesson.IdProfessor.Value);
                    if (professor != null && professor.IdUser != Guid.Empty)
                    {
                        try
                        {
                            var student = await _users.GetByIdAsync(currentUserId);
                            var studentName = BuildDisplayName(
                                student?.DisplayName,
                                student?.FirstName,
                                student?.LastName,
                                student?.Username ?? "Aluno");
                            var paymentSuffix = paymentResult.Amount > 0m
                                ? $" O pagamento de {paymentResult.Amount:0.00} {paymentResult.Currency} foi confirmado."
                                : string.Empty;
                            await _communication.InsertNotificationAsync(new Notification
                            {
                                IdUser = professor.IdUser,
                                Type = "aula",
                                Message = $"O aluno {studentName} confirmou a aula {lesson.Title?.Trim() ?? "agendada"} marcada para {FormatLessonWindow(reservation.StartTime, reservation.EndTime)}.{paymentSuffix}",
                                WasRead = false,
                                CreatedAt = DateTime.UtcNow,
                                UpdatedAt = DateTime.UtcNow,
                            });
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning(ex, "Failed to notify professor {ProfessorUserId} for paid reservation {ReservationId}", professor.IdUser, reservation.IdReservation);
                        }
                    }
                }
            }

            return Ok(paymentResult);
        }

        [HttpPost("{idReservation:guid}/reject")]
        public async Task<IActionResult> RejectReservation(Guid idReservation)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var currentUserId)) return Unauthorized(new { error = "token_invalid" });

            var reservation = await _service.GetReservationByIdAsync(idReservation);
            if (reservation == null || reservation.IdReservation == Guid.Empty)
            {
                return NotFound(new { error = "reservation_not_found" });
            }

            if (reservation.IdUser != currentUserId)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new
                {
                    error = "reservation_access_denied",
                    message = "Só o aluno desta explicação pode recusá-la."
                });
            }

            if (IsCancelledStatus(reservation.Status) || IsRejectedStatus(reservation.Status))
            {
                await _users.MarkLessonRequestNotificationsAsReadAsync(currentUserId, reservation.IdReservation);
                return NoContent();
            }

            if (!IsPendingStatus(reservation.Status))
            {
                if (IsAcceptedStatus(reservation.Status))
                {
                    await _users.MarkLessonRequestNotificationsAsReadAsync(currentUserId, reservation.IdReservation);
                }

                return Conflict(new { error = "reservation_not_pending", status = reservation.Status });
            }

            reservation.Status = "rejected";
            var reservationRows = await _service.UpdateReservationAsync(reservation);
            if (reservationRows == 0)
            {
                return NotFound(new { error = "reservation_not_found" });
            }

            await _users.MarkLessonRequestNotificationsAsReadAsync(currentUserId, reservation.IdReservation);

            var lesson = await _lessons.GetLessonByIdAsync(reservation.IdLesson);
            if (lesson != null)
            {
                var enrollment = await _lessons.GetEnrollmentByLessonAndUserAsync(reservation.IdLesson, reservation.IdUser);
                if (enrollment != null)
                {
                    enrollment.Status = "Declined";
                    await _lessons.UpdateEnrollmentAsync(enrollment);
                }

                if (lesson.IdProfessor != null && lesson.IdProfessor != Guid.Empty)
                {
                    var professor = await _professors.GetProfessorByIdAsync(lesson.IdProfessor.Value);
                    if (professor != null && professor.IdUser != Guid.Empty)
                    {
                        try
                        {
                            var student = await _users.GetByIdAsync(currentUserId);
                            var studentName = BuildDisplayName(
                                student?.DisplayName,
                                student?.FirstName,
                                student?.LastName,
                                student?.Username ?? "Aluno");

                            await _communication.InsertNotificationAsync(new Notification
                            {
                                IdUser = professor.IdUser,
                                Type = "aula",
                                Message = $"O aluno {studentName} recusou a aula {lesson.Title?.Trim() ?? "agendada"} prevista para {FormatLessonWindow(reservation.StartTime, reservation.EndTime)}.",
                                WasRead = false,
                                CreatedAt = DateTime.UtcNow,
                                UpdatedAt = DateTime.UtcNow,
                            });
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning(ex, "Failed to notify professor {ProfessorUserId} for rejected reservation {ReservationId}", professor.IdUser, reservation.IdReservation);
                        }
                    }
                }
            }

            return NoContent();
        }

        [HttpPost("{idReservation:guid}/cancel-by-professor")]
        public async Task<IActionResult> CancelReservationByProfessor(Guid idReservation)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetCurrentUserId(out var currentUserId)) return Unauthorized(new { error = "token_invalid" });

            var reservation = await _service.GetReservationByIdAsync(idReservation);
            if (reservation == null || reservation.IdReservation == Guid.Empty)
            {
                return NotFound(new { error = "reservation_not_found" });
            }

            var lesson = await _lessons.GetLessonByIdAsync(reservation.IdLesson);
            if (lesson == null || lesson.IdLesson == Guid.Empty || lesson.IdProfessor == null || lesson.IdProfessor == Guid.Empty)
            {
                return NotFound(new { error = "lesson_not_found" });
            }

            var professor = await _professors.GetProfessorByIdAsync(lesson.IdProfessor.Value);
            if (professor == null || professor.IdUser == Guid.Empty)
            {
                return NotFound(new { error = "professor_not_found" });
            }

            if (professor.IdUser != currentUserId)
            {
                return StatusCode(StatusCodes.Status403Forbidden, new
                {
                    error = "reservation_access_denied",
                    message = "Só o professor da aula pode cancelá-la."
                });
            }

            var professorUser = await _users.GetByIdAsync(currentUserId);
            var teacherName = BuildDisplayName(
                professorUser?.DisplayName,
                professorUser?.FirstName,
                professorUser?.LastName,
                professorUser?.Username ?? "Professor");

            var lessonReservations = (await _service.GetReservationsByLessonAsync(lesson.IdLesson)).ToList();
            var enrollments = (await _lessons.GetEnrollmentsByLessonAsync(lesson.IdLesson))
                .GroupBy(item => item.IdUser)
                .ToDictionary(group => group.Key, group => group.OrderByDescending(item => item.CreatedAt).First());

            var affectedStudents = 0;
            var refundedStudents = 0;
            decimal refundedAmount = 0m;
            var lessonTitle = lesson.Title?.Trim();
            var subject = string.IsNullOrWhiteSpace(lessonTitle) ? "Explicação" : lessonTitle;

            foreach (var lessonReservation in lessonReservations)
            {
                if (!IsCancelledStatus(lessonReservation.Status))
                {
                    lessonReservation.Status = "cancelled";
                    await _service.UpdateReservationAsync(lessonReservation);
                }

                if (enrollments.TryGetValue(lessonReservation.IdUser, out var enrollment))
                {
                    enrollment.Status = "Cancelled";
                    await _lessons.UpdateEnrollmentAsync(enrollment);
                }

                await _users.MarkLessonRequestNotificationsAsReadAsync(lessonReservation.IdUser, lessonReservation.IdReservation);

                var refundResult = await _payments.RefundReservationPaymentAsync(lessonReservation.IdReservation);
                if (refundResult.Refunded)
                {
                    refundedStudents++;
                    refundedAmount += refundResult.RefundedAmount;
                }

                var refundSuffix = refundResult.Refunded && refundResult.RefundedAmount > 0m
                    ? $" Os teus {refundResult.RefundedAmount:0.00} {refundResult.Currency} foram devolvidos automaticamente."
                    : string.Empty;
                var metadata = Environment.NewLine + BuildNotificationMetadata(
                    lessonReservation.IdReservation,
                    teacherName,
                    subject,
                    lessonReservation.StartTime,
                    lessonReservation.EndTime);

                await _communication.InsertNotificationAsync(new Notification
                {
                    IdUser = lessonReservation.IdUser,
                    Type = "aula_cancelada_professor",
                    Message = $"O professor {teacherName} cancelou a aula {subject} marcada para {FormatLessonWindow(lessonReservation.StartTime, lessonReservation.EndTime)}.{refundSuffix}{metadata}",
                    WasRead = false,
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                });

                affectedStudents++;
            }

            return Ok(new
            {
                lessonId = lesson.IdLesson,
                cancelledReservations = affectedStudents,
                refundedStudents,
                refundedAmount
            });
        }

        [HttpDelete("{idReservation:guid}")]
        public async Task<IActionResult> DeleteReservation(Guid idReservation)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteReservationAsync(idReservation);
            return rows == 0 ? NotFound() : NoContent();
        }

        // EXCEPTION RULES
        [HttpGet("exception-rules")]
        public async Task<IActionResult> GetAllExceptionRules()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetExceptionRulesAllAsync());
        }

        [HttpGet("exception-rules/{idExceptionRule:guid}")]
        public async Task<IActionResult> GetExceptionRule(Guid idExceptionRule)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetExceptionRuleByIdAsync(idExceptionRule);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("exception-rules")]
        public async Task<IActionResult> CreateExceptionRule([FromBody] ExceptionRule rule)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertExceptionRuleAsync(rule);
            rule.IdExceptionRule = id;
            return CreatedAtAction(nameof(GetExceptionRule), new { idExceptionRule = id }, rule);
        }

        [HttpPut("exception-rules/{idExceptionRule:guid}")]
        public async Task<IActionResult> UpdateExceptionRule(Guid idExceptionRule, [FromBody] ExceptionRule rule)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idExceptionRule != rule.IdExceptionRule) return BadRequest();
            var rows = await _service.UpdateExceptionRuleAsync(rule);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("exception-rules/{idExceptionRule:guid}")]
        public async Task<IActionResult> DeleteExceptionRule(Guid idExceptionRule)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteExceptionRuleAsync(idExceptionRule);
            return rows == 0 ? NotFound() : NoContent();
        }

        // EXCEPTION REQUESTS
        [HttpGet("exception-requests")]
        public async Task<IActionResult> GetAllExceptionRequests()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetExceptionRequestsAllAsync());
        }

        [HttpGet("exception-requests/{idExceptionRequest:guid}")]
        public async Task<IActionResult> GetExceptionRequest(Guid idExceptionRequest)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetExceptionRequestByIdAsync(idExceptionRequest);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("exception-requests")]
        public async Task<IActionResult> CreateExceptionRequest([FromBody] ExceptionRequest request)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertExceptionRequestAsync(request);
            request.IdExceptionRequest = id;
            return CreatedAtAction(nameof(GetExceptionRequest), new { idExceptionRequest = id }, request);
        }

        [HttpPut("exception-requests/{idExceptionRequest:guid}")]
        public async Task<IActionResult> UpdateExceptionRequest(Guid idExceptionRequest, [FromBody] ExceptionRequest request)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idExceptionRequest != request.IdExceptionRequest) return BadRequest();
            var rows = await _service.UpdateExceptionRequestAsync(request);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("exception-requests/{idExceptionRequest:guid}")]
        public async Task<IActionResult> DeleteExceptionRequest(Guid idExceptionRequest)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteExceptionRequestAsync(idExceptionRequest);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
