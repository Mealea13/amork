using System;
using System.ComponentModel.DataAnnotations;

namespace AmorkApp.Models;

public class Order
{
    [Key]
    public int OrderId { get; set; }
    [Required]
    public Guid UserId { get; set; }
    [Required]
    public string FoodName { get; set; } = string.Empty;
    public string? Description { get; set; }
    [Required]

    public int Quantity {get; set;}

    public double Price {get; set;}
    public int FoodId { get; set; }
    [Range(1, 5)]
    public int Rating { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public string? ImageUrl {get; set;}

    public double TotalAmount {get; set;}

    public string? Status {get; set;}

    public string? DeliveryAddress {get; set;}

    public string? Phone {get; set;}

    public string? Notes {get; set;}
}