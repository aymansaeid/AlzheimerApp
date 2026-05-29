using AlzheimerApp.API.Hubs; 
using AlzheimerApp.Application;
using AlzheimerApp.Infrastructure;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using System.Text;
using AlzheimerApp.API.BackgroundJobs;
using System.Reflection;
using System.IO;

var builder = WebApplication.CreateBuilder(args);

var rawConnectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (!string.IsNullOrEmpty(rawConnectionString) && rawConnectionString.StartsWith("postgres"))
{
    var databaseUri = new Uri(rawConnectionString);
    var userInfo = databaseUri.UserInfo.Split(':');

    rawConnectionString = $"Host={databaseUri.Host};Port={databaseUri.Port};Database={databaseUri.AbsolutePath.TrimStart('/')};Username={userInfo[0]};Password={userInfo[1]};SSL Mode=Require;Trust Server Certificate=True;";

    builder.Configuration["ConnectionStrings:DefaultConnection"] = rawConnectionString;
}

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSignalR();


builder.Services.AddSwaggerGen(options =>
{
    const string schemeId = "bearer";

    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "AlzheimerApp API",
        Version = "v1",
        Description = "The central backend for the Alzheimer's Tracking & Caregiver Application. \n\n" +
                      "**Frontend Developer Guide:**\n" +
                      "- Ensure you attach the `Bearer Token` to all secured requests.\n" +
                      "- All Dates are in UTC ISO 8601 format.\n" +
                      "- See schemas below for required JSON payloads.",
        Contact = new OpenApiContact
        {
            Name = "Backend Architecture Team",
            Email = "aemon.saeid@gmail.com"
        }
    });

    options.AddSecurityDefinition(schemeId, new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Paste only the JWT token"
    });

    options.AddSecurityRequirement(document => new OpenApiSecurityRequirement
    {
        [new OpenApiSecuritySchemeReference(schemeId, document)] = []
    });
    var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    options.IncludeXmlComments(xmlPath);
});


builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration);

builder.Services.AddHostedService<MedicineStatusSweeperWorker>();

var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = Encoding.UTF8.GetBytes(jwtSettings["Secret"]!);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(secretKey)
    };
});

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "AlzheimerApp API v1");
    options.RoutePrefix = "swagger"; // Serves Swagger at /swagger
});

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.MapHub<LocationHub>("/hubs/location");

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<AlzheimerApp.Infrastructure.Persistence.ApplicationDbContext>();
        // This automatically executes 'dotnet ef database update' on the cloud server upon boot
        await Microsoft.EntityFrameworkCore.RelationalDatabaseFacadeExtensions.MigrateAsync(context.Database);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while migrating the PostgreSQL database.");
    }
}

app.Run();