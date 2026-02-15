using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace AmorkApp.Models;

// This maps the class to the "categories" table in Postgres (lowercase)
[Table("categories")]
public class Category
{
    [Key]
    [Column("category_id")] // Maps to database column 'category_id'
    [JsonPropertyName("id")] // Sends 'id' to Flutter
    public int Id { get; set; }

    [Required]
    [Column("name")]
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    [Column("icon")]
    [JsonPropertyName("icon")]
    public string? Icon { get; set; }

    [Column("color")]
    [JsonPropertyName("color")]
    public string? Color { get; set; }
}
