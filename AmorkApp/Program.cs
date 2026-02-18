using AmorkApp.Data;
using AmorkApp.Models; // ✅ Add this
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

AppContext.SetSwitch("Npgsql.EnableLegacyTimestampBehavior", true);

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddControllers();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<AmorkDbContext>(options =>
    options.UseNpgsql(connectionString));

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
        };
    });

var app = builder.Build();

// ✅ Seed foods BEFORE app.Run()
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<AmorkDbContext>();
    if (!db.Foods.Any())
    if (!db.Foods.Any())
    {
        db.Foods.AddRange(
            new Food { Name = "Spicy Wings", Description = "Hot and spicy chicken wings", Price = 3.00, OriginalPrice = 6.00, Calories = 400, Time = "15 min", ImageUrl = "assets/images/wings grill.png", IsPopular = true, Rating = 4.5m, CategoryId = 1 },
            new Food { Name = "Fried Rice", Description = "Pork fried rice with egg", Price = 2.50, OriginalPrice = 5.00, Calories = 450, Time = "20 min", ImageUrl = "assets/images/Bay cha.png", IsPopular = true, Rating = 4.3m, CategoryId = 1 },
            new Food { Name = "Beef Burger", Description = "Double beef with extra cheese", Price = 5.50, OriginalPrice = null, Calories = 600, Time = "15 min", ImageUrl = "assets/images/Burger.png", IsPopular = true, Rating = 4.7m, CategoryId = 1 },
            new Food { Name = "Iced Coffee", Description = "Sweet iced coffee", Price = 1.75, OriginalPrice = 3.50, Calories = 200, Time = "3 min", ImageUrl = "assets/images/iced latte.png", IsPopular = false, Rating = 4.4m, CategoryId = 2 },
            new Food { Name = "Crispy Fries", Description = "Hot salty french fries", Price = 1.50, OriginalPrice = 3.00, Calories = 300, Time = "10 min", ImageUrl = "assets/images/fries.png", IsPopular = false, Rating = 4.3m, CategoryId = 4 }
        );
        db.SaveChanges();
    }
}

app.UseCors("AllowAll");
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run("http://0.0.0.0:5000");