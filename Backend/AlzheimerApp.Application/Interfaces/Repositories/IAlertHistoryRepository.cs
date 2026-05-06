using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IAlertHistoryRepository
{
    Task AddAsync(AlertHistory alert);
    Task<AlertHistory?> GetByIdAsync(Guid id); 
    Task<List<AlertHistory>> GetPatientAlertsAsync(Guid patientId); 
    Task UpdateAsync(AlertHistory alert); 
}