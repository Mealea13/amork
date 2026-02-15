using AmorkApp.Data; // This must match the namespace in your Data folder
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// --- 1. ADD CORS SERVICES HERE ---
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()    // Allows requests from any IP/Browser
              .AllowAnyMethod()    // Allows GET, POST, PUT, DELETE
              .AllowAnyHeader();   // Allows Authorization tokens and Content-Type
    });
});
// ---------------------------------

// Add services to the container.
builder.Services.AddControllers();

// Configure the Database using your password: Mealea13042004
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AmorkDbContext>(options =>
    options.UseNpgsql(connectionString));

var app = builder.Build();

// --- 2. USE CORS MIDDLEWARE HERE ---
// (Must be placed BEFORE app.MapControllers())
app.UseCors("AllowAll");
// -----------------------------------

// app.UseHttpsRedirection();
app.MapControllers();

// using (var scope = app.Services.CreateScope())
// {
//     var db = scope.ServiceProvider.GetRequiredService<AmorkDbContext>();
//     db.Database.EnsureCreated(); // This creates the database and tables if they don't exist!
// }

// Run on your WiFi IP to match Postman
app.Run("http://0.0.0.0:5000");