using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AmorkApp.Models;

[Table("foods")]
public class Food
{
    [Key]
    [Column("food_id")]
    public int FoodId { get; set; }

    [Required]
    [Column("food_name")]
    public string Name { get; set; } = string.Empty;

    [Column("description")]
    public string? Description { get; set; }

    [Required]
    [Column("price")]
    public double Price { get; set; }

    [Column("original_price")]
    public double? OriginalPrice { get; set; }

    [Column("image_url")]
    public string ImageUrl { get; set; } = string.Empty;

    [Required]
    [Column("category_id")]
    public int CategoryId { get; set; }

    [Column("calories")]
    public int Calories { get; set; }

    [Column("cooking_time")]
    public string Time { get; set; } = "15 min";

    [Column("rating")]
    public decimal Rating { get; set; } = 0.0m;

    [Column("is_popular")]
    public bool IsPopular { get; set; } = false;

    [Column("is_available")]
    public bool IsAvailable { get; set; } = true;
}