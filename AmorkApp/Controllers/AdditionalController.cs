using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Data;
using AmorkApp.Models;

namespace AmorkApp.Controllers
{
    // ==============================================
    // 1. FAVORITES CONTROLLER
    // ==============================================
    [ApiController]
    [Route("api/[controller]")]
    public class FavoritesController : ControllerBase
    {
        private readonly AmorkDbContext _context;

        public FavoritesController(AmorkDbContext context)
        {
            _context = context;
        }

        // GET: api/favorites/{userId}
        [HttpGet("{userId}")]
        public async Task<IActionResult> GetUserFavorites(Guid userId)
        {
            var favorites = await _context.Favorites // Fixed: uppercase 'Favorites'
                .Where(f => f.UserId == userId)
                .Select(f => new
                {
                    f.FavoriteId,
                    f.FoodId,
                    f.CreatedAt,
                    Food = _context.Foods.FirstOrDefault(food => food.FoodId == f.FoodId) // Fixed: uppercase 'Foods'
                })
                .ToListAsync();

            return Ok(favorites);
        }

        // POST: api/favorites/add
        [HttpPost("add")]
        public async Task<IActionResult> AddToFavorites([FromBody] Favorite favorite)
        {
            var exists = await _context.Favorites
                .AnyAsync(f => f.UserId == favorite.UserId && f.FoodId == favorite.FoodId);

            if (exists)
                return BadRequest(new { message = "Already in favorites" });

            _context.Favorites.Add(favorite);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Added to favorites" });
        }

        // DELETE: api/favorites/remove/{favoriteId}
        [HttpDelete("remove/{favoriteId}")]
        public async Task<IActionResult> RemoveFromFavorites(Guid favoriteId) // Changed to Guid to match your PostgreSQL schema
        {
            var favorite = await _context.Favorites.FindAsync(favoriteId);
            if (favorite == null) return NotFound();

            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Removed from favorites" });
        }

        // DELETE: api/favorites/remove/{userId}/{foodId}
        [HttpDelete("remove/{userId}/{foodId}")]
        public async Task<IActionResult> RemoveByUserAndFood(Guid userId, int foodId)
        {
            var favorite = await _context.Favorites
                .FirstOrDefaultAsync(f => f.UserId == userId && f.FoodId == foodId);
            if (favorite == null) return NotFound();

            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Removed from favorites" });
        }
    }

    // ==============================================
    // 2. REVIEWS CONTROLLER
    // ==============================================
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewsController : ControllerBase
    {
        private readonly AmorkDbContext _context;

        public ReviewsController(AmorkDbContext context)
        {
            _context = context;
        }

        // GET: api/reviews/food/{foodId}
        [HttpGet("food/{foodId}")]
        public async Task<IActionResult> GetFoodReviews(int foodId)
        {
            var reviews = await _context.Reviews
                .Where(r => r.FoodId == foodId)
                .OrderByDescending(r => r.CreatedAt)
                .Select(r => new
                {
                    r.ReviewId,
                    r.Rating,
                    r.Comment,
                    r.CreatedAt,
                    User = _context.Users
                        .Where(u => u.UserId == r.UserId)
                        .Select(u => new { u.Fullname })
                        .FirstOrDefault()
                })
                .ToListAsync();

            var averageRating = reviews.Any() ? reviews.Average(r => r.Rating) : 0;

            return Ok(new { reviews, averageRating });
        }

        // POST: api/reviews/submit
        [HttpPost("submit")]
        public async Task<IActionResult> SubmitReview([FromBody] Review review)
        {
            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.UserId == review.UserId && r.FoodId == review.FoodId);

            if (existingReview != null)
            {
                existingReview.Rating = review.Rating;
                existingReview.Comment = review.Comment;
                existingReview.CreatedAt = DateTime.UtcNow;
            }
            else
            {
                _context.Reviews.Add(review);
            }

            await _context.SaveChangesAsync();
            var avgRating = await _context.Reviews
                .Where(r => r.FoodId == review.FoodId)
                .AverageAsync(r => (decimal)r.Rating);

            var food = await _context.Foods.FindAsync(review.FoodId); // Fixed: uppercase 'Foods'
            if (food != null)
            {
                food.Rating = avgRating;
                await _context.SaveChangesAsync();
            }

            return Ok(new { message = "Review submitted successfully" });
        }

        // DELETE: api/reviews/{reviewId}
        [HttpDelete("{reviewId}")]
        public async Task<IActionResult> DeleteReview(Guid reviewId) // Changed to Guid to match your PostgreSQL schema
        {
            var review = await _context.Reviews.FindAsync(reviewId);
            if (review == null) return NotFound();

            _context.Reviews.Remove(review);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Review deleted" });
        }
    }

    // ==============================================
    // 3. PROMOTIONS CONTROLLER
    // ==============================================
    [ApiController]
    [Route("api/[controller]")]
    public class PromotionsController : ControllerBase
    {
        private readonly AmorkDbContext _context;

        public PromotionsController(AmorkDbContext context)
        {
            _context = context;
        }

        /* * Note: Ensure your 'Promotion' model in Models/Promotion.cs 
         * has the properties 'Code', 'ValidUntil', and 'DiscountPercent'
         * for this to compile perfectly!
         */

        // GET: api/promotions/active
        [HttpGet("active")]
        public async Task<IActionResult> GetActivePromotions()
        {
            // Assuming your Promotion model has IsActive and ValidUntil
            var promos = await _context.Promotions
                .Where(p => p.IsActive) 
                .ToListAsync();

            return Ok(promos);
        }

        // POST: api/promotions/validate
        [HttpPost("validate")]
        public async Task<IActionResult> ValidatePromoCode([FromBody] ValidatePromoRequest request)
        {
            var promo = await _context.Promotions
                .FirstOrDefaultAsync(p => p.Code == request.Code && p.IsActive);

            if (promo == null)
                return BadRequest(new { message = "Invalid or expired promo code" });

            var discount = request.OrderAmount * (promo.DiscountPercent / 100);

            return Ok(new
            {
                message = "Promo code is valid",
                discountPercent = promo.DiscountPercent,
                discountAmount = discount,
                newTotal = request.OrderAmount - discount
            });
        }

        // POST: api/promotions/create
        [HttpPost("create")]
        public async Task<IActionResult> CreatePromotion([FromBody] Promotion promo)
        {
            _context.Promotions.Add(promo);
            await _context.SaveChangesAsync();
            return Ok(new { message = "Promotion created successfully" });
        }
    }

    // ==============================================
    // DTOs
    // ==============================================
    public class ValidatePromoRequest
    {
        public string Code { get; set; } = string.Empty;
        public decimal OrderAmount { get; set; }
    }
}