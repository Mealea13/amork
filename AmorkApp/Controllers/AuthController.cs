using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;
using System.Text.Json.Serialization;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;

namespace AmorkApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly AmorkDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthController(AmorkDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        // 1. Check if user already exists
        var exists = await _context.Users.AnyAsync(u => u.Email.ToLower() == request.Email.ToLower());
        if (exists) return BadRequest(new { message = "Email already registered" });

        // 2. Create new user
        var user = new User
        {
            UserId       = Guid.NewGuid(),
            Fullname     = request.Fullname,
            Email        = request.Email,
            PasswordHash = request.Password, // TODO: hash with BCrypt later
            Phone        = request.Phone,
            MemberType   = "regular",
            CreatedAt    = DateTime.UtcNow,
            UpdatedAt    = DateTime.UtcNow,
            IsActive     = true,
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        // 3. Generate JWT token
        var token = GenerateJwtToken(user);

        return Ok(new {
            message = "User registered successfully!",
            token   = token,
            user    = new {
                id       = user.UserId,
                userId   = user.UserId,
                fullname = user.Fullname,
                email    = user.Email,
            }
        });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest loginData)
    {
        // 1. Find user
        var user = await _context.Users
            .FirstOrDefaultAsync(u => u.Email.ToLower() == loginData.Email.ToLower());

        // 2. Check password
        if (user == null || user.PasswordHash != loginData.Password)
        {
            return Unauthorized(new { message = "Invalid email or password" });
        }

        // 3. Generate JWT token
        var token = GenerateJwtToken(user);

        return Ok(new {
            message = "Login successful",
            token   = token,
            user    = new {
                id       = user.UserId,
                userId   = user.UserId,
                fullname = user.Fullname,
                email    = user.Email,
            }
        });
    }

    // JWT generator
    private string GenerateJwtToken(User user)
    {
        var key = new SymmetricSecurityKey(
            Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
            new Claim(ClaimTypes.Email, user.Email),
            new Claim("userId", user.UserId.ToString()),
        };

        var token = new JwtSecurityToken(
            issuer:             _configuration["Jwt:Issuer"],
            audience:           _configuration["Jwt:Audience"],
            claims:             claims,
            expires:            DateTime.UtcNow.AddDays(7),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}

public class RegisterRequest
{
    [JsonPropertyName("fullname")]
    public string Fullname { get; set; } = string.Empty;

    [JsonPropertyName("email")]
    public string Email { get; set; } = string.Empty;

    [JsonPropertyName("password")]
    public string Password { get; set; } = string.Empty;

    [JsonPropertyName("phone")]
    public string? Phone { get; set; }

    [JsonPropertyName("member_type")]
    public string? MemberType { get; set; } // kept for compatibility but ignored
}

public class LoginRequest
{
    [JsonPropertyName("email")]
    public string Email { get; set; } = string.Empty;

    [JsonPropertyName("password")]
    public string Password { get; set; } = string.Empty;
}