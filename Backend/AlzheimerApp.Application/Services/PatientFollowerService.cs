using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Services;

public class PatientFollowerService : IPatientFollowerService
{
    private readonly IPatientFollowerRepository _followerRepository;

    public PatientFollowerService(IPatientFollowerRepository followerRepository)
    {
        _followerRepository = followerRepository;
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
}