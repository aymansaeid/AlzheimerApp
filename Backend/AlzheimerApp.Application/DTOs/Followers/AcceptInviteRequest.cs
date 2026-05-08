namespace AlzheimerApp.Application.DTOs.Followers;

public class AcceptInviteRequest
{
    public string InviteCode { get; set; } = string.Empty;
    public string Relationship { get; set; } = string.Empty; // e.g., "Daughter", "Uncle"
}