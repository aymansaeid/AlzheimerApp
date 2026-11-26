namespace AlzheimerApp.Application.DTOs.Followers;

/// <summary>
/// What the logged-in user may do for ONE patient. Returned by <c>GET /api/Follower/my-patients</c> and the
/// follower dashboard, and enforced by the API (403 otherwise). The app should show/hide buttons from these flags
/// instead of re-deriving rules from <c>role</c> / <c>isPrimaryAdmin</c>.
/// </summary>
/// <remarks>
/// The whole policy lives in the factory methods below — change a rule here and both the API checks
/// and the flags sent to the app follow.
/// </remarks>
public class PatientPermissions
{
    /// <summary>See the patient's data (location, medicines, memories, alerts, team).</summary>
    public bool CanView { get; init; }

    /// <summary>The caller is this patient's primary caregiver (care team admin).</summary>
    public bool IsPrimaryAdmin { get; init; }

    /// <summary>Mark a dose as taken / pending.</summary>
    public bool CanMarkDoses { get; init; }

    /// <summary>Add, edit, pause or delete medicines.</summary>
    public bool CanManageMedicines { get; init; }

    /// <summary>Add, edit or delete safe zones.</summary>
    public bool CanManageSafeZones { get; init; }

    /// <summary>Add memories, and edit/delete the ones the caller uploaded.</summary>
    public bool CanAddMemories { get; init; }

    /// <summary>Edit/delete ANY memory of this patient (not only the caller's own).</summary>
    public bool CanManageAllMemories { get; init; }

    /// <summary>Invite members, remove members, transfer the admin role.</summary>
    public bool CanManageCareTeam { get; init; }

    public static PatientPermissions None { get; } = new();

    /// <summary>System admin (role 2): everything.</summary>
    public static PatientPermissions ForSystemAdmin() => new()
    {
        CanView = true,
        CanMarkDoses = true,
        CanManageMedicines = true,
        CanManageSafeZones = true,
        CanAddMemories = true,
        CanManageAllMemories = true,
        CanManageCareTeam = true
    };

    /// <summary>The patient looking at their own data: read + mark own doses.</summary>
    public static PatientPermissions ForPatientSelf() => new()
    {
        CanView = true,
        CanMarkDoses = true
    };

    /// <summary>A care team member. The primary caregiver additionally manages medicines, safe zones, all memories and the team.</summary>
    public static PatientPermissions ForFollower(bool isPrimary) => new()
    {
        CanView = true,
        IsPrimaryAdmin = isPrimary,
        CanMarkDoses = true,
        CanAddMemories = true,
        CanManageMedicines = isPrimary,
        CanManageSafeZones = isPrimary,
        CanManageAllMemories = isPrimary,
        CanManageCareTeam = isPrimary
    };
}