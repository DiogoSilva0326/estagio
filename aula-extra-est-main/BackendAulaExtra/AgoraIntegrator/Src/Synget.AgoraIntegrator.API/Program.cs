using Synget.AgoraIntegrator;
using Synget.AgoraIntegrator.Models;
using Synget.AgoraIntegrator.API.Hubs;
using Synget.ChatIntegrator;
using Microsoft.EntityFrameworkCore;
using Synget.AgoraIntegrator.API.Data;
using Synget.AgoraIntegrator.API.Data.Repositories;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new() { Title = "Synget.AgoraIntegrator.API", Version = "v1" });
});

// Add SignalR for real-time chat
builder.Services.AddSignalR();

// Configure PostgreSQL Database (Chat persistence)
var dbHost = builder.Configuration["DB_HOST"] ?? Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
var dbPort = builder.Configuration["DB_PORT"] ?? Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";
var dbUser = builder.Configuration["DB_USER"] ?? Environment.GetEnvironmentVariable("DB_USER") ?? "postgres";
var dbPassword = builder.Configuration["DB_PASSWORD"] ?? Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "postgres";
var dbName = builder.Configuration["DB_NAME"] ?? Environment.GetEnvironmentVariable("DB_NAME") ?? "confidant";

var connectionString = $"Host={dbHost};Port={dbPort};Database={dbName};Username={dbUser};Password={dbPassword}";
builder.Services.AddDbContext<ChatDbContext>(options =>
    options.UseNpgsql(connectionString));

// Register repositories
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IMessageRepository, MessageRepository>();
builder.Services.AddScoped<IContactRepository, ContactRepository>();
builder.Services.AddScoped<IGroupRoomRepository, GroupRoomRepository>();
builder.Services.AddScoped<IVideoCallRepository, VideoCallRepository>();
builder.Services.AddScoped<ISessionRepository, SessionRepository>();
builder.Services.AddScoped<IVideoRoomRepository, VideoRoomRepository>();
builder.Services.AddScoped<IProfessorRoomRepository, ProfessorRoomRepository>();
builder.Services.AddScoped<IChatFileRepository, ChatFileRepository>();

// Configure Agora settings from configuration
var agoraConfig = new AgoraConfig
{
    Platform = AgoraPlatform.RTC,
    AppId = builder.Configuration["Agora:AppId"] ?? "",
    AppCertificate = builder.Configuration["Agora:AppCertificate"] ?? "",
    TokenExpirationSeconds = int.TryParse(builder.Configuration["Agora:TokenExpirationSeconds"], out var exp) ? exp : 3600,
    // Whiteboard/Netless settings
    WhiteboardSdkToken = builder.Configuration["Whiteboard:NetlessSdkToken"] ?? "",
    WhiteboardAppIdentifier = builder.Configuration["Whiteboard:AppIdentifier"] ?? "",
    WhiteboardRegion = builder.Configuration["Whiteboard:Region"] ?? "us-sv"
};

// Create and initialize Agora platform
var agoraPlatformManager = new AgoraPlatformManager();
agoraPlatformManager.Initialize(agoraConfig);

// Register IAgora as singleton
builder.Services.AddSingleton<IAgora>(agoraPlatformManager.Agora!);

// Create and register Chat service
var chatService = new ChatService();
chatService.Initialize(new ChatConfig
{
    MaxMessagesPerRoom = 1000,
    MessageRetentionHours = 24
});
builder.Services.AddSingleton<IChat>(chatService);

// Add CORS for Flutter web app (with SignalR support)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(_ => true)  // Allow any origin for SignalR
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();  // Required for SignalR
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");

// Ensure uploads folder exists
var uploadsPath = Path.Combine(app.Environment.ContentRootPath, "uploads");
if (!Directory.Exists(uploadsPath))
{
    Directory.CreateDirectory(uploadsPath);
    Console.WriteLine($"Created uploads folder: {uploadsPath}");
}

app.UseStaticFiles(); // Enable static file serving

app.MapControllers();

// Map SignalR Chat Hub
app.MapHub<ChatHub>("/chathub");

app.Run();
