using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AmorkApp.Migrations
{
    /// <inheritdoc />
    public partial class AddRatingToCartItems : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Description",
                table: "cart_items",
                newName: "Notes");

            migrationBuilder.AddColumn<double>(
                name: "Price",
                table: "cart_items",
                type: "double precision",
                nullable: false,
                defaultValue: 0.0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Price",
                table: "cart_items");

            migrationBuilder.RenameColumn(
                name: "Notes",
                table: "cart_items",
                newName: "Description");
        }
    }
}
