using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace AlzheimerApp.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class MergeSplitMedicines : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"
CREATE TEMP TABLE medicine_merge AS
SELECT m.""Id"",
       first_value(m.""Id"") OVER (PARTITION BY m.group_key ORDER BY m.""CreatedAt"", m.""Id"") AS ""KeeperId""
FROM (
    SELECT ""Id"", ""CreatedAt"",
           concat_ws('|', ""PatientId"", lower(btrim(""Name"")), lower(btrim(""Dosage"")), coalesce(btrim(""Instructions""), ''),
                     ""DaysOfWeek"", ""StartDate"", coalesce(""EndDate""::text, '-'), ""IsActive"") AS group_key
    FROM ""Medicines""
) m;

DELETE FROM medicine_merge WHERE ""KeeperId"" IN (
    SELECT ""KeeperId"" FROM medicine_merge GROUP BY ""KeeperId"" HAVING count(*) = 1
);

UPDATE ""Medicines"" k
SET ""ScheduleTimes"" = t.times
FROM (
    SELECT mm.""KeeperId"", array_agg(DISTINCT st ORDER BY st) AS times
    FROM medicine_merge mm
    JOIN ""Medicines"" med ON med.""Id"" = mm.""Id""
    CROSS JOIN LATERAL unnest(med.""ScheduleTimes"") AS st
    GROUP BY mm.""KeeperId""
) t
WHERE k.""Id"" = t.""KeeperId"";

DELETE FROM ""MedicineLogs"" l
USING medicine_merge ml, ""MedicineLogs"" o, medicine_merge mo
WHERE l.""MedicineId"" = ml.""Id""
  AND o.""MedicineId"" = mo.""Id""
  AND ml.""KeeperId"" = mo.""KeeperId""
  AND l.""ScheduledAt"" = o.""ScheduledAt""
  AND l.""Id"" <> o.""Id""
  AND (
        (CASE l.""Status"" WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END) <
        (CASE o.""Status"" WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END)
     OR ((CASE l.""Status"" WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END) =
         (CASE o.""Status"" WHEN 1 THEN 2 WHEN 2 THEN 1 ELSE 0 END) AND l.""Id"" > o.""Id"")
  );

UPDATE ""MedicineLogs"" l
SET ""MedicineId"" = mm.""KeeperId""
FROM medicine_merge mm
WHERE l.""MedicineId"" = mm.""Id"" AND mm.""Id"" <> mm.""KeeperId"";

DELETE FROM ""Medicines"" m
USING medicine_merge mm
WHERE m.""Id"" = mm.""Id"" AND mm.""Id"" <> mm.""KeeperId"";

DROP TABLE medicine_merge;
");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Merged medicines cannot be split back automatically.
        }
    }
}
