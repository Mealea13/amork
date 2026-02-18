using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;
using System.Security.Claims;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authorization;

namespace AmorkApp.Controllers;

[ApiController]
[Authorize]
[Route("api/cart")]
public class CartController : ControllerBase
{
    private readonly AmorkDbContext _context;

    public CartController(AmorkDbContext context)
    {
        _context = context;
    }

    // GET /api/cart
    [HttpGet]
    public async Task<IActionResult> GetCart()
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized(new { message = "Invalid or missing token" });

        var cartItems = await _context.CartItems
            .Where(c => c.UserId == userId)
            .Select(c => new
            {
                id             = c.CartItemId,
                cart_item_id   = c.CartItemId,
                food_id        = c.FoodId,
                quantity       = c.Quantity,
                special_instructions = c.SpecialInstructions,
                food_name      = _context.Foods.Where(f => f.FoodId == c.FoodId).Select(f => f.Name).FirstOrDefault(),
                price          = _context.Foods.Where(f => f.FoodId == c.FoodId).Select(f => f.Price).FirstOrDefault(),
                original_price = _context.Foods.Where(f => f.FoodId == c.FoodId).Select(f => f.OriginalPrice).FirstOrDefault(),
                image_url      = _context.Foods.Where(f => f.FoodId == c.FoodId).Select(f => f.ImageUrl).FirstOrDefault(),
                calories       = _context.Foods.Where(f => f.FoodId == c.FoodId).Select(f => f.Calories).FirstOrDefault(),
                cooking_time   = _context.Foods.Where(f => f.FoodId == c.FoodId).Select(f => f.Time).FirstOrDefault(),
            })
            .ToListAsync();

        var total = cartItems.Sum(item => item.price * item.quantity);

        return Ok(new { items = cartItems, total });
    }

    // POST /api/cart/add
    [HttpPost("add")]
    public async Task<IActionResult> AddToCart([FromBody] AddToCartRequest request)
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized(new { message = "User not identified" });

        if (request.FoodId <= 0) return BadRequest(new { message = "Valid food_id is required" });

        var food = await _context.Foods.FindAsync(request.FoodId);
        if (food == null) return NotFound(new { message = "Food item does not exist" });

        // If item already in cart, just increase quantity
        var existingItem = await _context.CartItems
            .FirstOrDefaultAsync(c => c.UserId == userId && c.FoodId == request.FoodId);

        if (existingItem != null)
        {
            existingItem.Quantity += request.Quantity > 0 ? request.Quantity : 1;
            existingItem.UpdatedAt = DateTime.UtcNow;
            _context.CartItems.Update(existingItem);
        }
        else
        {
            var newItem = new Cart
            {
                CartItemId           = Guid.NewGuid(),
                UserId               = userId.Value,
                FoodId               = request.FoodId,
                Quantity             = request.Quantity > 0 ? request.Quantity : 1,
                SpecialInstructions  = request.SpecialInstructions,
                CreatedAt            = DateTime.UtcNow,
                UpdatedAt            = DateTime.UtcNow
            };
            _context.CartItems.Add(newItem);
        }

        await _context.SaveChangesAsync();
        return Ok(new { message = "Item added to cart successfully" });
    }

    // PUT /api/cart/{cartItemId}
    [HttpPut("{cartItemId}")]
    public async Task<IActionResult> UpdateQuantity(Guid cartItemId, [FromBody] UpdateQuantityRequest request)
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var cartItem = await _context.CartItems
            .FirstOrDefaultAsync(c => c.CartItemId == cartItemId && c.UserId == userId);
        if (cartItem == null) return NotFound(new { message = "Cart item not found" });

        cartItem.Quantity  = request.Quantity;
        cartItem.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
        return Ok(new { message = "Quantity updated successfully" });
    }

    // DELETE /api/cart/{cartItemId}
    [HttpDelete("{cartItemId}")]
    public async Task<IActionResult> RemoveFromCart(Guid cartItemId)
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var cartItem = await _context.CartItems
            .FirstOrDefaultAsync(c => c.CartItemId == cartItemId && c.UserId == userId);
        if (cartItem == null) return NotFound();

        _context.CartItems.Remove(cartItem);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Item removed from cart" });
    }

    // DELETE /api/cart/clear
    [HttpDelete("clear")]
    public async Task<IActionResult> ClearCart()
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var cartItems = await _context.CartItems.Where(c => c.UserId == userId).ToListAsync();
        _context.CartItems.RemoveRange(cartItems);
        await _context.SaveChangesAsync();
        return Ok(new { message = "Cart cleared successfully" });
    }

    private Guid? GetUserIdFromToken()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier)
                 ?? User.FindFirst("sub")
                 ?? User.FindFirst("userId")
                 ?? User.FindFirst("id");

        if (claim == null) return null;
        return Guid.TryParse(claim.Value, out var guid) ? guid : null;
    }
}

public class AddToCartRequest
{
    [JsonPropertyName("food_id")]
    public int FoodId { get; set; }

    [JsonPropertyName("quantity")]
    public int Quantity { get; set; } = 1;

    [JsonPropertyName("special_instructions")]
    public string? SpecialInstructions { get; set; }

    [JsonPropertyName("additional_ingredients")]
    public List<AdditionalIngredientRequest>? AdditionalIngredients { get; set; }
}

public class AdditionalIngredientRequest
{
    [JsonPropertyName("ingredient_id")]
    public int? IngredientId { get; set; }

    [JsonPropertyName("name")]
    public string? Name { get; set; }

    [JsonPropertyName("price")]
    public double Price { get; set; }
}

public class UpdateQuantityRequest
{
    [JsonPropertyName("quantity")]
    public int Quantity { get; set; }
}