using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

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

    // 1. GET: Fetch foods
    [HttpGet("popular")]
    public async Task<IActionResult> GetPopular()
    {
        var foods = await _context.Foods.ToListAsync();
        return Ok(foods);
    }

    // 2. POST: Add new food
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Food food)
    {
        if (food == null) return BadRequest();

        _context.Foods.Add(food);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Successfully added!" });
    }

    // 3. PUT: Update food
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] Food foodData)
    {
        var food = await _context.Foods.FindAsync(id);
        if (food == null) return NotFound();
        food.FoodName = foodData.FoodName;
        food.Price = foodData.Price;
        await _context.SaveChangesAsync();
        return Ok(new { message = "Updated successfully!" });
    }

    // 4. DELETE: Remove food
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var food = await _context.Foods.FindAsync(id);
        if (food == null) return NotFound();
        _context.Foods.Remove(food);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Deleted successfully!" });
    }
}