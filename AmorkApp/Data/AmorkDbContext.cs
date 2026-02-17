using AmorkApp.Models;
using Microsoft.EntityFrameworkCore;

namespace AmorkApp.Data;

public class AmorkDbContext : DbContext
{
    // The name here MUST match the class name exactly!
    public AmorkDbContext(DbContextOptions<AmorkDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Food> Foods { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Favorite> Favorites { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<Promotion> Promotions { get; set; }
    public DbSet<Cart> CartItems { get; set; }
    public DbSet<Order> Orders { get; set; }
}