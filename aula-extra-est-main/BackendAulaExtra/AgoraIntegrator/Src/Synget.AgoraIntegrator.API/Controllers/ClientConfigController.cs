using Microsoft.AspNetCore.Mvc;

namespace Synget.AgoraIntegrator.API.Controllers;

[ApiController]
[Route("api/client-config")]
public class ClientConfigController : ControllerBase
{
    private readonly IConfiguration _configuration;

    public ClientConfigController(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    [HttpGet]
    public IActionResult Get()
    {
        var agoraAppId = _configuration["Agora:AppId"] ?? string.Empty;
        var whiteboardAppIdentifier = _configuration["Whiteboard:AppIdentifier"] ?? string.Empty;
        var whiteboardRegion = _configuration["Whiteboard:Region"] ?? "us-sv";

        return Ok(new
        {
            agoraAppId,
            whiteboardAppIdentifier,
            whiteboardRegion,
        });
    }
}