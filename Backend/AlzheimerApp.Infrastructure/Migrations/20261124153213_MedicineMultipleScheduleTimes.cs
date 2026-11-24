using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AlzheimerApp.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class MedicineMultipleScheduleTimes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // 1. Yeni kolonu geçici olarak nullable ekle
            migrationBuilder.AddColumn<List<TimeSpan>>(
                name: "ScheduleTimes",
                table: "Medicines",
                type: "interval[]",
                nullable: true);

            // 2. Mevcut ScheduleTime değerini tek elemanlı diziye kopyala
            migrationBuilder.Sql(@"UPDATE ""Medicines"" SET ""ScheduleTimes"" = ARRAY[""ScheduleTime""];");

            // 3. Kolonu NOT NULL yap
            migrationBuilder.AlterColumn<List<TimeSpan>>(
                name: "ScheduleTimes",
                table: "Medicines",
                type: "interval[]",
                nullable: false,
                oldClrType: typeof(List<TimeSpan>),
                oldType: "interval[]",
                oldNullable: true);

            // 4. Veri taşındıktan sonra eski kolonu sil
            migrationBuilder.DropColumn(
                name: "ScheduleTime",
                table: "Medicines");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<TimeSpan>(
                name: "ScheduleTime",
                table: "Medicines",
                type: "interval",
                nullable: false,
                defaultValue: new TimeSpan(0, 0, 0, 0, 0));

            // Dizideki ilk saati geri al (PostgreSQL dizileri 1'den başlar)
            migrationBuilder.Sql(@"UPDATE ""Medicines"" SET ""ScheduleTime"" = ""ScheduleTimes""[1] WHERE array_length(""ScheduleTimes"", 1) > 0;");

            migrationBuilder.DropColumn(
                name: "ScheduleTimes",
                table: "Medicines");
        }
    }
}