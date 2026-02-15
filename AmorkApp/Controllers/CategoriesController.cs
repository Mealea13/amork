//AmorkApp/Controllers/CategoriesController.cs

using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;

namespace AmorkApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriesController : ControllerBase
{
    private readonly AmorkDbContext _context;

    public CategoriesController(AmorkDbContext context)
    {
        _context = context;
    }

    // GET: api/categories
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var categories = await _context.Categories.ToListAsync();
        return Ok(categories);
    }

    // GET: api/categories/{id}
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(int id)
    {
        var category = await _context.Categories.FindAsync(id);
        if (category == null) return NotFound();
        return Ok(category);
    }

    [HttpGet("{id}/foods")]
    public async Task<IActionResult> GetFoodsByCategory(int id)
    {
        var foods = await _context.foods
            .Where(f => f.CategoryId == id)
            .ToListAsync();
        return Ok(foods);
    }

    // POST: api/categories
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] Category category) // Changed to Category
    {
        _context.Categories.Add(category);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Category created successfully", category });
    }

    // PUT: api/categories/{id}
    [HttpPut("{id}")]
    public async Task<IActionResult> Update(int id, [FromBody] Category categoryData) // Changed to Category
    {
        var category = await _context.Categories.FindAsync(id);
        if (category == null) return NotFound();

        // Updated to match the properties in our new Category model
        category.Name = categoryData.Name;
        category.Icon = categoryData.Icon;
        category.Color = categoryData.Color;

        await _context.SaveChangesAsync();
        return Ok(new { message = "Category updated successfully" });
    }

    // DELETE: api/categories/{id}
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var category = await _context.Categories.FindAsync(id);
        if (category == null) return NotFound();

        _context.Categories.Remove(category);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Category deleted successfully" });
    }
}