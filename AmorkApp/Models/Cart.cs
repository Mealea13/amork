using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AmorkApp.Models;

[Table("cart_items")]
public class Cart
{
    [Key]
    [Column("cart_item_id")]
    public Guid CartItemId { get; set; }

    [Column("user_id")]
    public Guid UserId { get; set; }

    [Column("food_id")]
    public int FoodId { get; set; }

    [Column("quantity")]
    public int Quantity { get; set; }

    [Column("special_instructions")]
    public string? SpecialInstructions { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; }
}