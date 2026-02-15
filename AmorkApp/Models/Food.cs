using System;
using System.Collections.Generic; // Added for List<>
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

    [Required]
    [JsonPropertyName("food_name")]
    [Column("food_name")]
    public string Name { get; set; } = string.Empty;
    [Required]
    [JsonPropertyName("category_id")]
    [Column("category_id")]
    public int CategoryId { get; set; }

    [Column("price")]
    public double Price { get; set; }

    [Column("description")]
    public string? Description { get; set; }

    [Column("rating")]
    public decimal Rating { get; set; }

    [JsonPropertyName("image_url")]
    [Column("image_url")]
    public string? ImageUrl { get; set; }

    [JsonPropertyName("cooking_time")]
    [Column("cooking_time")]
    public string? CookingTime { get; set; }

    [JsonPropertyName("calories")]
    [Column("calories")]
    public int Calories { get; set; }

    [JsonPropertyName("is_popular")]
    [Column("is_popular")]
    public bool IsPopular { get; set; }

    [JsonPropertyName("is_available")]
    [Column("is_available")]
    public bool IsAvailable { get; set; }
}