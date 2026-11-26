using AlzheimerApp.Application.DTOs.Followers;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IPatientFollowerService
{
    Task<FollowerResponse> AddFollowerAsync(FollowerRequest request);

    /// <exception cref="UnauthorizedAccessException">A first (primary) invite requested by someone other than the patient.</exception>
    Task<InviteResponse> GenerateInviteAsync(Guid requesterId, GenerateInviteRequest request, bool isSystemAdmin = false);
    Task<FollowerResponse> AcceptInviteAsync(Guid newFollowerId, AcceptInviteRequest request);
    Task TransferAdminRightsAsync(Guid patientId, Guid currentAdminId, Guid newAdminId);
    Task<bool> CheckHasAdminAsync(Guid patientId);
    Task<FollowerDashboardResponse> GetDashboardDataAsync(Guid patientId, Guid followerId);
    Task<List<CareTeamMemberResponse>> GetCareTeamAsync(Guid patientId);
    Task RemoveFollowerAsync(Guid patientId, Guid adminId, Guid followerId);
    Task LeavePatientAsync(Guid patientId, Guid followerId);
    Task<List<TrackedPatientResponse>> GetTrackedPatientsAsync(Guid followerId);
}