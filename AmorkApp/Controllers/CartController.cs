using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;

namespace AmorkApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CartController : ControllerBase
{
    private readonly AmorkDbContext _context;

    public CartController(AmorkDbContext context)
    {
        _context = context;
    }

    // GET: api/cart/{userId}
    [HttpGet("{userId}")]
    public async Task<IActionResult> GetCart(Guid userId)
    {
        var cartItems = await _context.CartItem
            .Where(c => c.UserId == userId)
            .Select(c => new
            {
                c.CartItemId,
                c.FoodId,
                c.Quantity,
                Food = _context.foods.FirstOrDefault(f => f.FoodId == c.FoodId)
            })
            .ToListAsync();

        var total = cartItems.Sum(item =>
            (item.Food != null ? item.Food.Price : 0) * item.Quantity);

        return Ok(new { cartItems, total });
    }

    // POST: api/cart/add
    [HttpPost("add")]
    public async Task<IActionResult> AddToCart([FromBody] Cart cartItem)
    {
        // Check if item already exists in cart
        var existingItem = await _context.CartItem
            .FirstOrDefaultAsync(c => c.UserId == cartItem.UserId && c.FoodId == cartItem.FoodId);

        if (existingItem != null)
        {
            // Update quantity if item exists
            existingItem.Quantity += cartItem.Quantity;
        }
        else
        {
            // Add new item to cart
            _context.CartItem.Add(cartItem);
        }

        await _context.SaveChangesAsync();
        return Ok(new { message = "Item added to cart successfully" });
    }

    // PUT: api/cart/update/{cartItemId}
    [HttpPut("update/{cartItemId}")]
    public async Task<IActionResult> UpdateQuantity(int cartItemId, [FromBody] UpdateQuantityRequest request)
    {
        var cartItem = await _context.CartItem.FindAsync(cartItemId);
        if (cartItem == null) return NotFound();

        cartItem.Quantity = request.Quantity;
        await _context.SaveChangesAsync();
        return Ok(new { message = "Quantity updated successfully" });
    }

    // DELETE: api/cart/remove/{cartItemId}
    [HttpDelete("remove/{cartItemId}")]
    public async Task<IActionResult> RemoveFromCart(int cartItemId)
    {
        var cartItem = await _context.CartItem.FindAsync(cartItemId);
        if (cartItem == null) return NotFound();

        _context.CartItem.Remove(cartItem);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Item removed from cart" });
    }

    // DELETE: api/cart/clear/{userId}
    [HttpDelete("clear/{userId}")]
    public async Task<IActionResult> ClearCart(Guid userId)
    {
        var cartItems = await _context.CartItem
            .Where(c => c.UserId == userId)
            .ToListAsync();

        _context.CartItem.RemoveRange(cartItems);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Cart cleared successfully" });
    }
}

public class UpdateQuantityRequest
{
    public int Quantity { get; set; }
}