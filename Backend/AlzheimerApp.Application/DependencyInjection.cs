using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace AlzheimerApp.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<ILocationService, LocationService>();
        services.AddScoped<ISafeZoneService, SafeZoneService>();
        services.AddScoped<IPatientFollowerService, PatientFollowerService>();
        services.AddScoped<IMedicineService, MedicineService>();
        services.AddScoped<IMemoryContentService, MemoryContentService>();
        services.AddScoped<IUserService, UserService>();
        services.AddScoped<IAlertService, AlertService>();
        services.AddScoped<IMedicineLogService, MedicineLogService>();
        services.AddScoped<IPatientService, PatientService>();
        services.AddSingleton(TimeProvider.System);

        return services;
    }
}