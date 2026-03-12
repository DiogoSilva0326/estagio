using System;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Courses.Models;
using ConfidantPostgreSQL.Modules.Courses.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Courses.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class CoursesController : ControllerBase
    {
        private readonly ICoursesService _service;

        public CoursesController(ICoursesService service)
        {
            _service = service;
        }

        private bool TryAuthorize(out IActionResult? unauthorized)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            unauthorized = null;
            return true;
        }

        // TUTORING TYPES
        [HttpGet("tutoring-types")]
        public async Task<IActionResult> GetTutoringTypes()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetTutoringTypesAllAsync());
        }

        [HttpGet("tutoring-types/{idTutoringType:guid}")]
        public async Task<IActionResult> GetTutoringType(Guid idTutoringType)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetTutoringTypeByIdAsync(idTutoringType);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("tutoring-types")]
        public async Task<IActionResult> CreateTutoringType([FromBody] TutoringType tutoringType)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertTutoringTypeAsync(tutoringType);
            tutoringType.IdTutoringType = id;
            return CreatedAtAction(nameof(GetTutoringType), new { idTutoringType = id }, tutoringType);
        }

        [HttpPut("tutoring-types/{idTutoringType:guid}")]
        public async Task<IActionResult> UpdateTutoringType(Guid idTutoringType, [FromBody] TutoringType tutoringType)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idTutoringType != tutoringType.IdTutoringType) return BadRequest();
            var rows = await _service.UpdateTutoringTypeAsync(tutoringType);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("tutoring-types/{idTutoringType:guid}")]
        public async Task<IActionResult> DeleteTutoringType(Guid idTutoringType)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteTutoringTypeAsync(idTutoringType);
            return rows == 0 ? NotFound() : NoContent();
        }

        // PRICING MODELS
        [HttpGet("pricing-models")]
        public async Task<IActionResult> GetPricingModels()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetPricingModelsAllAsync());
        }

        [HttpGet("pricing-models/{idPricingModel:guid}")]
        public async Task<IActionResult> GetPricingModel(Guid idPricingModel)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetPricingModelByIdAsync(idPricingModel);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("pricing-models")]
        public async Task<IActionResult> CreatePricingModel([FromBody] PricingModel pricingModel)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertPricingModelAsync(pricingModel);
            pricingModel.IdPricingModel = id;
            return CreatedAtAction(nameof(GetPricingModel), new { idPricingModel = id }, pricingModel);
        }

        [HttpPut("pricing-models/{idPricingModel:guid}")]
        public async Task<IActionResult> UpdatePricingModel(Guid idPricingModel, [FromBody] PricingModel pricingModel)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idPricingModel != pricingModel.IdPricingModel) return BadRequest();
            var rows = await _service.UpdatePricingModelAsync(pricingModel);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("pricing-models/{idPricingModel:guid}")]
        public async Task<IActionResult> DeletePricingModel(Guid idPricingModel)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeletePricingModelAsync(idPricingModel);
            return rows == 0 ? NotFound() : NoContent();
        }

        // COURSES
        [HttpGet("courses")]
        public async Task<IActionResult> GetCourses()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetCoursesAllAsync());
        }

        [HttpGet("courses/{idCourse:guid}")]
        public async Task<IActionResult> GetCourse(Guid idCourse)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetCourseByIdAsync(idCourse);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("courses")]
        public async Task<IActionResult> CreateCourse([FromBody] Course course)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertCourseAsync(course);
            course.IdCourse = id;
            return CreatedAtAction(nameof(GetCourse), new { idCourse = id }, course);
        }

        [HttpPut("courses/{idCourse:guid}")]
        public async Task<IActionResult> UpdateCourse(Guid idCourse, [FromBody] Course course)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idCourse != course.IdCourse) return BadRequest();
            var rows = await _service.UpdateCourseAsync(course);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("courses/{idCourse:guid}")]
        public async Task<IActionResult> DeleteCourse(Guid idCourse)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteCourseAsync(idCourse);
            return rows == 0 ? NotFound() : NoContent();
        }

        // COURSE PRICES
        [HttpGet("course-prices")]
        public async Task<IActionResult> GetCoursePrices()
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            return Ok(await _service.GetCoursePricesAllAsync());
        }

        [HttpGet("course-prices/{idCoursePrice:guid}")]
        public async Task<IActionResult> GetCoursePrice(Guid idCoursePrice)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var item = await _service.GetCoursePriceByIdAsync(idCoursePrice);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("course-prices")]
        public async Task<IActionResult> CreateCoursePrice([FromBody] CoursePrice coursePrice)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var id = await _service.InsertCoursePriceAsync(coursePrice);
            coursePrice.IdCoursePrice = id;
            return CreatedAtAction(nameof(GetCoursePrice), new { idCoursePrice = id }, coursePrice);
        }

        [HttpPut("course-prices/{idCoursePrice:guid}")]
        public async Task<IActionResult> UpdateCoursePrice(Guid idCoursePrice, [FromBody] CoursePrice coursePrice)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            if (idCoursePrice != coursePrice.IdCoursePrice) return BadRequest();
            var rows = await _service.UpdateCoursePriceAsync(coursePrice);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("course-prices/{idCoursePrice:guid}")]
        public async Task<IActionResult> DeleteCoursePrice(Guid idCoursePrice)
        {
           //if (!TryAuthorize(out var unauthorized)) return unauthorized!;
            var rows = await _service.DeleteCoursePriceAsync(idCoursePrice);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
