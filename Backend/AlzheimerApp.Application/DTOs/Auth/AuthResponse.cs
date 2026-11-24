namespace AlzheimerApp.Application.DTOs.Auth;

/// <summary>
/// Response of <c>POST /api/Auth/login</c> and <c>POST /api/Auth/refresh-my-token</c>.
/// </summary>
public class AuthResponse
{
    public string Token { get; set; } = string.Empty;
    public UserDto User { get; set; } = new();
}