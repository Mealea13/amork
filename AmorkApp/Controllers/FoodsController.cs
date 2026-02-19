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

    // GET /api/foods?page=1&limit=20&categoryId=1&search=burger
    [HttpGet]
    public async Task<IActionResult> GetFoods(
        [FromQuery] int? categoryId,
        [FromQuery] string? category,
        [FromQuery] string? search,
        [FromQuery] int page = 1,
        [FromQuery] int limit = 20)
    {
        var query = _context.Foods.AsQueryable();

        if (categoryId.HasValue)
            query = query.Where(f => f.CategoryId == categoryId.Value);

        if (!string.IsNullOrEmpty(category))
        {
            var cat = await _context.Categories
                .FirstOrDefaultAsync(c => c.Name.ToLower() == category.ToLower());
            if (cat != null)
                query = query.Where(f => f.CategoryId == cat.Id);
        }

        if (!string.IsNullOrEmpty(search))
            query = query.Where(f =>
                f.Name.ToLower().Contains(search.ToLower()) ||
                (f.Description != null && f.Description.ToLower().Contains(search.ToLower())));

        query = query.Where(f => f.IsAvailable);

        var totalItems = await query.CountAsync();
        var foods = await query
            .Skip((page - 1) * limit)
            .Take(limit)
            .ToListAsync();

        return Ok(new { total = totalItems, page, limit, data = foods });
    }

    // GET /api/foods/search?q=burger
    [HttpGet("search")]
    public async Task<IActionResult> Search([FromQuery] string? q)
    {
        if (string.IsNullOrWhiteSpace(q))
            return Ok(new List<object>());

        var results = await _context.Foods
            .Where(f => f.IsAvailable &&
                (f.Name.ToLower().Contains(q.ToLower()) ||
                 (f.Description != null && f.Description.ToLower().Contains(q.ToLower()))))
            .ToListAsync();

        return Ok(results);
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

    // GET /api/foods/{id}
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var food = await _context.Foods.FindAsync(id);
        if (food == null) return NotFound(new { message = "Food item not found" });
        return Ok(food);
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

    // PUT /api/foods/{id}
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

    // DELETE /api/foods/{id}
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