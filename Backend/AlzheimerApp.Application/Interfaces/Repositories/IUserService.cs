using AlzheimerApp.Application.DTOs.Auth;
using AlzheimerApp.Application.DTOs.Users;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IUserService
{
    Task UpdateFcmTokenAsync(Guid userId, string token);

    /// <summary>
    /// Updates the logged-in user's own profile. Only the fields that are not null are changed.
    /// Changing the e-mail or password requires the current password.
    /// </summary>
    /// <exception cref="ArgumentException">Validation failed or the current password is wrong.</exception>
    /// <exception cref="KeyNotFoundException">The user does not exist.</exception>
    /// <exception cref="AlzheimerApp.Application.Common.ConflictException">The new e-mail is already used by another account.</exception>
    Task<UserDto> UpdateProfileAsync(Guid userId, UpdateProfileRequest request);

    /// <summary>
    /// Validates the image (max 5 MB, jpg/jpeg/png/webp by real file signature), uploads it to
    /// persistent storage, saves the new URL on the user and removes the previous photo.
    /// </summary>
    /// <exception cref="ArgumentException">The file fails validation.</exception>
    /// <exception cref="KeyNotFoundException">The user does not exist.</exception>
    Task<ProfilePhotoResponse> UpdateProfilePhotoAsync(Guid userId, ProfilePhotoUploadRequest request, CancellationToken cancellationToken = default);
}