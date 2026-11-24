using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AlzheimerApp.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class MedicineScheduleTimeZoneFix : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // 1. Eski kayıtlar Türkiye saatini UTC gibi saklıyordu; gerçek UTC'ye çevir (TR = UTC+3)
            migrationBuilder.Sql(@"UPDATE ""MedicineLogs"" SET ""ScheduledAt"" = ""ScheduledAt"" - INTERVAL '3 hours';");

            // 2. Benzersiz index'ten önce kopyaları sil (Taken > Missed > Pending, sonra küçük Id kalır)
            migrationBuilder.Sql(@"
DELETE FROM ""MedicineLogs"" a
USING ""MedicineLogs"" b
WHERE a.""MedicineId"" = b.""MedicineId""
  AND a.""ScheduledAt"" = b.""ScheduledAt""
  AND a.""Id"" <> b.""Id""
  AND (
        (CASE a.""Status"" WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END) <
        (CASE b.""Status"" WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END)
     OR ((CASE a.""Status"" WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END) =
         (CASE b.""Status"" WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END) AND a.""Id"" > b.""Id"")
  );");

            migrationBuilder.DropIndex(
                name: "IX_MedicineLogs_MedicineId",
                table: "MedicineLogs");

            migrationBuilder.CreateIndex(
                name: "IX_MedicineLogs_MedicineId_ScheduledAt",
                table: "MedicineLogs",
                columns: new[] { "MedicineId", "ScheduledAt" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_MedicineLogs_MedicineId_ScheduledAt",
                table: "MedicineLogs");

            migrationBuilder.CreateIndex(
                name: "IX_MedicineLogs_MedicineId",
                table: "MedicineLogs",
                column: "MedicineId");

            migrationBuilder.Sql(@"UPDATE ""MedicineLogs"" SET ""ScheduledAt"" = ""ScheduledAt"" + INTERVAL '3 hours';");
        }
    }
}