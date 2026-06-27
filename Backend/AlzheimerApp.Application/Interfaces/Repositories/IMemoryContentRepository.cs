using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IMemoryContentRepository
{
    Task<MemoryContent?> GetByIdAsync(Guid id);
    Task<List<MemoryContent>> GetActiveContentByPatientIdAsync(Guid patientId, Guid? uploaderId = null, string? personName = null, int? contentType = null);
    Task<MemoryContent> AddAsync(MemoryContent content);
    Task UpdateAsync(MemoryContent content);
    Task DeleteAsync(MemoryContent content);
}