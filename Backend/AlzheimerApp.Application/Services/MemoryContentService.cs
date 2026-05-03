using AlzheimerApp.Application.DTOs.MemoryContents;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Services;

public class MemoryContentService : IMemoryContentService
{
    private readonly IMemoryContentRepository _contentRepository;

    public MemoryContentService(IMemoryContentRepository contentRepository)
    {
        _contentRepository = contentRepository;
    }

    public async Task<MemoryContentResponse> AddContentAsync(MemoryContentRequest request)
    {
        var memoryContent = new MemoryContent
        {
            PatientId = request.PatientId,
            UploadedBy = request.UploadedBy,
            ContentType = request.ContentType,
            Title = request.Title,
            Description = request.Description,
            FileUrl = request.FileUrl,
            PersonName = request.PersonName,
            Relationship = request.Relationship,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var savedEntity = await _contentRepository.AddAsync(memoryContent);

        return MapToResponse(savedEntity);
    }

    public async Task<List<MemoryContentResponse>> GetPatientContentAsync(Guid patientId)
    {
        var contents = await _contentRepository.GetActiveContentByPatientIdAsync(patientId);
        return contents.Select(MapToResponse).ToList();
    }

    private MemoryContentResponse MapToResponse(MemoryContent content)
    {
        return new MemoryContentResponse
        {
            Id = content.Id,
            PatientId = content.PatientId,
            ContentType = content.ContentType,
            Title = content.Title,
            Description = content.Description,
            FileUrl = content.FileUrl,
            PersonName = content.PersonName,
            Relationship = content.Relationship,
            CreatedAt = content.CreatedAt
        };
    }
}