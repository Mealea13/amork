using AmorkApp.Models;
using Microsoft.EntityFrameworkCore;

namespace AmorkApp.Data;

public class AmorkDbContext : DbContext
{
    public AmorkDbContext(DbContextOptions<AmorkDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Food> foods { get; set; }
    public DbSet<Favorite> Favorite { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<Promotion> Promotions { get; set; }
    public DbSet<Cart> CartItem {get; set;}
    public DbSet<Order> orders{get; set;}
    public DbSet<Category> Categories { get; set; }
}