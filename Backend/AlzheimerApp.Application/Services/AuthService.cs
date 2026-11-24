using AlzheimerApp.Application.Common;
using AlzheimerApp.Application.DTOs.Auth;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;
using BCrypt.Net;

namespace AlzheimerApp.Application.Services;

public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;

    public AuthService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<User> RegisterAsync(RegisterDto dto)
    {
        // 1. Check if user already exists
        var existingUser = await _userRepository.GetByEmailAsync(dto.Email);
        if (existingUser != null)
        {
            throw new Exception("A user with this email already exists.");
        }

        // 2. Optional profile photo URL (must be https if provided)
        var profilePhotoUrl = PhotoUrlValidator.Normalize(dto.ProfilePhotoUrl);

        // 3. Hash the password securely
        string passwordHash = BCrypt.Net.BCrypt.HashPassword(dto.Password);

        // 4. Create the Domain Entity
        var user = new User
        {
            Email = dto.Email,
            PasswordHash = passwordHash,
            FullName = dto.FullName,
            Phone = dto.Phone,
            Role = dto.Role,
            ProfilePhotoUrl = profilePhotoUrl,
            IsActive = true
        };

        // 5. Save to database
        return await _userRepository.AddAsync(user);
    }

    public async Task<User> LoginAsync(LoginDto dto)
    {
        // 1. Find the user
        var user = await _userRepository.GetByEmailAsync(dto.Email);
        if (user == null)
        {
            throw new Exception("Invalid email or password.");
        }

        // 2. Verify the password
        bool isPasswordValid = BCrypt.Net.BCrypt.Verify(dto.Password, user.PasswordHash);
        if (!isPasswordValid)
        {
            throw new Exception("Invalid email or password.");
        }

        return user;
    }

    public async Task<User> GetFreshUserByIdAsync(Guid userId)
    {
        // Kullanıcıyı veritabanından güncel rolüyle birlikte çek
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) throw new Exception("User not found.");

        return user;
    }
}