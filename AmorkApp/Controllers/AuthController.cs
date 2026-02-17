using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;
using System.Text.Json.Serialization;

namespace AmorkApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AmorkDbContext _context;

    public AuthController(AmorkDbContext context)
    {
        _context = context;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] User user)
    {
        // 1. Check if user already exists
        var exists = await _context.Users.AnyAsync(u => u.Email.ToLower() == user.Email.ToLower());
        if (exists) return BadRequest(new { message = "Email already registered" });

        // 2. Set/Update timestamps
        // We removed the ??= because the User model already defaults to UtcNow
        user.UpdatedAt = DateTime.UtcNow;

        // 3. Save to database
        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return Ok(new { message = "User registered successfully!", userId = user.UserId });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest loginData)
    {
        // Search for user with matching email AND password
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == loginData.Email.ToLower() 
                                 && u.PasswordHash == loginData.Password);

        if (user == null) return Unauthorized(new { message = "Invalid email or password" });

        return Ok(new {
            message = "Login successful",
            token = "mock_token_for_development",
            user = new {
                id = user.UserId,
                fullname = user.Fullname,
                email = user.Email,
                memberType = user.MemberType
            }
        });
    }
}

public class LoginRequest
{
    [JsonPropertyName("email")]
    public string Email { get; set; } = string.Empty;

    [JsonPropertyName("password")]
    public string Password { get; set; } = string.Empty;
}