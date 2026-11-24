using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;

namespace AlzheimerApp.Application.DTOs.Auth;

/// <summary>
/// Public user profile returned by the Auth endpoints (login, refresh-my-token) and PUT /api/Users/me.
/// </summary>
public class UserDto
{
    public Guid Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Phone { get; set; } = string.Empty;

    /// <summary>0 = Patient, 1 = Follower (Caregiver), 2 = Admin.</summary>
    public UserRole Role { get; set; }

    /// <summary>Public URL of the user's profile photo, or <c>null</c> if none has been uploaded.</summary>
    public string? ProfilePhotoUrl { get; set; }

    public static UserDto FromEntity(User user) => new()
    {
        Id = user.Id,
        FullName = user.FullName,
        Email = user.Email,
        Phone = user.Phone,
        Role = user.Role,
        ProfilePhotoUrl = user.ProfilePhotoUrl
    };
}