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
    public Guid UserId { get; set; }

    [Column("fullname")]
    [JsonPropertyName("fullname")]
    public string? Fullname { get; set; }

    [Column("email")]
    [JsonPropertyName("email")]
    public string Email { get; set; } = string.Empty;

    [Column("password_text")]
    [JsonPropertyName("passwordText")]
    public string PasswordText { get; set; } = string.Empty;

    [Column("phone")]
    [JsonPropertyName("phone")]
    public string? Phone { get; set; }

    [Column("member_type")]
    [JsonPropertyName("memberType")]
    public string? MemberType { get; set; }

    [Column("create_at")] // Matches DB naming convention
    public DateTime? CreateAt { get; set; }
}