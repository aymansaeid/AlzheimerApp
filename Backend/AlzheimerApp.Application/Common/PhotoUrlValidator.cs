namespace AlzheimerApp.Application.Common;

/// <summary>
/// Validates profile photo URLs that the mobile app uploads to Firebase Storage itself and then sends to the API.
/// </summary>
public static class PhotoUrlValidator
{
    public const int MaxLength = 2048;

    /// <summary>
    /// Returns the trimmed URL, or <c>null</c> when the input is null/blank (meaning "no photo").
    /// </summary>
    /// <exception cref="ArgumentException">The URL is not an absolute https URL or is too long.</exception>
    public static string? Normalize(string? url)
    {
        if (string.IsNullOrWhiteSpace(url)) return null;

        var trimmed = url.Trim();
        if (trimmed.Length > MaxLength)
            throw new ArgumentException($"The profile photo URL must be at most {MaxLength} characters.");

        if (!Uri.TryCreate(trimmed, UriKind.Absolute, out var uri) || uri.Scheme != Uri.UriSchemeHttps)
            throw new ArgumentException("The profile photo URL must be a valid https:// URL.");

        return trimmed;
    }
}