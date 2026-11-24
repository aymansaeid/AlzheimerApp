namespace AlzheimerApp.Application.Interfaces.Services;

public interface INotificationService
{
    Task<bool> SendMulticastAlertAsync(List<string> fcmTokens, string title, string body, string alertType);

    /// <summary>
    /// Sends a push notification with a custom data payload (read by the Flutter app, e.g. <c>type</c>, <c>patientId</c>).
    /// Returns true if at least one device received it.
    /// </summary>
    Task<bool> SendMulticastAsync(List<string> fcmTokens, string title, string body, IReadOnlyDictionary<string, string> data);
}