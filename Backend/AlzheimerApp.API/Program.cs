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
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;

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
builder.Services.AddSingleton<WorkerHeartbeat>();
builder.Services.AddHostedService<MedicineDailyGeneratorWorker>();
builder.Services.AddHostedService<MedicineAlarmWorker>();
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
    // SignalR: WebSocket/SSE clients cannot send an Authorization header, so they pass the JWT
    // as ?access_token=... . Accept it ONLY for hub endpoints; REST endpoints still require the header.
    options.Events = new JwtBearerEvents
    {
        OnMessageReceived = context =>
        {
            var accessToken = context.Request.Query["access_token"];
            if (!string.IsNullOrEmpty(accessToken) && context.HttpContext.Request.Path.StartsWithSegments("/hubs"))
            {
                context.Token = accessToken;
            }
            return Task.CompletedTask;
        }

    };
});

// FIREBASE INITIALIZATION 
var firebaseConfig = builder.Configuration.GetSection("FirebaseSettings");

var firebaseCredentials = new Dictionary<string, string>
{
    { "type", firebaseConfig["Type"] ?? throw new ArgumentNullException("Firebase: Type is missing") },
    { "project_id", firebaseConfig["ProjectId"] ?? throw new ArgumentNullException("Firebase: ProjectId is missing") },
    { "private_key_id", firebaseConfig["PrivateKeyId"] ?? "" },

    { "private_key", (firebaseConfig["PrivateKey"] ?? throw new ArgumentNullException("Firebase: PrivateKey is missing")).Replace("\\n", "\n") },

    { "client_email", firebaseConfig["ClientEmail"] ?? "" },
    { "client_id", firebaseConfig["ClientId"] ?? "" }
};

FirebaseApp.Create(new AppOptions
{
    Credential = GoogleCredential.FromJson(System.Text.Json.JsonSerializer.Serialize(firebaseCredentials))
});

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "AlzheimerApp API v1");
    options.RoutePrefix = "swagger";
});

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<LocationHub>("/hubs/location");
// Lightweight liveness check (also handy for an uptime pinger so background workers keep running).
app.MapGet("/health", (WorkerHeartbeat heartbeat) => Results.Ok(new
{
    status = "ok",
    utc = DateTime.UtcNow,
    // If this keeps moving forward, the host restarts/sleeps the app and background workers stop meanwhile.
    processStartedAt = heartbeat.ProcessStartedAtUtc,
    workers = heartbeat.Snapshot()
}));

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<AlzheimerApp.Infrastructure.Persistence.ApplicationDbContext>();
        await Microsoft.EntityFrameworkCore.RelationalDatabaseFacadeExtensions.MigrateAsync(context.Database);
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while migrating the PostgreSQL database.");
    }
}

app.Run();