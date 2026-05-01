using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IAuthService
{
    Task<User> RegisterAsync(RegisterDto dto);
    Task<User> LoginAsync(LoginDto dto);
}