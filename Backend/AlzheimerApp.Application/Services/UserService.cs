using AlzheimerApp.Application.DTOs.Users;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;

namespace AlzheimerApp.Application.Services;

public class UserService : IUserService
{
    /// <summary>Maximum accepted profile photo size: 5 MB.</summary>
    public const long MaxProfilePhotoBytes = 5 * 1024 * 1024;

    private const string ProfilePhotoFolder = "profile-photos";

    // Extension -> canonical image format. jpg and jpeg are the same format.
    private static readonly Dictionary<string, ImageFormat> AllowedExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        [".jpg"] = ImageFormat.Jpeg,
        [".jpeg"] = ImageFormat.Jpeg,
        [".png"] = ImageFormat.Png,
        [".webp"] = ImageFormat.Webp
    };

    private readonly IUserRepository _userRepository;
    private readonly IFileStorageService _fileStorageService;

    public UserService(IUserRepository userRepository, IFileStorageService fileStorageService)
    {
        _userRepository = userRepository;
        _fileStorageService = fileStorageService;
    }

    public async Task UpdateFcmTokenAsync(Guid userId, string token)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) throw new Exception("User not found.");

        user.FcmToken = token;
        await _userRepository.UpdateAsync(user);
    }

    public async Task<ProfilePhotoResponse> UpdateProfilePhotoAsync(Guid userId, ProfilePhotoUploadRequest request, CancellationToken cancellationToken = default)
    {
        // 1. Cheap checks first: size and extension.
        if (request.Length <= 0)
            throw new ArgumentException("The uploaded file is empty.");

        if (request.Length > MaxProfilePhotoBytes)
            throw new ArgumentException("The profile photo must be 5 MB or smaller.");

        var extension = Path.GetExtension(request.FileName);
        if (string.IsNullOrEmpty(extension) || !AllowedExtensions.TryGetValue(extension, out var formatFromExtension))
            throw new ArgumentException("Only .jpg, .jpeg, .png and .webp files are allowed.");

        // 2. Buffer the file (max 5 MB) so we can inspect its real signature.
        //    We never trust the client's Content-Type header: Flutter's http/dio packages
        //    send "application/octet-stream" unless the developer sets it explicitly.
        using var buffer = new MemoryStream();
        await CopyWithLimitAsync(request.Content, buffer, MaxProfilePhotoBytes, cancellationToken);

        var detectedFormat = DetectImageFormat(buffer.GetBuffer().AsSpan(0, (int)buffer.Length));
        if (detectedFormat == null || detectedFormat != formatFromExtension)
            throw new ArgumentException("The file content is not a valid JPG, PNG or WEBP image.");

        // 3. Make sure the user exists before uploading anything.
        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException("User not found.");

        var oldPhotoUrl = user.ProfilePhotoUrl;

        // 4. Upload under a fresh name, so CDN/app caches never serve the old photo.
        var (fileExtension, contentType) = detectedFormat.Value switch
        {
            ImageFormat.Jpeg => (".jpg", "image/jpeg"),
            ImageFormat.Png => (".png", "image/png"),
            _ => (".webp", "image/webp")
        };
        var objectPath = $"{ProfilePhotoFolder}/{userId}/{Guid.NewGuid():N}{fileExtension}";

        buffer.Position = 0;
        var newPhotoUrl = await _fileStorageService.UploadAsync(buffer, objectPath, contentType, cancellationToken);

        // 5. Persist the URL. If the database update fails, remove the orphaned upload.
        try
        {
            user.ProfilePhotoUrl = newPhotoUrl;
            await _userRepository.UpdateAsync(user);
        }
        catch
        {
            await TryDeleteAsync(newPhotoUrl);
            throw;
        }

        // 6. Best-effort cleanup of the previous photo. A failure here must not fail the request.
        if (!string.IsNullOrEmpty(oldPhotoUrl))
        {
            await TryDeleteAsync(oldPhotoUrl);
        }

        return new ProfilePhotoResponse { ProfilePhotoUrl = newPhotoUrl };
    }

    private async Task TryDeleteAsync(string fileUrl)
    {
        try
        {
            await _fileStorageService.DeleteAsync(fileUrl);
        }
        catch
        {
            // Swallowed on purpose: an orphaned file in storage is preferable to a failed request.
        }
    }

    private static async Task CopyWithLimitAsync(Stream source, Stream destination, long maxBytes, CancellationToken cancellationToken)
    {
        var chunk = new byte[81920];
        long total = 0;
        int read;
        while ((read = await source.ReadAsync(chunk, cancellationToken)) > 0)
        {
            total += read;
            if (total > maxBytes)
                throw new ArgumentException("The profile photo must be 5 MB or smaller.");

            await destination.WriteAsync(chunk.AsMemory(0, read), cancellationToken);
        }

        if (total == 0)
            throw new ArgumentException("The uploaded file is empty.");
    }

    private static ImageFormat? DetectImageFormat(ReadOnlySpan<byte> header)
    {
        // JPEG: FF D8 FF
        if (header.Length >= 3 && header[0] == 0xFF && header[1] == 0xD8 && header[2] == 0xFF)
            return ImageFormat.Jpeg;

        // PNG: 89 50 4E 47 0D 0A 1A 0A
        if (header.Length >= 8 && header[..8].SequenceEqual(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }))
            return ImageFormat.Png;

        // WEBP: "RIFF" <4-byte size> "WEBP"
        if (header.Length >= 12
            && header[..4].SequenceEqual("RIFF"u8)
            && header.Slice(8, 4).SequenceEqual("WEBP"u8))
            return ImageFormat.Webp;

        return null;
    }

    private enum ImageFormat
    {
        Jpeg,
        Png,
        Webp
    }
}