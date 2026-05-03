using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IPatientFollowerRepository
{
    // We need this to find the family members tracking this specific patient
    Task<List<User>> GetFollowersByPatientIdAsync(Guid patientId);
}