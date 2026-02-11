using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace AmorkApp.Models;

[Table("foods")]
public class Food
{
    [Key]
    [Column("food_id")]
    public int FoodId { get; set; }

    [Required] // Added this to fix the CS0246 error
    [JsonPropertyName("food_name")]
    [Column("food_name")]
    public string Name { get; set; } = string.Empty;

    [Column("price")]
    public double Price { get; set; }

    [Column("description")]
    public string? Description { get; set; }

    [Column("rating")]
    public decimal Rating { get; set; }

    [Column("image_url")]
    public string? ImageUrl { get; set; }

    [JsonPropertyName("cooking_time")]
    [Column("cooking_time")]
    public string? CookingTime { get; set; }
}