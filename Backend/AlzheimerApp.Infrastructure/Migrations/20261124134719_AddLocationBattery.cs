using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AlzheimerApp.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddLocationBattery : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "BatteryLevel",
                table: "LocationLogs",
                type: "integer",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsCharging",
                table: "LocationLogs",
                type: "boolean",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "BatteryLevel",
                table: "LocationLogs");

            migrationBuilder.DropColumn(
                name: "IsCharging",
                table: "LocationLogs");
        }
    }
}
