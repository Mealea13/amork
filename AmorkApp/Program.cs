using AmorkApp.Data; // This must match the namespace in your Data folder
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Configure the Database using your password: Mealea13042004
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AmorkDbContext>(options =>
    options.UseNpgsql(connectionString));

var app = builder.Build();

// app.UseHttpsRedirection();
app.MapControllers();

// using (var scope = app.Services.CreateScope())
// {
//     var db = scope.ServiceProvider.GetRequiredService<AmorkDbContext>();
//     db.Database.EnsureCreated(); // This creates the database and tables if they don't exist!
// }

// Run on your WiFi IP to match Postman
app.Run("http://0.0.0.0:5000");