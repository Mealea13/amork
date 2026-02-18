using AmorkApp.Models;
using Microsoft.EntityFrameworkCore;

namespace AmorkApp.Data;

public class AmorkDbContext : DbContext
{
    public AmorkDbContext(DbContextOptions<AmorkDbContext> options) : base(options) { }

    public DbSet<User> Users { get; set; }
    public DbSet<Food> Foods { get; set; }
    public DbSet<Category> Categories { get; set; }
    public DbSet<Favorite> Favorites { get; set; }
    public DbSet<Review> Reviews { get; set; }
    public DbSet<Promotion> Promotions { get; set; }
    public DbSet<Cart> CartItems { get; set; }
    public DbSet<Order> Orders { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.Entity<User>().ToTable("users");
        modelBuilder.Entity<Food>().ToTable("foods");
        modelBuilder.Entity<Category>().ToTable("categories");
        modelBuilder.Entity<Favorite>().ToTable("favorites");
        modelBuilder.Entity<Review>().ToTable("reviews");
        modelBuilder.Entity<Promotion>().ToTable("promotions");
        modelBuilder.Entity<Cart>().ToTable("cart_items");
        modelBuilder.Entity<Order>().ToTable("orders");
    }
}