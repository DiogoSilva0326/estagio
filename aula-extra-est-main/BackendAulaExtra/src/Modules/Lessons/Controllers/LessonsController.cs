using System;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Communication.Models;
using ConfidantPostgreSQL.Modules.Communication.Service;
using ConfidantPostgreSQL.Modules.Lessons.Models;
using ConfidantPostgreSQL.Modules.Lessons.Service;
using ConfidantPostgreSQL.Modules.Professors.Service;
using ConfidantPostgreSQL.Modules.Reservations.Models;
using ConfidantPostgreSQL.Modules.Reservations.Service;
using ConfidantPostgreSQL.Modules.Users.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Lessons.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class LessonsController : ControllerBase
    {
        private readonly ILessonsService _service;
        private readonly IReservationsService _reservations;
        private readonly ICommunicationService _communication;
        private readonly IUserService _users;
        private readonly IProfessorsService _professors;

        public LessonsController(
            ILessonsService service,
            IReservationsService reservations,
            ICommunicationService communication,
            IUserService users,
            IProfessorsService professors)
        {
            _service = service;
            _reservations = reservations;
            _communication = communication;
            _users = users;
            _professors = professors;
        }

        private static string NormalizePendingStatus(string? status)
        {
            var normalized = status?.Trim();
            return string.IsNullOrWhiteSpace(normalized) ? "Pending" : normalized;
        }

        private static string BuildDisplayName(string? displayName, string? firstName, string? lastName, string fallback)
        {
            if (!string.IsNullOrWhiteSpace(displayName)) return displayName.Trim();

            var fullName = string.Join(" ", new[] { firstName?.Trim(), lastName?.Trim() }
                .Where(value => !string.IsNullOrWhiteSpace(value))).Trim();

            return !string.IsNullOrWhiteSpace(fullName) ? fullName : fallback;
        }

        private static string FormatLessonWindow(DateTime? startTime, DateTime? endTime)
        {
            if (startTime == null || endTime == null) return "horário a confirmar";

            var culture = new CultureInfo("pt-PT");
            var start = startTime.Value;
            var end = endTime.Value;

            if (start.Date == end.Date)
            {
                return $"{start.ToString("dd/MM/yyyy", culture)}, das {start.ToString("HH:mm", culture)} às {end.ToString("HH:mm", culture)}";
            }

            return $"{start.ToString("dd/MM/yyyy HH:mm", culture)} até {end.ToString("dd/MM/yyyy HH:mm", culture)}";
        }

        private static string BuildLessonRequestMetadata(Guid reservationId, string teacherName, string subject, DateTime? startTime, DateTime? endTime, decimal? amount, string? currency)
        {
            var query = string.Join("&", new[]
            {
                $"reservationId={Uri.EscapeDataString(reservationId.ToString())}",
                $"teacherName={Uri.EscapeDataString(teacherName)}",
                $"subject={Uri.EscapeDataString(subject)}",
                $"start={Uri.EscapeDataString(startTime?.ToString("o") ?? string.Empty)}",
                $"end={Uri.EscapeDataString(endTime?.ToString("o") ?? string.Empty)}",
                $"amount={Uri.EscapeDataString(amount?.ToString("0.00", CultureInfo.InvariantCulture) ?? string.Empty)}",
                $"currency={Uri.EscapeDataString(string.IsNullOrWhiteSpace(currency) ? "EUR" : currency!)}"
            });

            return $"[[{query}]]";
        }

        // LESSONS
        [HttpGet("lessons")]
        public async Task<IActionResult> GetLessons()
        {
            return Ok(await _service.GetLessonsAllAsync());
        }

        [HttpGet("lessons/{idLesson:guid}")]
        public async Task<IActionResult> GetLesson(Guid idLesson)
        {
            var item = await _service.GetLessonByIdAsync(idLesson);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("lessons")]
        public async Task<IActionResult> CreateLesson([FromBody] Lesson lesson)
        {
            var id = await _service.InsertLessonAsync(lesson);
            lesson.IdLesson = id;
            return CreatedAtAction(nameof(GetLesson), new { idLesson = id }, lesson);
        }

        [HttpPut("lessons/{idLesson:guid}")]
        public async Task<IActionResult> UpdateLesson(Guid idLesson, [FromBody] Lesson lesson)
        {
            if (idLesson != lesson.IdLesson) return BadRequest();
            var rows = await _service.UpdateLessonAsync(lesson);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("lessons/{idLesson:guid}")]
        public async Task<IActionResult> DeleteLesson(Guid idLesson)
        {
            var rows = await _service.DeleteLessonAsync(idLesson);
            return rows == 0 ? NotFound() : NoContent();
        }

        // LESSON FEEDBACK
        [HttpGet("lesson-feedback")]
        public async Task<IActionResult> GetLessonFeedback()
        {
            return Ok(await _service.GetLessonFeedbackAllAsync());
        }

        [HttpGet("lesson-feedback/{idLessonFeedback:guid}")]
        public async Task<IActionResult> GetLessonFeedbackById(Guid idLessonFeedback)
        {
            var item = await _service.GetLessonFeedbackByIdAsync(idLessonFeedback);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("lesson-feedback")]
        public async Task<IActionResult> CreateLessonFeedback([FromBody] LessonFeedback feedback)
        {
            var id = await _service.InsertLessonFeedbackAsync(feedback);
            feedback.IdLessonFeedback = id;
            return CreatedAtAction(nameof(GetLessonFeedbackById), new { idLessonFeedback = id }, feedback);
        }

        [HttpPut("lesson-feedback/{idLessonFeedback:guid}")]
        public async Task<IActionResult> UpdateLessonFeedback(Guid idLessonFeedback, [FromBody] LessonFeedback feedback)
        {
            if (idLessonFeedback != feedback.IdLessonFeedback) return BadRequest();
            var rows = await _service.UpdateLessonFeedbackAsync(feedback);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("lesson-feedback/{idLessonFeedback:guid}")]
        public async Task<IActionResult> DeleteLessonFeedback(Guid idLessonFeedback)
        {
            var rows = await _service.DeleteLessonFeedbackAsync(idLessonFeedback);
            return rows == 0 ? NotFound() : NoContent();
        }

        // LESSON PRICES
        [HttpGet("lesson-prices")]
        public async Task<IActionResult> GetLessonPrices()
        {
            return Ok(await _service.GetLessonPricesAllAsync());
        }

        [HttpGet("lesson-prices/{idLessonPrice:guid}")]
        public async Task<IActionResult> GetLessonPrice(Guid idLessonPrice)
        {
            var item = await _service.GetLessonPriceByIdAsync(idLessonPrice);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("lesson-prices")]
        public async Task<IActionResult> CreateLessonPrice([FromBody] LessonPrice price)
        {
            var id = await _service.InsertLessonPriceAsync(price);
            price.IdLessonPrice = id;
            return CreatedAtAction(nameof(GetLessonPrice), new { idLessonPrice = id }, price);
        }

        [HttpPut("lesson-prices/{idLessonPrice:guid}")]
        public async Task<IActionResult> UpdateLessonPrice(Guid idLessonPrice, [FromBody] LessonPrice price)
        {
            if (idLessonPrice != price.IdLessonPrice) return BadRequest();
            var rows = await _service.UpdateLessonPriceAsync(price);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("lesson-prices/{idLessonPrice:guid}")]
        public async Task<IActionResult> DeleteLessonPrice(Guid idLessonPrice)
        {
            var rows = await _service.DeleteLessonPriceAsync(idLessonPrice);
            return rows == 0 ? NotFound() : NoContent();
        }

        // LESSON SCHEDULE BLOCKS
        [HttpGet("lesson-schedule-blocks")]
        public async Task<IActionResult> GetLessonScheduleBlocks() => Ok(await _service.GetLessonScheduleBlocksAllAsync());

        [HttpGet("lesson-schedule-blocks/{idLessonScheduleBlock:guid}")]
        public async Task<IActionResult> GetLessonScheduleBlock(Guid idLessonScheduleBlock)
        {
            var item = await _service.GetLessonScheduleBlockByIdAsync(idLessonScheduleBlock);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("lesson-schedule-blocks")]
        public async Task<IActionResult> CreateLessonScheduleBlock([FromBody] LessonScheduleBlock block)
        {
            var id = await _service.InsertLessonScheduleBlockAsync(block);
            block.IdLessonScheduleBlock = id;
            return CreatedAtAction(nameof(GetLessonScheduleBlock), new { idLessonScheduleBlock = id }, block);
        }

        [HttpPut("lesson-schedule-blocks/{idLessonScheduleBlock:guid}")]
        public async Task<IActionResult> UpdateLessonScheduleBlock(Guid idLessonScheduleBlock, [FromBody] LessonScheduleBlock block)
        {
            if (idLessonScheduleBlock != block.IdLessonScheduleBlock) return BadRequest();
            var rows = await _service.UpdateLessonScheduleBlockAsync(block);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("lesson-schedule-blocks/{idLessonScheduleBlock:guid}")]
        public async Task<IActionResult> DeleteLessonScheduleBlock(Guid idLessonScheduleBlock)
        {
            var rows = await _service.DeleteLessonScheduleBlockAsync(idLessonScheduleBlock);
            return rows == 0 ? NotFound() : NoContent();
        }

        // ENROLLMENTS
        [HttpGet("enrollments")]
        public async Task<IActionResult> GetEnrollments() => Ok(await _service.GetEnrollmentsAllAsync());

        [HttpGet("enrollments/{idEnrollment:guid}")]
        public async Task<IActionResult> GetEnrollment(Guid idEnrollment)
        {
            var item = await _service.GetEnrollmentByIdAsync(idEnrollment);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("enrollments")]
        public async Task<IActionResult> CreateEnrollment([FromBody] Enrollment enrollment)
        {
            enrollment.Status = NormalizePendingStatus(enrollment.Status);
            var id = await _service.InsertEnrollmentAsync(enrollment);
            enrollment.IdEnrollment = id;

            Lesson? lesson = null;
            Guid reservationId = Guid.Empty;

            try
            {
                lesson = await _service.GetLessonByIdAsync(enrollment.IdLesson);
                if (lesson != null)
                {
                    var existingReservation = await _reservations
                        .GetReservationByLessonAndUserAsync(enrollment.IdLesson, enrollment.IdUser);

                    var reservationStatus = string.IsNullOrWhiteSpace(enrollment.Status)
                        ? "Pending"
                        : enrollment.Status;

                    if (existingReservation == null)
                    {
                        reservationId = await _reservations.InsertReservationAsync(new Reservation
                        {
                            IdUser = enrollment.IdUser,
                            IdLesson = enrollment.IdLesson,
                            StartTime = lesson.ScheduledStart,
                            EndTime = lesson.ScheduledEnd,
                            MinStudentsAtBooking = 1,
                            Status = reservationStatus,
                        });
                    }
                    else
                    {
                        existingReservation.StartTime = lesson.ScheduledStart;
                        existingReservation.EndTime = lesson.ScheduledEnd;
                        existingReservation.Status = reservationStatus;
                        await _reservations.UpdateReservationAsync(existingReservation);
                        reservationId = existingReservation.IdReservation;
                    }
                }
            }
            catch
            {
                await _service.DeleteEnrollmentAsync(id);
                throw;
            }

            if (lesson != null)
            {
                try
                {
                    var subject = lesson.Title?.Trim();
                    if (string.IsNullOrWhiteSpace(subject)) subject = "Explicação";

                    var teacherName = "Professor";
                    if (lesson.IdProfessor != null && lesson.IdProfessor != Guid.Empty)
                    {
                        var professor = await _professors.GetProfessorByIdAsync(lesson.IdProfessor.Value);
                        if (professor != null && professor.IdUser != Guid.Empty)
                        {
                            var teacherUser = await _users.GetByIdAsync(professor.IdUser);
                            teacherName = BuildDisplayName(
                                teacherUser?.DisplayName,
                                teacherUser?.FirstName,
                                teacherUser?.LastName,
                                teacherUser?.Username ?? teacherName);
                        }
                    }

                    var priceAmount = lesson.BasePrice ?? 0m;
                    var currency = "EUR";
                    var metadata = reservationId == Guid.Empty
                        ? string.Empty
                        : Environment.NewLine + BuildLessonRequestMetadata(
                            reservationId,
                            teacherName,
                            subject,
                            lesson.ScheduledStart,
                            lesson.ScheduledEnd,
                            priceAmount,
                            currency);

                    var paymentSentence = priceAmount > 0m
                        ? $" Valor a pagar antes da confirmação: {priceAmount.ToString("0.00", CultureInfo.InvariantCulture)} {currency}."
                        : string.Empty;

                    await _communication.InsertNotificationAsync(new Notification
                    {
                        IdUser = enrollment.IdUser,
                        Type = "marcar_aula",
                        Message = $"O professor {teacherName} enviou a marcação da aula {subject} para {FormatLessonWindow(lesson.ScheduledStart, lesson.ScheduledEnd)}.{paymentSentence} Paga e confirma ou recusa para concluir o agendamento.{metadata}",
                        WasRead = false,
                        CreatedAt = DateTime.UtcNow,
                        UpdatedAt = DateTime.UtcNow,
                    });
                }
                catch
                {
                }
            }

            return CreatedAtAction(nameof(GetEnrollment), new { idEnrollment = id }, enrollment);
        }

        [HttpPut("enrollments/{idEnrollment:guid}")]
        public async Task<IActionResult> UpdateEnrollment(Guid idEnrollment, [FromBody] Enrollment enrollment)
        {
            if (idEnrollment != enrollment.IdEnrollment) return BadRequest();
            var rows = await _service.UpdateEnrollmentAsync(enrollment);
            if (rows > 0)
            {
                var reservation = await _reservations.GetReservationByLessonAndUserAsync(enrollment.IdLesson, enrollment.IdUser);
                if (reservation != null)
                {
                    reservation.Status = enrollment.Status;
                    await _reservations.UpdateReservationAsync(reservation);
                }
            }
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("enrollments/{idEnrollment:guid}")]
        public async Task<IActionResult> DeleteEnrollment(Guid idEnrollment)
        {
            var rows = await _service.DeleteEnrollmentAsync(idEnrollment);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
