using AlzheimerApp.Application.DTOs.Locations;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface ILocationService
{
    Task<LocationLog> LogLocationAsync(LocationRequest dto);
}