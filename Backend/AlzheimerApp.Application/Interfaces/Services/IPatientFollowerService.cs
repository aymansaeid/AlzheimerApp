using AlzheimerApp.Application.DTOs.Followers;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IPatientFollowerService
{
    Task<FollowerResponse> AddFollowerAsync(FollowerRequest request);
}