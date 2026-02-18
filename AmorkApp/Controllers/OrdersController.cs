using AmorkApp.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using AmorkApp.Models;
using System.Security.Claims;
using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Authorization;

namespace AmorkApp.Controllers;

[ApiController]
[Route("api/orders")]
[Authorize]
public class OrdersController : ControllerBase
{
    private readonly AmorkDbContext _context;

    public OrdersController(AmorkDbContext context)
    {
        _context = context;
    }

    // POST /api/orders
    [HttpPost]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var orderNumber = $"AMK{DateTime.UtcNow:MMddHHmmss}";
        var subtotal = request.Items?.Sum(i => i.Price * i.Quantity) ?? request.Total;

        var order = new Order
        {
            OrderId       = Guid.NewGuid(),
            UserId        = userId.Value,
            OrderNumber   = orderNumber,
            Status        = "confirmed",
            PaymentMethod = request.PaymentMethod ?? "cash_on_delivery",
            PaymentStatus = "paid",
            DeliveryStreet = request.DeliveryAddress,
            DeliveryPhone  = request.Phone,
            Note           = request.Notes,
            Subtotal       = subtotal,
            DeliveryFee    = 1.00,
            Tax            = 0.00,
            Discount       = 0.00,
            Total          = subtotal + 1.00,
            CreatedAt      = DateTime.UtcNow,
            UpdatedAt      = DateTime.UtcNow,
            OrderItems     = request.Items?.Select(i => new OrderItem
            {
                OrderItemId          = Guid.NewGuid(),
                FoodId               = i.FoodId,
                FoodName             = i.FoodName ?? "",
                Quantity             = i.Quantity,
                UnitPrice            = i.Price,
                Subtotal             = i.Price * i.Quantity,
                SpecialInstructions  = i.SpecialInstructions,
            }).ToList() ?? new List<OrderItem>()
        };

        _context.Orders.Add(order);
        await _context.SaveChangesAsync();

        return Ok(new
        {
            message = "Order created successfully",
            orderId = order.OrderId,
            orderNumber = order.OrderNumber,
            total = order.Total,
            status = order.Status
        });
    }

    // GET /api/orders
    [HttpGet]
    public async Task<IActionResult> GetOrders()
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var orders = await _context.Orders
            .Include(o => o.OrderItems)
            .Where(o => o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .Select(o => new
            {
                orderId       = o.OrderId,
                orderNumber   = o.OrderNumber,
                status        = o.Status,
                totalAmount   = o.Total,
                paymentMethod = o.PaymentMethod,
                paymentStatus = o.PaymentStatus,
                createdAt     = o.CreatedAt,
                orderItems    = o.OrderItems.Select(i => new
                {
                    foodId    = i.FoodId,
                    foodName  = i.FoodName,
                    quantity  = i.Quantity,
                    price     = i.UnitPrice,
                    subtotal  = i.Subtotal,
                }).ToList()
            })
            .ToListAsync();

        return Ok(orders);
    }

    // GET /api/orders/{id}
    [HttpGet("{id}")]
    public async Task<IActionResult> GetOrderById(Guid id)
    {
        var userId = GetUserIdFromToken();
        if (userId == null) return Unauthorized();

        var order = await _context.Orders
            .Include(o => o.OrderItems)
            .Where(o => o.OrderId == id && o.UserId == userId)
            .Select(o => new
            {
                orderId       = o.OrderId,
                orderNumber   = o.OrderNumber,
                status        = o.Status,
                totalAmount   = o.Total,
                subtotal      = o.Subtotal,
                deliveryFee   = o.DeliveryFee,
                tax           = o.Tax,
                paymentMethod = o.PaymentMethod,
                createdAt     = o.CreatedAt,
                items         = o.OrderItems.Select(i => new
                {
                    foodId   = i.FoodId,
                    foodName = i.FoodName,
                    quantity = i.Quantity,
                    price    = i.UnitPrice,
                    subtotal = i.Subtotal,
                }).ToList()
            })
            .FirstOrDefaultAsync();

        if (order == null) return NotFound(new { message = "Order not found" });
        return Ok(order);
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

public class CreateOrderRequest
{
    [JsonPropertyName("total")]           public double Total { get; set; }
    [JsonPropertyName("payment_method")]  public string? PaymentMethod { get; set; }
    [JsonPropertyName("delivery_address")]public string? DeliveryAddress { get; set; }
    [JsonPropertyName("phone")]           public string? Phone { get; set; }
    [JsonPropertyName("notes")]           public string? Notes { get; set; }
    [JsonPropertyName("items")]           public List<OrderItemRequest>? Items { get; set; }
}

public class OrderItemRequest
{
    [JsonPropertyName("food_id")]              public int FoodId { get; set; }
    [JsonPropertyName("food_name")]            public string? FoodName { get; set; }
    [JsonPropertyName("quantity")]             public int Quantity { get; set; }
    [JsonPropertyName("price")]                public double Price { get; set; }
    [JsonPropertyName("special_instructions")] public string? SpecialInstructions { get; set; }
}