using AlzheimerApp.Application.Interfaces.Services;
using FirebaseAdmin;
using Google;
using Google.Cloud.Storage.V1;
using Microsoft.Extensions.Configuration;
using System.Net;
using StorageObject = Google.Apis.Storage.v1.Data.Object;

namespace AlzheimerApp.Infrastructure.Services;

/// <summary>
/// Stores files in the project's Firebase Storage bucket (Google Cloud Storage under the hood).
/// </summary>
/// <remarks>
/// Reuses the service-account credential that <c>Program.cs</c> already loads into <see cref="FirebaseApp"/>,
/// so the only new setting is the bucket name: <c>FirebaseSettings__StorageBucket</c> on Render
/// (for example <c>my-project.firebasestorage.app</c> or <c>my-project.appspot.com</c>).
///
/// Files are served through Firebase "download token" URLs — the same kind of URL the Flutter SDK's
/// <c>getDownloadURL()</c> returns — so the bucket itself does not have to be made public.
/// </remarks>
public class FirebaseStorageService : IFileStorageService
{
    private const string DownloadTokenMetadataKey = "firebaseStorageDownloadTokens";
    private const string DownloadUrlPrefix = "https://firebasestorage.googleapis.com/v0/b/";

    private readonly IConfiguration _configuration;

    // Created on first use: FirebaseApp is initialised in Program.cs after services are registered.
    private readonly Lazy<StorageClient> _storageClient;

    public FirebaseStorageService(IConfiguration configuration)
    {
        _configuration = configuration;
        _storageClient = new Lazy<StorageClient>(
            () => StorageClient.Create(FirebaseApp.DefaultInstance.Options.Credential),
            LazyThreadSafetyMode.ExecutionAndPublication);
    }

    public async Task<string> UploadAsync(Stream content, string objectPath, string contentType, CancellationToken cancellationToken = default)
    {
        var bucket = GetBucketName();
        var downloadToken = Guid.NewGuid().ToString();

        var storageObject = new StorageObject
        {
            Bucket = bucket,
            Name = objectPath,
            ContentType = contentType,
            // Each upload gets a unique path, so the file at a given URL never changes.
            CacheControl = "public, max-age=31536000, immutable",
            Metadata = new Dictionary<string, string>
            {
                [DownloadTokenMetadataKey] = downloadToken
            }
        };

        await _storageClient.Value.UploadObjectAsync(storageObject, content, cancellationToken: cancellationToken);

        return $"{DownloadUrlPrefix}{bucket}/o/{Uri.EscapeDataString(objectPath)}?alt=media&token={downloadToken}";
    }

    public async Task DeleteAsync(string fileUrl, CancellationToken cancellationToken = default)
    {
        var bucket = GetBucketName();
        var objectPath = TryGetObjectPath(fileUrl, bucket);
        if (objectPath == null) return; // Not one of our files (e.g. an old external avatar URL).

        try
        {
            await _storageClient.Value.DeleteObjectAsync(bucket, objectPath, cancellationToken: cancellationToken);
        }
        catch (GoogleApiException ex) when (ex.HttpStatusCode == HttpStatusCode.NotFound)
        {
            // Already gone — nothing to do.
        }
    }

    private string GetBucketName()
    {
        var bucket = _configuration["FirebaseSettings:StorageBucket"];
        if (string.IsNullOrWhiteSpace(bucket))
        {
            throw new InvalidOperationException(
                "Firebase Storage is not configured. Set FirebaseSettings:StorageBucket (Render: FirebaseSettings__StorageBucket).");
        }

        // Accept the "gs://bucket" form shown in the Firebase console as well.
        return bucket.Trim().Replace("gs://", string.Empty).TrimEnd('/');
    }

    /// <summary>Extracts the object path from a URL produced by <see cref="UploadAsync"/>.</summary>
    private static string? TryGetObjectPath(string fileUrl, string bucket)
    {
        var expectedPrefix = $"{DownloadUrlPrefix}{bucket}/o/";
        if (string.IsNullOrWhiteSpace(fileUrl) || !fileUrl.StartsWith(expectedPrefix, StringComparison.Ordinal))
            return null;

        var encodedPath = fileUrl[expectedPrefix.Length..];
        var queryStart = encodedPath.IndexOf('?');
        if (queryStart >= 0) encodedPath = encodedPath[..queryStart];

        return encodedPath.Length == 0 ? null : Uri.UnescapeDataString(encodedPath);
    }
}