namespace AlzheimerApp.Application.DTOs.Users;

public class ProfilePhotoResponse
{
    /// <summary>Permanent public URL of the newly uploaded profile photo.</summary>
    public string ProfilePhotoUrl { get; set; } = string.Empty;
}