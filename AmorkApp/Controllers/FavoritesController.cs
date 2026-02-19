using AmorkApp.Data;
using AmorkApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.Text.Json.Serialization;

namespace AmorkApp.Controllers;

[ApiController]
[Route("api/favorites")]
[Authorize]
public class FavoritesController : ControllerBase
{
    private readonly AmorkDbContext _context;

    public FavoritesController(AmorkDbContext context)
    {
        _context = context;
    }

    // GET /api/favorites
    [HttpGet]
    public async Task<IActionResult> GetFavorites()
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var favorites = await _context.Favorites
            .Where(f => f.UserId == userId)
            .Join(_context.Foods,
                fav  => fav.FoodId,
                food => food.FoodId,
                (fav, food) => new
                {
                    favoriteId    = fav.FavoriteId,
                    foodId        = food.FoodId,
                    foodName      = food.Name,
                    description   = food.Description,
                    price         = food.Price,
                    originalPrice = food.OriginalPrice,
                    imageUrl      = food.ImageUrl,
                    calories      = food.Calories,
                    cookingTime   = food.Time,
                    rating        = food.Rating,
                    categoryId    = food.CategoryId,
                    createdAt     = fav.CreatedAt,
                })
            .OrderByDescending(f => f.createdAt)
            .ToListAsync();

        return Ok(favorites);
    }

    // POST /api/favorites/add
    [HttpPost("add")]
    public async Task<IActionResult> AddFavorite([FromBody] FavoriteRequest request)
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var food = await _context.Foods.FindAsync(request.FoodId);
        if (food == null) return NotFound(new { message = "Food not found" });

        var exists = await _context.Favorites
            .AnyAsync(f => f.UserId == userId && f.FoodId == request.FoodId);
        if (exists) return Ok(new { message = "Already in favorites" });

        var favorite = new Favorite
        {
            FavoriteId = Guid.NewGuid(),
            UserId     = userId.Value,
            FoodId     = request.FoodId,
            CreatedAt  = DateTime.UtcNow,
        };

        _context.Favorites.Add(favorite);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Added to favorites ❤️" });
    }

    // DELETE /api/favorites/remove/{foodId}
    [HttpDelete("remove/{foodId}")]
    public async Task<IActionResult> RemoveFavorite(int foodId)
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var favorite = await _context.Favorites
            .FirstOrDefaultAsync(f => f.UserId == userId && f.FoodId == foodId);
        if (favorite == null) return NotFound(new { message = "Not in favorites" });

        _context.Favorites.Remove(favorite);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Removed from favorites" });
    }

    // GET /api/favorites/check/{foodId}
    [HttpGet("check/{foodId}")]
    public async Task<IActionResult> CheckFavorite(int foodId)
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var isFavorite = await _context.Favorites
            .AnyAsync(f => f.UserId == userId && f.FoodId == foodId);
        return Ok(new { isFavorite });
    }

    private Guid? GetUserIdFromToken()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)
                 ?? User.FindFirst("sub")
                 ?? User.FindFirst("userId");
        if (claim == null) return null;
        return Guid.TryParse(claim.Value, out var guid) ? guid : null;
    }
}

public class FavoriteRequest
{
    [JsonPropertyName("food_id")]
    public int FoodId { get; set; }
}