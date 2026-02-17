using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;

namespace AmorkApp.Models;

[Table("users")]
public class User
{
    [Key]
    [Column("user_id")]
    [JsonPropertyName("id")]
    public Guid UserId { get; set; } = Guid.NewGuid();

    [Column("fullname")]
    public string Fullname { get; set; } = string.Empty;

    [Column("email")]
    public string Email { get; set; } = string.Empty;

    [Column("phone")]
    public string? Phone { get; set; }

    [Column("password_hash")]
    [JsonPropertyName("password")] 
    public string PasswordHash { get; set; } = string.Empty;

    [Column("profile_image")]
    public string? ProfileImage { get; set; }

    [Column("member_type")]
    public string? MemberType { get; set; } = "regular";

    // ✅ FIX: Use DateTime.UtcNow for both
    [Column("created_at")]
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    [Column("is_active")]
    public bool IsActive { get; set; } = true;
}