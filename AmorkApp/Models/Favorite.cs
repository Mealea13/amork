namespace AmorkApp.Models;
public class Favorite
{
    public int FavoriteId { get; set; }
    public Guid UserId { get; set; }
    public int FoodId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}