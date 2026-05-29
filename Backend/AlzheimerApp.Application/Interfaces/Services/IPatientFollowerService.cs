using AlzheimerApp.Application.DTOs.Followers;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IPatientFollowerService
{
    Task<FollowerResponse> AddFollowerAsync(FollowerRequest request);
    Task<InviteResponse> GenerateInviteAsync(Guid requesterId, GenerateInviteRequest request);
    Task<FollowerResponse> AcceptInviteAsync(Guid newFollowerId, AcceptInviteRequest request);
    Task TransferAdminRightsAsync(Guid patientId, Guid currentAdminId, Guid newAdminId);
    Task<bool> CheckHasAdminAsync(Guid patientId);
    Task<FollowerDashboardResponse> GetDashboardDataAsync(Guid patientId);
    Task<List<CareTeamMemberResponse>> GetCareTeamAsync(Guid patientId);
    Task RemoveFollowerAsync(Guid patientId, Guid adminId, Guid followerId);
    Task LeavePatientAsync(Guid patientId, Guid followerId);
}