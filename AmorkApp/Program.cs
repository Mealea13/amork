using AmorkApp.Data;
using Microsoft.EntityFrameworkCore;
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

var app = builder.Build();
app.UseCors("AllowAll");
app.UseStaticFiles();
app.MapControllers();
app.Run("http://0.0.0.0:5000");