using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Lessons.Models;
using ConfidantPostgreSQL.Modules.Lessons.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Lessons.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class LessonsController : ControllerBase
    {
        private readonly ILessonsService _service;

        public LessonsController(ILessonsService service)
        {
            _service = service;
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
            var id = await _service.InsertEnrollmentAsync(enrollment);
            enrollment.IdEnrollment = id;
            return CreatedAtAction(nameof(GetEnrollment), new { idEnrollment = id }, enrollment);
        }

        [HttpPut("enrollments/{idEnrollment:guid}")]
        public async Task<IActionResult> UpdateEnrollment(Guid idEnrollment, [FromBody] Enrollment enrollment)
        {
            if (idEnrollment != enrollment.IdEnrollment) return BadRequest();
            var rows = await _service.UpdateEnrollmentAsync(enrollment);
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
