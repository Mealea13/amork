using System;
using System.ComponentModel.DataAnnotations;

namespace AmorkApp.Models;

public class Cart
{
    [Key]
    public int CartItemId { get; set; }
    [Required]
    public Guid UserId { get; set; }
    [Required]
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    [Required]
    public int FoodId { get; set; }
    [Range(1, 5)]
    public int Quantity { get; set; }
    [Required]
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public string? ImageUrl {get; set;}
}