using System;
using System.ComponentModel.DataAnnotations;

namespace AmorkApp.Models;

public class Review
{
    [Key]
    public int ReviewId { get; set; }
    [Required]
    public Guid UserId { get; set; }
    [Required]
    public int FoodId { get; set; }
    [Range(1, 5)]
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}