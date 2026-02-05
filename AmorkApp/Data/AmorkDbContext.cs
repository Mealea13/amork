using Microsoft.EntityFrameworkCore;

namespace AmorkApp.Data; // Ensure this is exactly AmorkApp.Data

public class AmorkDbContext : DbContext
{
    public AmorkDbContext(DbContextOptions<AmorkDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Food> Foods => Set<Food>();
}