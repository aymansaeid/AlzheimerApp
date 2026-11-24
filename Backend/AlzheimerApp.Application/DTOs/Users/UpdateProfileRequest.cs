namespace AlzheimerApp.Application.DTOs.Users;

/// <summary>
/// Partial profile update for the logged-in user (any role).
/// Every field is optional: <c>null</c> / omitted means "leave unchanged".
/// </summary>
public class UpdateProfileRequest
{
    /// <summary>New full name. Cannot be empty.</summary>
    public string? FullName { get; set; }

    /// <summary>New phone number. Send an empty string to clear it.</summary>
    public string? Phone { get; set; }

    /// <summary>New e-mail address. Requires <see cref="CurrentPassword"/>.</summary>
    public string? Email { get; set; }

    /// <summary>New password (min. 6 characters). Requires <see cref="CurrentPassword"/>.</summary>
    public string? NewPassword { get; set; }

    /// <summary>The user's current password. Only required when changing <see cref="Email"/> or <see cref="NewPassword"/>.</summary>
    public string? CurrentPassword { get; set; }

    /// <summary>
    /// New profile photo URL (https), e.g. one the app uploaded to Firebase Storage itself.
    /// Send an empty string to remove the photo.
    /// </summary>
    public string? ProfilePhotoUrl { get; set; }
}