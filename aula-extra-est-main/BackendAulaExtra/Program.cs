using System;
using System.IO;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Integrations.CloudflareImages;
using ConfidantPostgreSQL.Integrations.Email;
using ConfidantPostgreSQL.Integrations.AgoraLessons;

using ConfidantPostgreSQL.Modules.AgoraAPI.Repository;
using ConfidantPostgreSQL.Modules.AgoraAPI.Service;
using ConfidantPostgreSQL.Modules.Communication.Repository;
using ConfidantPostgreSQL.Modules.Communication.Service;
using ConfidantPostgreSQL.Modules.Complaints.Repository;
using ConfidantPostgreSQL.Modules.Complaints.Service;
using ConfidantPostgreSQL.Modules.ContactsForm.Repository;
using ConfidantPostgreSQL.Modules.ContactsForm.Service;
using ConfidantPostgreSQL.Modules.Courses.Repository;
using ConfidantPostgreSQL.Modules.Courses.Service;
using ConfidantPostgreSQL.Modules.Education.Repository;
using ConfidantPostgreSQL.Modules.Education.Service;
using ConfidantPostgreSQL.Modules.Faq.Repository;
using ConfidantPostgreSQL.Modules.Faq.Service;
using ConfidantPostgreSQL.Modules.Favorites.Repository;
using ConfidantPostgreSQL.Modules.Favorites.Service;
using ConfidantPostgreSQL.Modules.Lessons.Repository;
using ConfidantPostgreSQL.Modules.Lessons.Service;
using ConfidantPostgreSQL.Modules.Payments.Repository;
using ConfidantPostgreSQL.Modules.Payments.Service;
using ConfidantPostgreSQL.Modules.ProfessorAds.Repository;
using ConfidantPostgreSQL.Modules.ProfessorAds.Service;
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
builder.Services.AddScoped<IContactsFormRepository>(_ => new ContactsFormRepository(connString));
builder.Services.AddScoped<ICoursesRepository>(_ => new CoursesRepository(connString));
builder.Services.AddScoped<IEducationRepository>(_ => new EducationRepository(connString));
builder.Services.AddScoped<IFaqRepository>(_ => new FaqRepository(connString));
builder.Services.AddScoped<IFavoritesRepository>(_ => new FavoritesRepository(connString));
builder.Services.AddScoped<ILessonsRepository>(_ => new LessonsRepository(connString));
builder.Services.AddScoped<IPaymentsRepository>(_ => new PaymentsRepository(connString));
builder.Services.AddScoped<IProfessorAdsRepository>(_ => new ProfessorAdsRepository(connString));
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
builder.Services.AddScoped<IContactsFormService, ContactsFormService>();
builder.Services.AddScoped<ICoursesService, CoursesService>();
builder.Services.AddScoped<IEducationService, EducationService>();
builder.Services.AddScoped<IFaqService, FaqService>();
builder.Services.AddScoped<IFavoritesService, FavoritesService>();
builder.Services.AddScoped<ILessonsService, LessonsService>();
builder.Services.AddScoped<IPaymentsService, PaymentsService>();
builder.Services.AddScoped<IProfessorAdsService, ProfessorAdsService>();
builder.Services.AddScoped<IProfessorsService, ProfessorsService>();
builder.Services.AddScoped<IReservationsService, ReservationsService>();
builder.Services.AddScoped<IScheduleService, ScheduleService>();

// Integrations
builder.Services.AddSingleton<IPostmarkService>(_ => PostmarkService.FromEnvironment());
builder.Services.AddScoped<IEmailTemplateService, EmailTemplateService>();

builder.Services.Configure<CloudflareImagesOptions>(options =>
{
    builder.Configuration.GetSection("CloudflareImages").Bind(options);

    options.AccountId ??= Environment.GetEnvironmentVariable("CLOUDFLARE_IMAGES_ACCOUNT_ID");
    options.ApiToken ??= Environment.GetEnvironmentVariable("CLOUDFLARE_IMAGES_API_TOKEN");
    options.DeliveryBase ??= Environment.GetEnvironmentVariable("CLOUDFLARE_IMAGES_DELIVERY_BASE");

    var defaultVariant = Environment.GetEnvironmentVariable("CLOUDFLARE_IMAGES_DEFAULT_VARIANT");
    if (!string.IsNullOrWhiteSpace(defaultVariant))
    {
        options.DefaultVariant = defaultVariant;
    }
});
builder.Services.AddHttpClient<ICloudflareImagesClient, CloudflareImagesClient>();

var agoraIntegratorBaseUrl = Environment.GetEnvironmentVariable("AGORA_INTEGRATOR_BASE_URL");
if (string.IsNullOrWhiteSpace(agoraIntegratorBaseUrl))
{
    agoraIntegratorBaseUrl = builder.Environment.IsDevelopment()
        ? "http://localhost:5050"
        : "https://aulaextra-agora.synget.ovh";
}

var agoraLessonOptions = new AgoraLessonOptions
{
    BaseUrl = agoraIntegratorBaseUrl,
    AgoraAppId = Environment.GetEnvironmentVariable("AGORA_APP_ID")
        ?? Environment.GetEnvironmentVariable("AGORA_APPID")
        ?? string.Empty,
    WhiteboardAppIdentifier = Environment.GetEnvironmentVariable("WHITEBOARD_APP_IDENTIFIER") ?? string.Empty,
    WhiteboardRegion = Environment.GetEnvironmentVariable("WHITEBOARD_REGION") ?? "us-sv",
};
builder.Services.AddSingleton(agoraLessonOptions);
builder.Services.AddHttpClient<IAgoraLessonIntegratorClient, AgoraLessonIntegratorClient>();

var app = builder.Build();
var uploadsRoot = Path.Combine(app.Environment.ContentRootPath, "uploads");
Directory.CreateDirectory(uploadsRoot);

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
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadsRoot),
    RequestPath = "/uploads"
});
app.MapControllers();
app.Run();