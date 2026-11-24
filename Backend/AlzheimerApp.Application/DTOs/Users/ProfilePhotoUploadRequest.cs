namespace AlzheimerApp.Application.DTOs.Users;

/// <summary>
/// Framework-independent representation of an uploaded profile photo.
/// The API layer maps <c>IFormFile</c> to this so the Application layer stays free of ASP.NET Core types.
/// </summary>
public class ProfilePhotoUploadRequest
{
    public required Stream Content { get; init; }
    public required string FileName { get; init; }
    public long Length { get; init; }
}