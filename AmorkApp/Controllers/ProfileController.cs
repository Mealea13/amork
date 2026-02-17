using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Data;
using AmorkApp.Models;

namespace AmorkApp.Controllers
{
    [ApiController]
    [Route("api/[controller]")] // This makes the base URL: /api/profile
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

            return Ok(new
            {
                user.UserId,
                user.Fullname,
                user.Email,
                user.Phone,
                user.MemberType,
                // Return the path so Flutter can find it in wwwroot
                profile_image = user.ProfileImage 
            });
        }

        // PUT: api/profile/{userId}
        [HttpPut("{userId}")]
        public async Task<IActionResult> UpdateProfile(Guid userId, [FromBody] ProfileUpdateDto request)
        {
            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound(new { message = "User not found" });

            user.Fullname = request.Fullname ?? user.Fullname;
            user.Phone = request.Phone ?? user.Phone;
            user.Email = request.Email ?? user.Email;
            user.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();
            return Ok(new { message = "Profile updated successfully" });
        }

        // POST: api/profile/upload-image/{userId}
        [HttpPost("upload-image/{userId}")]
        public async Task<IActionResult> UploadProfileImage(Guid userId, IFormFile image)
        {
            if (image == null || image.Length == 0) return BadRequest("No image provided");

            var user = await _context.Users.FindAsync(userId);
            if (user == null) return NotFound("User not found");

            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "profiles");
            if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

            var fileName = $"{userId}_{DateTime.UtcNow.Ticks}{Path.GetExtension(image.FileName)}";
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await image.CopyToAsync(stream);
            }

            user.ProfileImage = $"/uploads/profiles/{fileName}";
            user.UpdatedAt = DateTime.UtcNow;
            
            await _context.SaveChangesAsync();
            return Ok(new { imageUrl = user.ProfileImage });
        }
    }

    public class ProfileUpdateDto {
        public string? Fullname { get; set; }
        public string? Phone { get; set; }
        public string? Email { get; set; }
    }
}