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

        // LESSON PACKS
        [HttpGet("lesson-packs")]
        public async Task<IActionResult> GetLessonPacks()
        {
            return Ok(await _service.GetLessonPacksAllAsync());
        }

        [HttpGet("lesson-packs/{idLessonPack:guid}")]
        public async Task<IActionResult> GetLessonPack(Guid idLessonPack)
        {
            var item = await _service.GetLessonPackByIdAsync(idLessonPack);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpGet("lesson-packs/by-course/{idCourse:guid}")]
        public async Task<IActionResult> GetLessonPacksByCourse(Guid idCourse)
        {
            return Ok(await _service.GetLessonPacksByCourseIdAsync(idCourse));
        }

        [HttpPost("lesson-packs")]
        public async Task<IActionResult> CreateLessonPack([FromBody] LessonPack lessonPack)
        {
            var id = await _service.InsertLessonPackAsync(lessonPack);
            lessonPack.IdLessonPack = id;
            return CreatedAtAction(nameof(GetLessonPack), new { idLessonPack = id }, lessonPack);
        }

        [HttpPut("lesson-packs/{idLessonPack:guid}")]
        public async Task<IActionResult> UpdateLessonPack(Guid idLessonPack, [FromBody] LessonPack lessonPack)
        {
            if (idLessonPack != lessonPack.IdLessonPack) return BadRequest();
            var rows = await _service.UpdateLessonPackAsync(lessonPack);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("lesson-packs/{idLessonPack:guid}")]
        public async Task<IActionResult> DeleteLessonPack(Guid idLessonPack)
        {
            var rows = await _service.DeleteLessonPackAsync(idLessonPack);
            return rows == 0 ? NotFound() : NoContent();
        }

        // USER LESSON PACKS
        [HttpGet("user-lesson-packs")]
        public async Task<IActionResult> GetUserLessonPacks()
        {
            return Ok(await _service.GetUserLessonPacksAllAsync());
        }

        [HttpGet("user-lesson-packs/{idUserLessonPack:guid}")]
        public async Task<IActionResult> GetUserLessonPack(Guid idUserLessonPack)
        {
            var item = await _service.GetUserLessonPackByIdAsync(idUserLessonPack);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpGet("user-lesson-packs/by-user/{idUser:guid}")]
        public async Task<IActionResult> GetUserLessonPacksByUser(Guid idUser)
        {
            return Ok(await _service.GetUserLessonPacksByUserIdAsync(idUser));
        }

        [HttpPost("user-lesson-packs")]
        public async Task<IActionResult> CreateUserLessonPack([FromBody] UserLessonPack userLessonPack)
        {
            var id = await _service.InsertUserLessonPackAsync(userLessonPack);
            userLessonPack.IdUserLessonPack = id;
            return CreatedAtAction(nameof(GetUserLessonPack), new { idUserLessonPack = id }, userLessonPack);
        }

        [HttpPut("user-lesson-packs/{idUserLessonPack:guid}")]
        public async Task<IActionResult> UpdateUserLessonPack(Guid idUserLessonPack, [FromBody] UserLessonPack userLessonPack)
        {
            if (idUserLessonPack != userLessonPack.IdUserLessonPack) return BadRequest();
            var rows = await _service.UpdateUserLessonPackAsync(userLessonPack);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("user-lesson-packs/{idUserLessonPack:guid}")]
        public async Task<IActionResult> DeleteUserLessonPack(Guid idUserLessonPack)
        {
            var rows = await _service.DeleteUserLessonPackAsync(idUserLessonPack);
            return rows == 0 ? NotFound() : NoContent();
        }

        // PACK TRANSACTIONS
        [HttpGet("pack-transactions")]
        public async Task<IActionResult> GetPackTransactions()
        {
            return Ok(await _service.GetPackTransactionsAllAsync());
        }

        [HttpGet("pack-transactions/{idPackTransaction:guid}")]
        public async Task<IActionResult> GetPackTransaction(Guid idPackTransaction)
        {
            var item = await _service.GetPackTransactionByIdAsync(idPackTransaction);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpGet("pack-transactions/by-user-lesson-pack/{idUserLessonPack:guid}")]
        public async Task<IActionResult> GetPackTransactionsByUserLessonPack(Guid idUserLessonPack)
        {
            return Ok(await _service.GetPackTransactionsByUserLessonPackIdAsync(idUserLessonPack));
        }

        [HttpPost("pack-transactions")]
        public async Task<IActionResult> CreatePackTransaction([FromBody] PackTransaction packTransaction)
        {
            var id = await _service.InsertPackTransactionAsync(packTransaction);
            packTransaction.IdPackTransaction = id;
            return CreatedAtAction(nameof(GetPackTransaction), new { idPackTransaction = id }, packTransaction);
        }

        [HttpDelete("pack-transactions/{idPackTransaction:guid}")]
        public async Task<IActionResult> DeletePackTransaction(Guid idPackTransaction)
        {
            var rows = await _service.DeletePackTransactionAsync(idPackTransaction);
            return rows == 0 ? NotFound() : NoContent();
        }
    }
}
