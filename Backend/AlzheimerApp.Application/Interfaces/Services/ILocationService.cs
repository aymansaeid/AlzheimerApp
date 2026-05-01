using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface ILocationService
{
    Task<LocationLog> LogLocationAsync(LocationDto dto);
}