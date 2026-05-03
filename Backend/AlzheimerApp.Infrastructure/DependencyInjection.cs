using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Infrastructure.Persistence;
using AlzheimerApp.Infrastructure.Repositories;
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

        return services;
    }
}