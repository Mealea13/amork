using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace AmorkApp.Data; // This must match exactly

[Table("users")]
public class User
{
    [Key]
    [Column("user_id")]
    public int UserId { get; set; }

    [Column("fullname")]
    public string? Fullname { get; set; }

    [Column("email")]
    public string Email { get; set; } = string.Empty;

    [Column("password_text")]
    public string PasswordText { get; set; } = string.Empty;
}

[Table("foods")]
public class Food
{
    [Key]
    [Column("food_id")]
    public int FoodId { get; set; }

    [JsonPropertyName("food_name")]
    [Column("food_name")]
    public string FoodName { get; set; } = string.Empty;

    [Column("price")]
    public decimal Price { get; set; }

    [JsonPropertyName("cooking_time")]
    [Column("cooking_time")]
    public string? CookingTime { get; set; }
}