using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace AlzheimerApp.API.Hubs;

[Authorize] // Only logged-in users can connect to the websocket
public class LocationHub : Hub
{
    // The Flutter app will call this method when the Follower opens the map screen
    public async Task SubscribeToPatientTracking(Guid patientId)
    {
        // We group connections by Patient ID. 
        // This way, we only send updates to the family members of THIS specific patient.
        string groupName = $"PatientTracker_{patientId}";
        await Groups.AddToGroupAsync(Context.ConnectionId, groupName);

        Console.WriteLine($"User {Context.UserIdentifier} subscribed to {groupName}");
    }

    public async Task UnsubscribeFromPatientTracking(Guid patientId)
    {
        string groupName = $"PatientTracker_{patientId}";
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
    }
}