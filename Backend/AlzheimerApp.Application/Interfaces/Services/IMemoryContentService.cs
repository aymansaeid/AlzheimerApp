using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Application.DTOs.MemoryContents;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IMemoryContentService
{
    Task<MemoryContentResponse> AddContentAsync(MemoryContentRequest request);
    Task<List<MemoryContentResponse>> GetPatientContentAsync(Guid patientId, Guid? uploaderId = null, string? personName = null, int? contentType = null);
    Task<PagedResponse<MemoryProfileResponse>> GetPaginatedMemoryProfilesAsync(Guid patientId, int page, int pageSize);
    Task UpdateContentAsync(Guid id, UpdateMemoryContentRequest request);
    Task DeleteContentAsync(Guid id);
}