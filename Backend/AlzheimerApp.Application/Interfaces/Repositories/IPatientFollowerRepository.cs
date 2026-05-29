using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IPatientFollowerRepository
{
    // We need this to find the family members tracking this specific patient
    Task<List<PatientFollower>> GetFollowersByPatientIdAsync(Guid patientId);
    Task<PatientFollower> AddAsync(PatientFollower patientFollower);
    Task<bool> RelationshipExistsAsync(Guid patientId, Guid followerId);
    Task<bool> HasPrimaryFollowerAsync(Guid patientId);

    Task<PatientFollower?> GetRelationshipAsync(Guid patientId, Guid followerId);
    Task UpdateAsync(PatientFollower relationship);
    Task RemoveAsync(PatientFollower relationship);
}