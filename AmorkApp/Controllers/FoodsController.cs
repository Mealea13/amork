using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;

namespace AmorkApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FoodsController : ControllerBase
{
    private readonly AmorkDbContext _context;

    public FoodsController(AmorkDbContext context)
    {
        _context = context;
    }

    // GET /api/foods?page=1&limit=20&category=food&search=
    [HttpGet]
    public async Task<IActionResult> GetFoods(
        [FromQuery] int? categoryId,
        [FromQuery] string? category,   // supports ?category=food (name-based)
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int limit = 20)
    {
        var query = _context.Foods.AsQueryable();

        // Filter by categoryId number (e.g. ?categoryId=1)
        if (categoryId.HasValue)
        {
            query = query.Where(f => f.CategoryId == categoryId.Value);
        }

        // Filter by category name (e.g. ?category=food)
        if (!string.IsNullOrEmpty(category))
        {
            var cat = await _context.Categories
                .FirstOrDefaultAsync(c => c.Name.ToLower() == category.ToLower());

            if (cat != null)
            {
                query = query.Where(f => f.CategoryId == cat.Id);
            }
        }

        // Filter by search keyword
        if (!string.IsNullOrEmpty(search))
        {
            query = query.Where(f =>
                f.Name.Contains(search) ||
                (f.Description != null && f.Description.Contains(search)));
        }

        // Only show available foods
        query = query.Where(f => f.IsAvailable);

        // Pagination
        var totalItems = await query.CountAsync();
        var foods = await query
            .Skip((page - 1) * limit)
            .Take(limit)
            .ToListAsync();

        return Ok(new
        {
            total = totalItems,
            page,
            limit,
            data = foods
        });
    }

    // GET /api/foods/popular
    [HttpGet("popular")]
    public async Task<IActionResult> GetPopular()
    {
        var foods = await _context.Foods
            .Where(f => f.IsPopular && f.IsAvailable)
            .ToListAsync();

        if (!foods.Any())
            foods = await _context.Foods.Where(f => f.IsAvailable).Take(10).ToListAsync();

        return Ok(foods);
    }

    // GET /api/foods/5
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var food = await _context.Foods.FindAsync(id);
        if (food == null) return NotFound(new { message = "Food item not found" });
        return Ok(food);
    }

    // POST /api/foods/add-to-cart
    [HttpPost("add-to-cart")]
    public async Task<IActionResult> AddToCart([FromBody] Cart item)
    {
        var foodExists = await _context.Foods.AnyAsync(f => f.FoodId == item.FoodId);
        if (!foodExists) return BadRequest(new { message = "This food no longer exists." });

        _context.CartItems.Add(item);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Added to cart successfully!" });
    }

    // POST /api/foods
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Food food)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        _context.Foods.Add(food);
        await _context.SaveChangesAsync();
        return CreatedAtAction(nameof(GetById), new { id = food.FoodId }, food);
    }

    // PUT /api/foods/5
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] Food foodData)
    {
        var food = await _context.Foods.FindAsync(id);
        if (food == null) return NotFound();

        food.Name        = foodData.Name;
        food.Price       = foodData.Price;
        food.Description = foodData.Description;
        food.ImageUrl    = foodData.ImageUrl;
        food.CategoryId  = foodData.CategoryId;
        food.Calories    = foodData.Calories;
        food.Time        = foodData.Time;
        food.Rating      = foodData.Rating;
        food.IsPopular   = foodData.IsPopular;
        food.IsAvailable = foodData.IsAvailable;

        await _context.SaveChangesAsync();
        return Ok(new { message = "Food updated successfully!" });
    }

    // DELETE /api/foods/5
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var food = await _context.Foods.FindAsync(id);
        if (food == null) return NotFound();

        _context.Foods.Remove(food);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Food deleted successfully!" });
    }
}