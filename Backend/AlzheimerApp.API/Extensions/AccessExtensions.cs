using AlzheimerApp.Application.DTOs.Followers;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Enums;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace AlzheimerApp.API.Extensions;

/// <summary>Small helpers so every controller reads the caller and checks per-patient permissions the same way.</summary>
public static class AccessExtensions
{
    /// <summary>The caller's user id from the JWT (<c>NameIdentifier</c>), or <c>Guid.Empty</c>.</summary>
    public static Guid GetUserId(this ClaimsPrincipal user) =>
        Guid.TryParse(user.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : Guid.Empty;

    /// <summary>True for the system admin role (UserRole.Admin), NOT for a patient's primary caregiver.</summary>
    public static bool IsSystemAdmin(this ClaimsPrincipal user) => user.IsInRole(nameof(UserRole.Admin));

    public static Task<PatientPermissions> GetPermissionsAsync(this ICareTeamAccessService access, ClaimsPrincipal user, Guid patientId) =>
        access.GetPermissionsAsync(user.GetUserId(), user.IsSystemAdmin(), patientId);

    /// <summary>403 with a readable message (Forbid() would return an empty body).</summary>
    public static IActionResult NoPermission(this ControllerBase controller, string? message = null) =>
        controller.StatusCode(StatusCodes.Status403Forbidden,
            new { Error = message ?? "You do not have permission to do this for this patient." });
}