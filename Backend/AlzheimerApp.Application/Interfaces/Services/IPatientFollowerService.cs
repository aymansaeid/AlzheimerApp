using AlzheimerApp.Application.DTOs.Followers;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IPatientFollowerService
{
    Task<FollowerResponse> AddFollowerAsync(FollowerRequest request);
    Task<InviteResponse> GenerateInviteAsync(GenerateInviteRequest request);
    Task<FollowerResponse> AcceptInviteAsync(Guid newFollowerId, AcceptInviteRequest request);
    Task TransferAdminRightsAsync(Guid patientId, Guid currentAdminId, Guid newAdminId);
    Task<bool> CheckHasAdminAsync(Guid patientId); 
}