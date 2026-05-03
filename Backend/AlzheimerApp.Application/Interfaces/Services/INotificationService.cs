namespace AlzheimerApp.Application.Interfaces.Services;

public interface INotificationService
{
    Task<bool> SendMulticastAlertAsync(List<string> fcmTokens, string title, string body, string alertType);
}