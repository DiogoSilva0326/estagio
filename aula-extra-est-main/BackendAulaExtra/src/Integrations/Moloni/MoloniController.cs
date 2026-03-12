using System;
using System.Collections.Generic;
using System.Linq;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Integrations.Moloni;
using Microsoft.AspNetCore.Mvc;
using Synget.ERPIntegrator.Models;

namespace ConfidantPostgreSQL.Integrations.Moloni
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class MoloniController : ControllerBase
    {
        private readonly IMoloniService _moloni;
        private readonly ILogger<MoloniController>? _logger;

        public MoloniController(IMoloniService moloni, ILogger<MoloniController>? logger = null)
        {
            _moloni = moloni;
            _logger = logger;
        }

        /// <summary>
        /// Lista todos os produtos do Moloni (ID, Reference, Category, Name, Price, Stock).
        /// Requer autenticação JWT.
        /// </summary>
        [HttpGet("Products")]
        public ActionResult GetProducts(
            [FromHeader(Name = "Authorization")] string? authorization,
            [FromHeader] string? token,
            [FromQuery] bool onlyWithStock = false)
        {
            if (!_moloni.IsEnabled)
                return StatusCode(503, new { error = "moloni_not_configured", message = _moloni.LastMessage ?? "Moloni não está configurado." });

            var products = _moloni.GetProducts(onlyWithStock);
            var list = new List<object>();
            foreach (var p in products)
            {
                list.Add(new
                {
                    id = p.ID,
                    reference = p.Reference ?? "",
                    categoryName = p.CategoryName ?? "",
                    name = p.Name ?? "",
                    price = p.Price,
                    stockTotal = p.StockTotal,
                });
            }
            return Ok(new { products = list });
        }
    }
}

