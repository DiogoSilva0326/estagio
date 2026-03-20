using System;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Integrations.CloudflareImages;
using ConfidantPostgreSQL.Integrations.Email;

using ConfidantPostgreSQL.Modules.AgoraAPI.Repository;
using ConfidantPostgreSQL.Modules.AgoraAPI.Service;
using ConfidantPostgreSQL.Modules.Communication.Repository;
using ConfidantPostgreSQL.Modules.Communication.Service;
using ConfidantPostgreSQL.Modules.Complaints.Repository;
using ConfidantPostgreSQL.Modules.Complaints.Service;
using ConfidantPostgreSQL.Modules.Courses.Repository;
using ConfidantPostgreSQL.Modules.Courses.Service;
using ConfidantPostgreSQL.Modules.Education.Repository;
using ConfidantPostgreSQL.Modules.Education.Service;
using ConfidantPostgreSQL.Modules.Favorites.Repository;
using ConfidantPostgreSQL.Modules.Favorites.Service;
using ConfidantPostgreSQL.Modules.Lessons.Repository;
using ConfidantPostgreSQL.Modules.Lessons.Service;
using ConfidantPostgreSQL.Modules.Payments.Repository;
using ConfidantPostgreSQL.Modules.Payments.Service;
using ConfidantPostgreSQL.Modules.Professors.Repository;
using ConfidantPostgreSQL.Modules.Professors.Service;
using ConfidantPostgreSQL.Modules.Reservations.Repository;
using ConfidantPostgreSQL.Modules.Reservations.Service;
using ConfidantPostgreSQL.Modules.Schedule.Repository;
using ConfidantPostgreSQL.Modules.Schedule.Service;
using ConfidantPostgreSQL.Modules.Student.Repository;
using ConfidantPostgreSQL.Modules.Student.Service;
using ConfidantPostgreSQL.Modules.UserProfile.Repository;
using ConfidantPostgreSQL.Modules.UserProfile.Service;
using ConfidantPostgreSQL.Modules.Users.Repository;
using ConfidantPostgreSQL.Modules.Users.Service;
using ConfidantPostgreSQL.Modules.Communication.Hubs;

var builder = WebApplication.CreateBuilder(args);

var connString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING");
if (string.IsNullOrWhiteSpace(connString))
{
    // Dev-friendly defaults (keeps docker-compose env working as-is).
    var dbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
    var dbPort = Environment.GetEnvironmentVariable("DB_PORT") ?? "5432";
    var dbUser = Environment.GetEnvironmentVariable("DB_USER") ?? "confidants_user";
    var dbPass = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "YourStrong@Passw0rd";
    var dbName = Environment.GetEnvironmentVariable("DB_NAME") ?? "ConfidantsDB";
    connString = $"Host={dbHost};Port={dbPort};Username={dbUser};Password={dbPass};Database={dbName}";
}

builder.Services.AddCors(options =>
{
    options.AddPolicy("corsapp", policy =>
    {
        policy.SetIsOriginAllowed(_ => true)
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials();
    });
});

builder.Services.AddScoped<JwtFilter>();
builder.Services.AddSignalR();
builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
});

// Repositories
builder.Services.AddScoped<IUserRepository>(_ => new UserRepository(connString));
builder.Services.AddScoped<IMyTutorsRepository>(_ => new MyTutorsRepository(connString));
builder.Services.AddScoped<IStudentEvaluationsRepository>(_ => new StudentEvaluationsRepository(connString));
builder.Services.AddScoped<IStudentProfessorEvaluationsRepository>(_ => new StudentProfessorEvaluationsRepository(connString));
builder.Services.AddScoped<IUserProfileRepository>(sp => new UserProfileRepository(connString, sp.GetService<ILogger<UserProfileRepository>>()));
builder.Services.AddScoped<IAgoraRepository>(_ => new AgoraRepository(connString));
builder.Services.AddScoped<ICommunicationRepository>(_ => new CommunicationRepository(connString));
builder.Services.AddScoped<IComplaintsRepository>(_ => new ComplaintsRepository(connString));
builder.Services.AddScoped<ICoursesRepository>(_ => new CoursesRepository(connString));
builder.Services.AddScoped<IEducationRepository>(_ => new EducationRepository(connString));
builder.Services.AddScoped<IFavoritesRepository>(_ => new FavoritesRepository(connString));
builder.Services.AddScoped<ILessonsRepository>(_ => new LessonsRepository(connString));
builder.Services.AddScoped<IPaymentsRepository>(_ => new PaymentsRepository(connString));
builder.Services.AddScoped<IProfessorsRepository>(_ => new ProfessorsRepository(connString));
builder.Services.AddScoped<IReservationsRepository>(_ => new ReservationsRepository(connString));
builder.Services.AddScoped<IScheduleRepository>(_ => new ScheduleRepository(connString));

// Services
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IMyTutorsService, MyTutorsService>();
builder.Services.AddScoped<IStudentEvaluationsService, StudentEvaluationsService>();
builder.Services.AddScoped<IStudentProfessorEvaluationsService, StudentProfessorEvaluationsService>();
builder.Services.AddScoped<IUserProfileService, UserProfileService>();
builder.Services.AddScoped<IAgoraService, AgoraService>();
builder.Services.AddScoped<ICommunicationService, CommunicationService>();
builder.Services.AddScoped<IComplaintsService, ComplaintsService>();
builder.Services.AddScoped<ICoursesService, CoursesService>();
builder.Services.AddScoped<IEducationService, EducationService>();
builder.Services.AddScoped<IFavoritesService, FavoritesService>();
builder.Services.AddScoped<ILessonsService, LessonsService>();
builder.Services.AddScoped<IPaymentsService, PaymentsService>();
builder.Services.AddScoped<IProfessorsService, ProfessorsService>();
builder.Services.AddScoped<IReservationsService, ReservationsService>();
builder.Services.AddScoped<IScheduleService, ScheduleService>();

// Integrations
builder.Services.AddSingleton<IPostmarkService>(_ => PostmarkService.FromEnvironment());
builder.Services.AddScoped<IEmailTemplateService, EmailTemplateService>();

builder.Services.Configure<CloudflareImagesOptions>(builder.Configuration.GetSection("CloudflareImages"));
builder.Services.AddHttpClient<ICloudflareImagesClient, CloudflareImagesClient>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}
else
{
    app.Use(async (context, next) =>
    {
        try
        {
            await next();
        }
        catch (Exception ex)
        {
            if (context.Response.HasStarted) throw;

            context.Response.ContentType = "application/json";
            context.Response.StatusCode = ex switch
            {
                CloudflareImagesNotConfiguredException => StatusCodes.Status503ServiceUnavailable,
                _ => StatusCodes.Status500InternalServerError
            };

            await context.Response.WriteAsJsonAsync(new
            {
                error = ex.Message,
                traceId = context.TraceIdentifier
            });
        }
    });
}

app.UseRouting();
app.UseCors("corsapp");
app.MapControllers();
app.MapHub<ChatHub>("/chathub");
app.Run();