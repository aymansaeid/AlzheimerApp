using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace AlzheimerApp.API.Hubs;

/// <summary>
/// Real-time location hub. Connect to <c>/hubs/location?access_token={jwt}</c>.
/// </summary>
[Authorize] // Only logged-in users can connect to the websocket
public class LocationHub : Hub
{
    private readonly ILocationService _locationService;

    /// <summary>SignalR group of everyone watching one patient (location updates and safe zone changes).</summary>
    public static string GroupFor(Guid patientId) => $"PatientTracker_{patientId}";

    public LocationHub(ILocationService locationService)
    {
        _locationService = locationService;
    }

    // The Flutter app will call this method when the Follower opens the map screen
    public async Task SubscribeToPatientTracking(Guid patientId)
    {
        // Only the patient, their linked care team and admins may listen to this patient's location.
        if (!Guid.TryParse(Context.UserIdentifier, out var userId))
            throw new HubException("Invalid token claims.");

        bool isAdmin = Context.User?.IsInRole(nameof(UserRole.Admin)) ?? false;
        if (!await _locationService.CanTrackPatientAsync(userId, isAdmin, patientId))
            throw new HubException("Access denied: you are not part of this patient's care team.");

        // We group connections by Patient ID.
        // This way, we only send updates to the family members of THIS specific patient.
        await Groups.AddToGroupAsync(Context.ConnectionId, GroupFor(patientId));
    }

    public async Task UnsubscribeFromPatientTracking(Guid patientId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, GroupFor(patientId));
    }
}