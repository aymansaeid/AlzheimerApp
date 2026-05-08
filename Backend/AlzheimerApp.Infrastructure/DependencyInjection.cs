using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Infrastructure.Persistence;
using AlzheimerApp.Infrastructure.Repositories;
using AlzheimerApp.Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace AlzheimerApp.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
  
        var connectionString = configuration.GetConnectionString("DefaultConnection");

        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseNpgsql(connectionString));

        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<ILocationLogRepository, LocationLogRepository>();
        services.AddScoped<ISafeZoneRepository, SafeZoneRepository>();
        services.AddScoped<IPatientFollowerRepository, PatientFollowerRepository>();
        services.AddScoped<IAlertHistoryRepository, AlertHistoryRepository>();
        services.AddScoped<INotificationService, FirebaseNotificationService>();
        services.AddScoped<IMedicineRepository, MedicineRepository>();
        services.AddScoped<IMemoryContentRepository, MemoryContentRepository>();
        services.AddScoped<IMedicineLogRepository, MedicineLogRepository>();
        services.AddScoped<IPatientInviteRepository, PatientInviteRepository>();

        return services;
    }
}