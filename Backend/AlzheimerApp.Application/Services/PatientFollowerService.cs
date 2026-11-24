using AlzheimerApp.Application.DTOs.Alerts;
using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.DTOs.MedicineLogs;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.Services;

public class PatientFollowerService : IPatientFollowerService
{
    private readonly IPatientFollowerRepository _followerRepository;
    private readonly IPatientInviteRepository _inviteRepository;
    private readonly IUserRepository _userRepository;
    private readonly ILocationLogRepository _locationRepository;
    private readonly IAlertHistoryRepository _alertRepository;
    private readonly IMedicineLogService _medicineLogService;

    public PatientFollowerService(
            IPatientFollowerRepository followerRepository,
            IPatientInviteRepository inviteRepository,
            IUserRepository userRepository,
            ILocationLogRepository locationRepository,
            IAlertHistoryRepository alertRepository,
            IMedicineLogService medicineLogService)
    {
        _followerRepository = followerRepository;
        _inviteRepository = inviteRepository;
        _userRepository = userRepository;
        _locationRepository = locationRepository;
        _alertRepository = alertRepository;
        _medicineLogService = medicineLogService;
    }

    public async Task<FollowerResponse> AddFollowerAsync(FollowerRequest request)
    {
        bool exists = await _followerRepository.RelationshipExistsAsync(request.PatientId, request.FollowerId);
        if (exists)
        {
            throw new Exception("This user is already following this patient.");
        }

        var relationship = new PatientFollower
        {
            PatientId = request.PatientId,
            FollowerId = request.FollowerId,
            Relationship = request.Relationship,
            IsPrimary = request.IsPrimary,
            CreatedAt = DateTime.UtcNow
        };

        var savedEntity = await _followerRepository.AddAsync(relationship);

        return new FollowerResponse
        {
            Id = savedEntity.Id,
            PatientId = savedEntity.PatientId,
            FollowerId = savedEntity.FollowerId,
            Relationship = savedEntity.Relationship,
            IsPrimary = savedEntity.IsPrimary,
            CreatedAt = savedEntity.CreatedAt
        };
    }

    public async Task<InviteResponse> GenerateInviteAsync(GenerateInviteRequest request)
    {
        // Generate a clean, 6-character alphanumeric code (e.g., "A7X9WQ")
        string randomCode = Guid.NewGuid().ToString().Substring(0, 6).ToUpper();

        var invite = new PatientInvite
        {
            PatientId = request.PatientId,
            InviteCode = randomCode,
            IsPrimaryInvite = request.IsPrimaryInvite,
            ExpiresAt = DateTime.UtcNow.AddDays(7), // Link expires in 7 days for security
            IsActive = true
        };

        await _inviteRepository.AddAsync(invite);

        return new InviteResponse
        {
            InviteCode = invite.InviteCode,
            // Ekrem will configure the Flutter app to automatically open when a link like this is clicked on the phone
            DeepLinkUrl = $"alzheimerapp://invite?code={invite.InviteCode}",
            ExpiresAt = invite.ExpiresAt
        };
    }

    public async Task<FollowerResponse> AcceptInviteAsync(Guid newFollowerId, AcceptInviteRequest request)
    {
        // 1. Validate the code
        var invite = await _inviteRepository.GetByCodeAsync(request.InviteCode);

        if (invite == null) throw new Exception("Invalid or inactive invite code.");
        if (invite.ExpiresAt < DateTime.UtcNow) throw new Exception("This invite link has expired.");

        // 2. Check if they are already following this patient
        bool exists = await _followerRepository.RelationshipExistsAsync(invite.PatientId, newFollowerId);
        if (exists) throw new Exception("You are already linked to this patient.");

        // 3. Create the relationship using the role from the invite!
        var relationship = new PatientFollower
        {
            PatientId = invite.PatientId,
            FollowerId = newFollowerId,
            Relationship = request.Relationship,
            IsPrimary = invite.IsPrimaryInvite, // 🔥 Here is where the magic happens!
            CreatedAt = DateTime.UtcNow
        };

        var savedEntity = await _followerRepository.AddAsync(relationship);

        // 4. (Optional Security) If it was a Primary invite, burn the code so no one else can become Admin
        if (invite.IsPrimaryInvite)
        {
            invite.IsActive = false;
            await _inviteRepository.UpdateAsync(invite);
        }

        return new FollowerResponse
        {
            Id = savedEntity.Id,
            PatientId = savedEntity.PatientId,
            FollowerId = savedEntity.FollowerId,
            Relationship = savedEntity.Relationship,
            IsPrimary = savedEntity.IsPrimary,
            CreatedAt = savedEntity.CreatedAt
        };
    }
    public async Task TransferAdminRightsAsync(Guid patientId, Guid currentAdminId, Guid newAdminId)
    {
        // 1. Get both relationships
        var currentAdminRel = await _followerRepository.GetRelationshipAsync(patientId, currentAdminId);
        var newAdminRel = await _followerRepository.GetRelationshipAsync(patientId, newAdminId);

        if (currentAdminRel == null || newAdminRel == null)
            throw new Exception("One or both users are not linked to this patient.");

        // 2. Security Check: Ensure the person trying to transfer is actually the primary!
        if (!currentAdminRel.IsPrimary)
            throw new Exception("Only the current Primary Follower can transfer admin rights.");

        // 3. The Swap
        currentAdminRel.IsPrimary = false;
        newAdminRel.IsPrimary = true;

        // 4. Save to Database
        await _followerRepository.UpdateAsync(currentAdminRel);
        await _followerRepository.UpdateAsync(newAdminRel);
    }
    public async Task<bool> CheckHasAdminAsync(Guid patientId)
    {
        return await _followerRepository.HasPrimaryFollowerAsync(patientId);
    }
    public async Task<FollowerDashboardResponse> GetDashboardDataAsync(Guid patientId, Guid followerId)
    {
        // Verify the follower actually has a security clearance to view this patient
        var relationship = await _followerRepository.GetRelationshipAsync(patientId, followerId);
        if (relationship == null)
        {
            throw new Exception("Access Denied. You are not authorized to view this patient's dashboard.");
        }

        var patient = await _userRepository.GetByIdAsync(patientId);
        if (patient == null) throw new Exception("Patient not found.");

        var lastLocation = await _locationRepository.GetLatestLocationAsync(patientId);
        var alerts = await _alertRepository.GetPatientAlertsAsync(patientId);
        var unreadCount = alerts.Count(a => !a.IsRead);
        var latestAlert = alerts.OrderByDescending(a => a.SentAt).FirstOrDefault();
        var todayLogs = await _medicineLogService.GetDailyLogsAsync(patientId, DateTime.UtcNow);

        return new FollowerDashboardResponse
        {
            PatientId = patient.Id,
            PatientName = patient.FullName,
            ProfilePhotoUrl = patient.ProfilePhotoUrl,

            // Pass the specific permissions flag back down
            CurrentUserIsAdmin = relationship.IsPrimary,

            LastLatitude = lastLocation?.Latitude,
            LastLongitude = lastLocation?.Longitude,
            IsCurrentlyOutside = lastLocation?.IsOutsideZone ?? false,
            LastSeenAt = lastLocation?.RecordedAt,
            UnreadAlertCount = unreadCount,
            LatestAlert = latestAlert != null ? new AlertResponse
            {
                Id = latestAlert.Id,
                Message = latestAlert.Message,
                SentAt = latestAlert.SentAt,
                IsRead = latestAlert.IsRead
            } : null,
            TotalMedsToday = todayLogs.Count,
            MedsTakenToday = todayLogs.Count(l => l.Status == MedicineStatus.Taken),
            UpcomingMeds = todayLogs.Where(l => l.Status == MedicineStatus.Pending).ToList()
        };
    }

    // Paste these new/updated methods right into your existing service class:

public async Task<InviteResponse> GenerateInviteAsync(Guid requesterId, GenerateInviteRequest request)
{
    bool hasAdmin = await _followerRepository.HasPrimaryFollowerAsync(request.PatientId);

    if (hasAdmin)
    {
        // 🚨 SECURITY VALIDATION: If the group has an admin, only THAT admin can generate new invites!
        var currentRelationship = await _followerRepository.GetRelationshipAsync(request.PatientId, requesterId);
        if (currentRelationship == null || !currentRelationship.IsPrimary)
        {
            throw new Exception("Unauthorized. Only the Primary Caregiver can invite other family members.");
        }
        
        // Force the invite type to be standard secondary if an admin already occupies the slot
        request.IsPrimaryInvite = false;
    }
    else
    {
        // If there is no admin yet, this is the master genesis invite
        request.IsPrimaryInvite = true;
    }

    // Generate a clean, 6-character alphanumeric code
    string randomCode = Guid.NewGuid().ToString().Substring(0, 6).ToUpper();

    var invite = new PatientInvite
    {
        PatientId = request.PatientId,
        InviteCode = randomCode,
        IsPrimaryInvite = request.IsPrimaryInvite,
        ExpiresAt = DateTime.UtcNow.AddDays(2), // Reduced to 2 days for tight medical security
        IsActive = true
    };

    await _inviteRepository.AddAsync(invite);

    return new InviteResponse
    {
        InviteCode = invite.InviteCode,
        DeepLinkUrl = $"alzheimerapp://invite?code={invite.InviteCode}",
        ExpiresAt = invite.ExpiresAt
    };
}

public async Task<List<CareTeamMemberResponse>> GetCareTeamAsync(Guid patientId)
{
    var relationships = await _followerRepository.GetFollowersByPatientIdAsync(patientId);
    
    return relationships.Select(r => new CareTeamMemberResponse
    {
        FollowerId = r.FollowerId,
        FullName = r.Follower?.FullName ?? "Unknown Member",
        Phone = r.Follower?.Phone ?? "No Phone Linked",
        ProfilePhotoUrl = r.Follower?.ProfilePhotoUrl,
        RelationshipType = r.Relationship,
        IsPrimary = r.IsPrimary,
        JoinedAt = r.CreatedAt
    }).ToList();
}

public async Task RemoveFollowerAsync(Guid patientId, Guid adminId, Guid followerId)
{
    // 1. Verify the person eviction-testing is the group administrator
    var adminRel = await _followerRepository.GetRelationshipAsync(patientId, adminId);
    if (adminRel == null || !adminRel.IsPrimary)
    {
        throw new Exception("Action denied. Only the Primary Caregiver can manage team membership.");
    }

    if (adminId == followerId)
    {
        throw new Exception("You cannot remove yourself as Primary Admin. Transfer ownership first.");
    }

    // 2. Fetch target relation and execute eviction
    var targetRel = await _followerRepository.GetRelationshipAsync(patientId, followerId);
    if (targetRel == null)
    {
        throw new Exception("The specified member is not linked to this patient's care team.");
    }

    await _followerRepository.RemoveAsync(targetRel);
}
    public async Task LeavePatientAsync(Guid patientId, Guid followerId)
    {
        // Find the relationship record
        var relationship = await _followerRepository.GetRelationshipAsync(patientId, followerId);
        if (relationship == null)
        {
            throw new Exception("You are not linked to this patient.");
        }

        // If they are the primary admin, block them from leaving blindly!
        if (relationship.IsPrimary)
        {
            throw new Exception("Action Denied: As the Primary Caregiver, you cannot leave the care team until you transfer Admin rights to another family member.");
        }

        // If they are a standard follower, let them leave cleanly
        await _followerRepository.RemoveAsync(relationship);
    }

    public async Task<List<TrackedPatientResponse>> GetTrackedPatientsAsync(Guid followerId)
    {
        var links = await _followerRepository.GetRelationshipsByFollowerIdAsync(followerId);

        return links.Select(l => new TrackedPatientResponse
        {
            PatientId = l.PatientId,
            FullName = l.Patient?.FullName ?? "Unknown Patient",
            ProfilePhotoUrl = l.Patient?.ProfilePhotoUrl,
            IsPrimaryAdmin = l.IsPrimary,
            JoinedAt = l.CreatedAt
        }).ToList();
    }
}