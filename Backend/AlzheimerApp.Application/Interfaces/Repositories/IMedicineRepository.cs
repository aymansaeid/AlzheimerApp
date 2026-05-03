using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IMedicineRepository
{
    Task<Medicine?> GetByIdAsync(Guid id);
    Task<List<Medicine>> GetActiveMedicinesByPatientIdAsync(Guid patientId);
    Task<Medicine> AddAsync(Medicine medicine);
    Task UpdateAsync(Medicine medicine);
    Task DeleteAsync(Medicine medicine);
}