namespace AlzheimerApp.Application.DTOs.Followers;

public class InviteResponse
{
    public string InviteCode { get; set; } = string.Empty;
    public string DeepLinkUrl { get; set; } = string.Empty; // The clickable link for Flutter!
    public DateTime ExpiresAt { get; set; }
}