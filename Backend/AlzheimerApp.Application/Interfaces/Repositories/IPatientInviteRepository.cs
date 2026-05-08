using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IPatientInviteRepository
{
    Task<PatientInvite> AddAsync(PatientInvite invite);
    Task<PatientInvite?> GetByCodeAsync(string inviteCode);
    Task UpdateAsync(PatientInvite invite);
}