using AlzheimerApp.Application.DTOs.Users;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IUserService
{
    Task UpdateFcmTokenAsync(Guid userId, string token);

    /// <summary>
    /// Validates the image (max 5 MB, jpg/jpeg/png/webp by real file signature), uploads it to
    /// persistent storage, saves the new URL on the user and removes the previous photo.
    /// </summary>
    /// <exception cref="ArgumentException">The file fails validation.</exception>
    /// <exception cref="KeyNotFoundException">The user does not exist.</exception>
    Task<ProfilePhotoResponse> UpdateProfilePhotoAsync(Guid userId, ProfilePhotoUploadRequest request, CancellationToken cancellationToken = default);
}