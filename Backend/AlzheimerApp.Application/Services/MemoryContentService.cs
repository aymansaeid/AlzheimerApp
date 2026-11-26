using AlzheimerApp.Application.DTOs;
using AlzheimerApp.Application.DTOs.MemoryContents;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.Services;

public class MemoryContentService : IMemoryContentService
{
    private readonly IMemoryContentRepository _contentRepository;

    private readonly IUserRepository _userRepository;

    public MemoryContentService(IMemoryContentRepository contentRepository, IUserRepository userRepository)
    {
        _contentRepository = contentRepository;
        _userRepository = userRepository;
    }
    public async Task<MemoryContentResponse> AddContentAsync(Guid uploaderId, MemoryContentRequest request)
    {
        if (!Enum.IsDefined(request.ContentType))
            throw new ArgumentException("contentType must be 0 (Photo), 1 (Voice) or 2 (IdentityCard).");

        var personName = Clean(request.PersonName);
        var memoryContent = new MemoryContent
        {
            PatientId = request.PatientId,
            UploadedBy = uploaderId,
            ContentType = request.ContentType,
            Title = Clean(request.Title) ?? personName ?? DefaultTitle(request.ContentType),
            Description = Clean(request.Description),
            FileUrl = Clean(request.FileUrl),
            PersonName = personName,
            Relationship = Clean(request.Relationship),
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var savedEntity = await _contentRepository.AddAsync(memoryContent);

        // The new entity has no Uploader loaded; fetch it so the response carries name + photo.
        savedEntity.Uploader ??= await _userRepository.GetByIdAsync(savedEntity.UploadedBy);
        return MapToResponse(savedEntity);
    }

    public async Task<List<MemoryContentResponse>> GetPatientContentAsync(Guid patientId, Guid? uploaderId = null, string? personName = null, int? contentType = null)
    {
        var contents = await _contentRepository.GetActiveContentByPatientIdAsync(patientId, uploaderId, personName, contentType);
        return contents.Select(MapToResponse).ToList();
    }

    public async Task<PagedResponse<MemoryProfileResponse>> GetPaginatedMemoryProfilesAsync(Guid patientId, int page, int pageSize)
    {
        var allContents = await _contentRepository.GetActiveContentByPatientIdAsync(patientId);

        var groupedProfiles = allContents
            .GroupBy(c => new { c.PersonName, c.Relationship, c.UploadedBy })
            .ToList();

        var totalCount = groupedProfiles.Count;
        var pagedGroups = groupedProfiles
            .OrderBy(g => g.Key.PersonName)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToList();

        var items = pagedGroups.Select(g => {
            var latestVoice = g.Where(x => (int)x.ContentType == 1)
                               .OrderByDescending(x => x.CreatedAt)
                               .FirstOrDefault();

            var coverPhoto = g.Where(x => (int)x.ContentType == 0)
                              .OrderByDescending(x => x.CreatedAt)
                              .FirstOrDefault()?.FileUrl ?? g.FirstOrDefault()?.FileUrl;

            return new MemoryProfileResponse
            {
                PersonName = string.IsNullOrWhiteSpace(g.Key.PersonName) ? "Bilinmiyor" : g.Key.PersonName,
                Relationship = string.IsNullOrWhiteSpace(g.Key.Relationship) ? "" : g.Key.Relationship,
                UploaderId = g.Key.UploadedBy,
                UploaderName = g.FirstOrDefault()?.Uploader?.FullName,
                UploaderProfilePhotoUrl = g.FirstOrDefault()?.Uploader?.ProfilePhotoUrl,
                CoverPhotoUrl = coverPhoto,
                MemoryCount = g.Count(),
                LatestVoiceRecordUrl = latestVoice?.FileUrl,
                LatestVoiceRecordText = latestVoice?.Description ?? latestVoice?.Title
            };
        }).ToList();

        return new PagedResponse<MemoryProfileResponse>
        {
            Items = items,
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize
        };
    }

    public async Task<MemoryContentResponse> UpdateContentAsync(Guid id, UpdateMemoryContentRequest request)
    {
        var content = await _contentRepository.GetByIdAsync(id)
            ?? throw new KeyNotFoundException("Memory content not found.");

        // PARTIAL update: null = keep the current value (the app sends only the fields it changed).
        if (request.ContentType.HasValue)
        {
            if (!Enum.IsDefined(request.ContentType.Value))
                throw new ArgumentException("contentType must be 0 (Photo), 1 (Voice) or 2 (IdentityCard).");
            content.ContentType = request.ContentType.Value;
        }
        if (request.PersonName != null) content.PersonName = Clean(request.PersonName);
        if (request.Title != null) content.Title = Clean(request.Title) ?? content.PersonName ?? DefaultTitle(content.ContentType);
        if (request.Description != null) content.Description = Clean(request.Description);
        if (request.FileUrl != null) content.FileUrl = Clean(request.FileUrl);
        if (request.Relationship != null) content.Relationship = Clean(request.Relationship);
        if (request.IsActive.HasValue) content.IsActive = request.IsActive.Value;

        await _contentRepository.UpdateAsync(content);

        content.Uploader ??= await _userRepository.GetByIdAsync(content.UploadedBy);
        return MapToResponse(content);
    }

    private static string? Clean(string? value) => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

    private static string DefaultTitle(MemoryContentType type) => type switch
    {
        MemoryContentType.Photo => "Fotoğraf",
        MemoryContentType.Voice => "Ses kaydı",
        MemoryContentType.IdentityCard => "Kimlik kartı",
        _ => "Anı"
    };

    public async Task DeleteContentAsync(Guid id)
    {
        var content = await _contentRepository.GetByIdAsync(id);
        if (content == null) throw new Exception("Memory content not found.");

        await _contentRepository.DeleteAsync(content);
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
            IsActive = content.IsActive,
            CreatedAt = content.CreatedAt,
            UploaderId = content.UploadedBy,
            UploaderName = content.Uploader?.FullName,
            UploaderProfilePhotoUrl = content.Uploader?.ProfilePhotoUrl
        };
    }
}