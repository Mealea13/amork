namespace AmorkApp.Models;
public class Promotion
{
    public int PromotionId { get; set; }
    public Guid UserId { get; set; }
    public int FoodId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public bool IsActive {get; set;}

    public DateTime? ValidUntil {get; set;}

    public string Code { get; set; } = string.Empty;
    public decimal DiscountPercent { get; set; }
}