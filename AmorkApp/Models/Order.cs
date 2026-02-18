using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AmorkApp.Models;

[Table("orders")]
public class Order
{
    [Key]
    [Column("order_id")]
    public Guid OrderId { get; set; } = Guid.NewGuid();

    [Required]
    [Column("user_id")]
    public Guid UserId { get; set; }

    [Column("order_number")]
    public string OrderNumber { get; set; } = $"AMK-{DateTime.UtcNow:yyyyMMddHHmmss}";

    [Column("status")]
    public string Status { get; set; } = "confirmed";

    [Column("payment_method")]
    public string PaymentMethod { get; set; } = "cash_on_delivery";

    [Column("payment_status")]
    public string PaymentStatus { get; set; } = "paid";

    [Column("delivery_street")]
    public string? DeliveryStreet { get; set; }

    [Column("delivery_city")]
    public string? DeliveryCity { get; set; }

    [Column("delivery_phone")]
    public string? DeliveryPhone { get; set; }

    [Column("note")]
    public string? Note { get; set; }

    [Column("subtotal")]
    public double Subtotal { get; set; }

    [Column("delivery_fee")]
    public double DeliveryFee { get; set; } = 1.00;

    [Column("tax")]
    public double Tax { get; set; } = 0.00;

    [Column("discount")]
    public double Discount { get; set; } = 0.00;

    [Column("total")]
    public double Total { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public List<OrderItem> OrderItems { get; set; } = new();
}

[Table("order_items")]
public class OrderItem
{
    [Key]
    [Column("order_item_id")]
    public Guid OrderItemId { get; set; } = Guid.NewGuid();

    [Column("order_id")]
    public Guid OrderId { get; set; }

    [Column("food_id")]
    public int FoodId { get; set; }

    [Column("food_name")]
    public string FoodName { get; set; } = string.Empty;

    [Column("quantity")]
    public int Quantity { get; set; }

    [Column("unit_price")]
    public double UnitPrice { get; set; }

    [Column("subtotal")]
    public double Subtotal { get; set; }

    [Column("special_instructions")]
    public string? SpecialInstructions { get; set; }
}