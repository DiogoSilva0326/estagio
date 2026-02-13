using System.Net.Mime;
using DotNetEnv;
using AgoraBackend.agoraAPI.Models;
using AgoraBackend.agoraAPI.Services;
using AgoraBackend.agoraAPI.Repository;
using AgoraBackend.agoraAPI.Controllers;

// Load environment configuration
try
{
	var cwdEnv = Path.Combine(Directory.GetCurrentDirectory(), ".env");
	if (File.Exists(cwdEnv)) Env.Load(cwdEnv);
	else Env.Load();
}
catch
{
	// If no .env, continue with system environment variables
}

var builder = WebApplication.CreateBuilder(args);

// Register CORS policy
builder.Services.AddCors(options =>
{
	options.AddPolicy("AllowAll", policy =>
		policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

// Register HTTP client factory for Netless API and Agora Chat
builder.Services.AddHttpClient("netless");
builder.Services.AddHttpClient();

// Register application configuration (loads from environment)
builder.Services.AddSingleton<AppConfig>(sp =>
{
	var agoraAppId = Environment.GetEnvironmentVariable("AGORA_APP_ID") ?? "";
	var agoraAppCertificate = Environment.GetEnvironmentVariable("AGORA_APP_CERTIFICATE") ?? "";
	var netlessSdkToken = Environment.GetEnvironmentVariable("NETLESS_SDK_TOKEN") ?? "";
	var netlessRegion = Environment.GetEnvironmentVariable("NETLESS_REGION") ?? "us-sv";
	var agoraChatAppKey = Environment.GetEnvironmentVariable("AGORA_CHAT_APP_KEY") ?? "";
	var agoraChatClientId = Environment.GetEnvironmentVariable("AGORA_CHAT_CLIENT_ID") ?? "";
	var agoraChatClientSecret = Environment.GetEnvironmentVariable("AGORA_CHAT_CLIENT_SECRET") ?? "";

	if (string.IsNullOrWhiteSpace(agoraAppId))
		throw new InvalidOperationException("missing AGORA_APP_ID");
	if (string.IsNullOrWhiteSpace(agoraAppCertificate))
		throw new InvalidOperationException("missing AGORA_APP_CERTIFICATE");
	if (string.IsNullOrWhiteSpace(netlessSdkToken))
		throw new InvalidOperationException("missing NETLESS_SDK_TOKEN");

	return new AppConfig(
		agoraAppId, 
		agoraAppCertificate, 
		netlessSdkToken, 
		netlessRegion,
		agoraChatAppKey,
		agoraChatClientId,
		agoraChatClientSecret);
});

// Register Agora Chat REST client if credentials are configured
builder.Services.AddSingleton<IAgoraChatRestClient?>(sp =>
{
	var config = sp.GetRequiredService<AppConfig>();
	if (!string.IsNullOrWhiteSpace(config.AgoraChatAppKey) &&
	    !string.IsNullOrWhiteSpace(config.AgoraChatClientId) &&
	    !string.IsNullOrWhiteSpace(config.AgoraChatClientSecret))
	{
		var logger = sp.GetRequiredService<ILogger<AgoraChatRestClient>>();
		return new AgoraChatRestClient(sp.GetRequiredService<IHttpClientFactory>(), config, logger);
	}
	return null;
});

// Register services with dependency injection
builder.Services.AddSingleton<IRtcTokenService, RtcTokenService>();
builder.Services.AddSingleton<IWhiteboardRoomRepository, WhiteboardRoomRepository>();
builder.Services.AddSingleton<IWhiteboardService, WhiteboardService>();
builder.Services.AddSingleton<IRtmTokenService, RtmTokenService>();
builder.Services.AddSingleton<IAgoraChatService, AgoraChatService>();
builder.Services.AddSingleton<ISessionStorageService, SessionStorageService>();

// Add controllers
builder.Services.AddControllers();

var app = builder.Build();

app.UseCors("AllowAll");

// Ensure wwwroot/uploads exists and serve static files
try
{
	var wwwroot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
	var uploads = Path.Combine(wwwroot, "uploads");
	if (!Directory.Exists(uploads)) Directory.CreateDirectory(uploads);
}
catch
{
	// ignore directory setup issues; upload endpoint will try creating as needed
}

app.UseStaticFiles();

// Default health check endpoint
app.MapGet("/", () => Results.Text("AgoraBackend OK", MediaTypeNames.Text.Plain));

// Map controller routes
app.MapControllers();

// Configure port (default: 8082 for compatibility with Go server)
var port = Environment.GetEnvironmentVariable("PORT");
if (int.TryParse(port, out var portNumber) && portNumber > 0)
{
	app.Urls.Add($"http://localhost:{portNumber}");
}
else
{
	app.Urls.Add("http://localhost:8082");
}

app.Run();
