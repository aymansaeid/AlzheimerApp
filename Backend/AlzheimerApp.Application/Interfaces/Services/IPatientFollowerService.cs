using AlzheimerApp.Application.DTOs.Followers;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IPatientFollowerService
{
    Task<FollowerResponse> AddFollowerAsync(FollowerRequest request);
    Task<InviteResponse> GenerateInviteAsync(GenerateInviteRequest request);
    Task<FollowerResponse> AcceptInviteAsync(Guid newFollowerId, AcceptInviteRequest request);
}