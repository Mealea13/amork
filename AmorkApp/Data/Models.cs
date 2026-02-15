using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Text.Json.Serialization;
namespace AmorkApp.Models;

[Table("users")]
public class User
{
    [Key]
    [Column("user_id")]
    public Guid UserId { get; set; } = Guid.NewGuid();

    [Column("fullname")]
    [JsonPropertyName("fullname")]
    public string? Fullname { get; set; }

    [Column("email")]
    [JsonPropertyName("email")]
    public string Email { get; set; } = string.Empty;

    // ✅ THE FIX: This maps the JSON key "password" to your DB column "password_text"
    [Column("password_text")]
    [JsonPropertyName("password")] 
    public string PasswordText { get; set; } = string.Empty;

    [Column("phone")]
    [JsonPropertyName("phone")]
    public string? Phone { get; set; }

    [Column("member_type")]
    [JsonPropertyName("member_type")]
    public string? MemberType { get; set; } = "regular";

    [Column("created_at")]
    public DateTime? CreatedAt { get; set; } = DateTime.UtcNow;

    [Column("updated_at")]
    public DateTime? UpdatedAt { get; set; } = DateTime.UtcNow;

    [Column("is_active")]
    public bool IsActive { get; set; } = true;
}