using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AmorkApp.Models;

[Table("favorites")]
public class Favorite
{
    [Key]
    [Column("favorite_id")]
    public Guid FavoriteId { get; set; } = Guid.NewGuid();

    [Column("user_id")]
    public Guid UserId { get; set; }

    [Column("food_id")]
    public int FoodId { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}