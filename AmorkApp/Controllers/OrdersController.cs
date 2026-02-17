using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;

namespace AmorkApp.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly AmorkDbContext _context;

    public OrdersController(AmorkDbContext context)
    {
        _context = context;
    }

    // GET: api/orders/user/{userId}
    [HttpGet("user/{userId}")]
    public async Task<IActionResult> GetUserOrders(Guid userId)
    {
        var orders = await _context.Orders
            .Where(o => o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .Select(o => new
            {
                o.OrderId,
                o.TotalAmount,
                o.Status,
                o.DeliveryAddress,
                o.CreatedAt,
                ItemCount = _context.Orders.Count(oi => oi.OrderId == o.OrderId)
            })
            .ToListAsync();

        return Ok(orders);
    }

    // GET: api/orders/{orderId}
    [HttpGet("{orderId}")]
    public async Task<IActionResult> GetOrderDetails(int orderId)
    {
        var order = await _context.Orders.FindAsync(orderId);
        if (order == null) return NotFound();

        var items = await _context.Orders
            .Where(oi => oi.OrderId == orderId)
            .ToListAsync();

        return Ok(new { order, items });
    }

    // POST: api/orders/place
    [HttpPost("place")]
    public async Task<IActionResult> PlaceOrder([FromBody] PlaceOrderRequest request)
    {
        // Get user's cart items
        var cartItems = await _context.CartItems
            .Where(c => c.UserId == request.UserId)
            .ToListAsync();

        if (!cartItems.Any())
            return BadRequest(new { message = "Cart is empty" });

        // Calculate total
        double totalAmount = 0;
        var orderItems = new List<Order>();

        foreach (var cartItem in cartItems)
        {
            var food = await _context.Foods.FindAsync(cartItem.FoodId);
            if (food != null)
            {
                totalAmount += food.Price * cartItem.Quantity;
                orderItems.Add(new Order
                {
                    FoodId = food.FoodId,
                    FoodName = food.Name,
                    Quantity = cartItem.Quantity,
                    Price = food.Price
                });
            }
        }

        // Create order
        var order = new Order
        {
            UserId = request.UserId,
            TotalAmount = totalAmount,
            DeliveryAddress = request.DeliveryAddress,
            Phone = request.Phone,
            Notes = request.Notes,
            Status = "pending"
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        // Add order items
        foreach (var item in orderItems)
        {
            item.OrderId = order.OrderId;
        }
        _context.Orders.AddRange(orderItems);

        // Clear cart
        _context.CartItems.RemoveRange(cartItems);
        await _context.SaveChangesAsync();

        return Ok(new { message = "Order placed successfully", orderId = order.OrderId });
    }

    // PUT: api/orders/{orderId}/status
    [HttpPut("{orderId}/status")]
    public async Task<IActionResult> UpdateOrderStatus(int orderId, [FromBody] UpdateStatusRequest request)
    {
        var order = await _context.Orders.FindAsync(orderId);
        if (order == null) return NotFound();

        order.Status = request.Status;
        await _context.SaveChangesAsync();
        return Ok(new { message = "Order status updated" });
    }

    // DELETE: api/orders/{orderId}
    [HttpDelete("{orderId}")]
    public async Task<IActionResult> CancelOrder(int orderId)
    {
        var order = await _context.Orders.FindAsync(orderId);
        if (order == null) return NotFound();

        if (order.Status == "delivering" || order.Status == "completed")
            return BadRequest(new { message = "Cannot cancel order in this status" });

        order.Status = "cancelled";
        await _context.SaveChangesAsync();
        return Ok(new { message = "Order cancelled successfully" });
    }
}

public class PlaceOrderRequest
{
    public Guid UserId { get; set; }
    public string? DeliveryAddress { get; set; }
    public string? Phone { get; set; }
    public string? Notes { get; set; }
}

public class UpdateStatusRequest
{
    public string Status { get; set; } = string.Empty;
}