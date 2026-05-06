namespace AlzheimerApp.Application.Interfaces.Services;

public interface IUserService
{
    Task UpdateFcmTokenAsync(Guid userId, string token);
}