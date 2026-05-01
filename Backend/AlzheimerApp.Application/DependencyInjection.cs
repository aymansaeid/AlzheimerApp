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

        return services;
    }
}