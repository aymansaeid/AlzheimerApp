using AlzheimerApp.Application.DTOs.Auth;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace AlzheimerApp.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IConfiguration _configuration;

    public AuthController(IAuthService authService, IConfiguration configuration)
    {
        _authService = authService;
        _configuration = configuration;
    }
    /// <summary>
    /// Registers a new user (Patient or Follower) into the system.
    /// </summary>
    /// <remarks>
    /// **Role Mapping:**
    /// * 0 = Patient
    /// * 1 = Follower
    /// * 2 = Admin
    /// 
    /// Sample request:
    /// 
    ///     POST /api/auth/register
    ///     {
    ///        "email": "ekrem@example.com",
    ///        "password": "StrongPassword123!",
    ///        "fullName": "Ekrem (Son)",
    ///        "role": 1
    ///     }
    /// </remarks>
    /// <response code="200">Returns the new user's ID and details.</response>
    /// <response code="400">If the email is already taken or validation fails.</response>
    [HttpPost("register")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    public async Task<IActionResult> Register([FromBody] RegisterDto dto)
    {
        try
        {
            var user = await _authService.RegisterAsync(dto);
            return Ok(new { Message = "User registered successfully", UserId = user.Id });
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    /// <summary>
    /// Logs in an existing user and returns a JWT token.
    /// </summary>
    /// <remarks>
    /// Sample request:
    /// 
    ///     POST /api/auth/login
    ///     {
    ///        "email": "ekrem@example.com",
    ///        "password": "StrongPassword123!"
    ///     }
    /// </remarks>
    /// <response code="200">Returns the JWT token and user details.</response>
    /// <response code="401">If the email or password is incorrect.</response>
    [HttpPost("login")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<IActionResult> Login([FromBody] LoginDto dto)
    {
        try
        {
            var user = await _authService.LoginAsync(dto);
            var token = GenerateJwtToken(user);

            return Ok(new
            {
                Token = token,
                User = new { user.Id, user.FullName, user.Email, user.Role }
            });
        }
        catch (Exception ex)
        {
            return Unauthorized(new { Error = ex.Message });
        }
    }

    private string GenerateJwtToken(User user)
    {
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSettings["Secret"]!));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Email, user.Email),
            new Claim(ClaimTypes.Role, user.Role.ToString()),
            new Claim("FullName", user.FullName)
        };

        var token = new JwtSecurityToken(
            issuer: jwtSettings["Issuer"],
            audience: jwtSettings["Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddDays(7), // Token lasts for 7 days
            signingCredentials: creds
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}