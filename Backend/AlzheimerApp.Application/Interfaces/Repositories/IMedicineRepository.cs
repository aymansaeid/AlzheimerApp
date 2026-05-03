using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IMedicineRepository
{
    Task<Medicine> AddAsync(Medicine medicine);
    Task<List<Medicine>> GetActiveMedicinesByPatientIdAsync(Guid patientId);
}