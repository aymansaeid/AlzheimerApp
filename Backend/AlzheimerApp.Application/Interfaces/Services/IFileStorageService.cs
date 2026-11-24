namespace AlzheimerApp.Application.Interfaces.Services;

/// <summary>
/// Abstraction over a persistent, publicly readable object store.
/// Render's container disk is ephemeral, so uploaded files must never be written to the local file system.
/// </summary>
public interface IFileStorageService
{
    /// <summary>
    /// Uploads a file and returns a permanent public download URL for it.
    /// </summary>
    /// <param name="content">The file content. Read from its current position to the end.</param>
    /// <param name="objectPath">The storage path, e.g. <c>profile-photos/{userId}/{fileId}.jpg</c>.</param>
    /// <param name="contentType">The MIME type stored with the object, e.g. <c>image/jpeg</c>.</param>
    /// <param name="cancellationToken">Cancels the upload.</param>
    Task<string> UploadAsync(Stream content, string objectPath, string contentType, CancellationToken cancellationToken = default);

    /// <summary>
    /// Deletes a file previously returned by <see cref="UploadAsync"/>.
    /// URLs that do not belong to this storage are ignored, and a file that no longer exists is not an error.
    /// </summary>
    Task DeleteAsync(string fileUrl, CancellationToken cancellationToken = default);
}