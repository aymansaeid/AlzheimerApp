using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AlzheimerApp.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddProfilePhotoUrlAndLocationIndex : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_LocationLogs_PatientId",
                table: "LocationLogs");

            migrationBuilder.RenameColumn(
                name: "AvatarUrl",
                table: "Users",
                newName: "ProfilePhotoUrl");

            migrationBuilder.CreateIndex(
                name: "IX_LocationLogs_PatientId_RecordedAt",
                table: "LocationLogs",
                columns: new[] { "PatientId", "RecordedAt" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_LocationLogs_PatientId_RecordedAt",
                table: "LocationLogs");

            migrationBuilder.RenameColumn(
                name: "ProfilePhotoUrl",
                table: "Users",
                newName: "AvatarUrl");

            migrationBuilder.CreateIndex(
                name: "IX_LocationLogs_PatientId",
                table: "LocationLogs",
                column: "PatientId");
        }
    }
}
