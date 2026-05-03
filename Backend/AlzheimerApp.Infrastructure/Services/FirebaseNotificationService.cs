using AlzheimerApp.Application.Interfaces.Services;
using FirebaseAdmin.Messaging;

namespace AlzheimerApp.Infrastructure.Services;

public class FirebaseNotificationService : INotificationService
{
    public async Task<bool> SendMulticastAlertAsync(List<string> fcmTokens, string title, string body, string alertType)
    {
        if (fcmTokens == null || !fcmTokens.Any()) return false;

        var message = new MulticastMessage()
        {
            Tokens = fcmTokens,
            Notification = new Notification
            {
                Title = title,
                Body = body
            },
            Data = new Dictionary<string, string>()
            {
                { "alertType", alertType },
                { "click_action", "FLUTTER_NOTIFICATION_CLICK" } // Tells the mobile app to open when clicked!
            }
        };

        // Send to all followers at the exact same time
        var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(message);

        return response.SuccessCount > 0;
    }
}