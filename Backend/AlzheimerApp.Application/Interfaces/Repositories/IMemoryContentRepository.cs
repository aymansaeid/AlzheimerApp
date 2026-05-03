using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IMemoryContentRepository
{
    Task<MemoryContent> AddAsync(MemoryContent content);
    Task<List<MemoryContent>> GetActiveContentByPatientIdAsync(Guid patientId);
}