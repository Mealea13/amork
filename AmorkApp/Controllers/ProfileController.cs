using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Data;
using AmorkApp.Models;

namespace AmorkApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProfileController : ControllerBase
    {
        private readonly AmorkDbContext _context;

        public ProfileController(AmorkDbContext context)
        {
            _context = context;
        }

        // GET: api/profile/{userId}
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetProfile(Guid userId)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound(new { message = "User not found" });

            var orderCount = await _context.Orders
                .Where(o => o.UserId == userId)
                .CountAsync();

            var memberType = orderCount switch
            {
                0             => "New Guest",
                >= 1 and <= 4 => "Regular",
                >= 5 and <= 9 => "Member",
                _             => "VIP"
            };

            if (user.MemberType != memberType)
            {
                user.MemberType = memberType;
                user.UpdatedAt  = DateTime.UtcNow;
                await _context.SaveChangesAsync();
            }

            return Ok(new
            {
                userId        = user.UserId,
                fullname      = user.Fullname,
                email         = user.Email,
                phone         = user.Phone,
                member        = memberType,
                orderCount    = orderCount,
                profile_image = user.ProfileImage,
                register_date = user.CreatedAt.ToString("dd MMM yyyy"),
            });
        }

        // PUT: api/profile/{userId}
        [HttpPut("{userId}")]
        public async Task<IActionResult> UpdateProfile(Guid userId, [FromBody] ProfileUpdateDto request)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound(new { message = "User not found" });

            // ✅ Only update if value is provided and not empty
            if (!string.IsNullOrWhiteSpace(request.Fullname))
                user.Fullname = request.Fullname.Trim();

            if (!string.IsNullOrWhiteSpace(request.Phone))
                user.Phone = request.Phone.Trim();

            if (!string.IsNullOrWhiteSpace(request.Email))
                user.Email = request.Email.Trim();

            user.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message  = "Profile updated successfully",
                fullname = user.Fullname,
                phone    = user.Phone,
                email    = user.Email,
            });
        }

        // POST: api/profile/upload-image/{userId}
        [HttpPost("upload-image/{userId}")]
        public async Task<IActionResult> UploadProfileImage(Guid userId, IFormFile image)
        {
            if (image == null || image.Length == 0)
                return BadRequest("No image provided");

            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound("User not found");

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "profiles");
            if (!Directory.Exists(uploadsFolder))
                Directory.CreateDirectory(uploadsFolder);

            var fileName = $"{userId}_{DateTime.UtcNow.Ticks}{Path.GetExtension(image.FileName)}";
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await image.CopyToAsync(stream);
            }

            user.ProfileImage = $"/uploads/profiles/{fileName}";
            user.UpdatedAt    = DateTime.UtcNow;
            await _context.SaveChangesAsync();

            return Ok(new { imageUrl = user.ProfileImage });
        }
    }

    // ✅ [JsonPropertyName] maps lowercase JSON keys → C# properties
    public class ProfileUpdateDto
    {
        [JsonPropertyName("fullname")]
        public string? Fullname { get; set; }

        [JsonPropertyName("phone")]
        public string? Phone { get; set; }

        [JsonPropertyName("email")]
        public string? Email { get; set; }
    }
}