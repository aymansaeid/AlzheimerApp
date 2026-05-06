using AlzheimerApp.Application.DTOs.MemoryContents;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IMemoryContentService
{
    Task<MemoryContentResponse> AddContentAsync(MemoryContentRequest request);
    Task<List<MemoryContentResponse>> GetPatientContentAsync(Guid patientId);
    Task UpdateContentAsync(Guid id, UpdateMemoryContentRequest request);
    Task DeleteContentAsync(Guid id);
}