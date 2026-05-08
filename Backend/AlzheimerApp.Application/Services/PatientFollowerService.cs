using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Services;

public class PatientFollowerService : IPatientFollowerService
{
    private readonly IPatientFollowerRepository _followerRepository;
    private readonly IPatientInviteRepository _inviteRepository;


    public PatientFollowerService(IPatientFollowerRepository followerRepository , IPatientInviteRepository inviteRepository)
    {
        _followerRepository = followerRepository;
        _inviteRepository = inviteRepository;
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
}