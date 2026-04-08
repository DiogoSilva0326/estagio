using Synget_R2.Integrator.Configuration;
using Synget_R2.Integrator.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

builder.Configuration.AddDotEnvIfPresent(Path.Combine(builder.Environment.ContentRootPath, ".env"));

builder.Services.AddSyngetR2Integrator(builder.Configuration);
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapControllers();

app.Run();
