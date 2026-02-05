using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

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

    // 1. Register Endpoint
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] User user)
    {
        // Check if user already exists
        var exists = await _context.Users.AnyAsync(u => u.Email == user.Email);
        if (exists) return BadRequest(new { message = "Email already registered" });

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
            user = new { user.Fullname, user.Email } 
        });
    }
}

// Data Transfer Object for Login
public class LoginRequest
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}