using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;

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
        var exists = await _context.Users.AnyAsync(u => u.Email == user.Email);
        if (exists) return BadRequest(new { message = "Email already registered" });
        if (user.CreatedAt == null) {
            user.CreatedAt = DateTime.UtcNow;
        }

        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return Ok(new { message = "User registered successfully!" });
    }

    // 2. Login Endpoint
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest loginData)
    {
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email == loginData.Email && u.PasswordText == loginData.Password);

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
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}