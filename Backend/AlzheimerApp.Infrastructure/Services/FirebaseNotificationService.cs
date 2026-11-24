using AlzheimerApp.Application.Interfaces.Services;
using FirebaseAdmin.Messaging;

namespace AlzheimerApp.Infrastructure.Services;

public class FirebaseNotificationService : INotificationService
{
    public Task<bool> SendMulticastAlertAsync(List<string> fcmTokens, string title, string body, string alertType)
    {
        return SendMulticastAsync(fcmTokens, title, body, new Dictionary<string, string>
        {
            { "alertType", alertType }
        });
    }

    public async Task<bool> SendMulticastAsync(List<string> fcmTokens, string title, string body, IReadOnlyDictionary<string, string> data)
    {
        var tokens = fcmTokens?.Where(t => !string.IsNullOrWhiteSpace(t)).Distinct().ToList();
        if (tokens == null || tokens.Count == 0) return false;

        var payload = new Dictionary<string, string>(data)
        {
            ["click_action"] = "FLUTTER_NOTIFICATION_CLICK" // Tells the mobile app to open when clicked!
        };

        var message = new MulticastMessage()
        {
            Tokens = tokens,
            Notification = new Notification
            {
                Title = title,
                Body = body
            },
            Data = payload
        };

        // Send to all devices at the exact same time
        var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message);

        return response.SuccessCount > 0;
    }
}