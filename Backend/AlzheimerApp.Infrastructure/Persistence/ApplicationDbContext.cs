using AlzheimerApp.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Persistence;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<PatientFollower> PatientFollowers { get; set; }
    public DbSet<SafeZone> SafeZones { get; set; }
    public DbSet<LocationLog> LocationLogs { get; set; }
    public DbSet<MemoryContent> MemoryContents { get; set; }
    public DbSet<Medicine> Medicines { get; set; }
    public DbSet<MedicineLog> MedicineLogs { get; set; }
    public DbSet<AlertHistory> AlertHistories { get; set; }
    public DbSet<PatientInvite> PatientInvites { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // 1. Patient-Follower Relationship (Many-to-Many self-referencing via PatientFollower table)
        modelBuilder.Entity<PatientFollower>()
            .HasOne(pf => pf.Patient)
            .WithMany(u => u.Followers)
            .HasForeignKey(pf => pf.PatientId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<PatientFollower>()
            .HasOne(pf => pf.Follower)
            .WithMany(u => u.FollowedPatients)
            .HasForeignKey(pf => pf.FollowerId)
            .OnDelete(DeleteBehavior.Restrict);

        // 2. Memory Content Relationships (UploadedBy vs PatientId)
        modelBuilder.Entity<MemoryContent>()
            .HasOne(mc => mc.Patient)
            .WithMany(u => u.MemoryContents)
            .HasForeignKey(mc => mc.PatientId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<MemoryContent>()
            .HasOne(mc => mc.Uploader)
            .WithMany() // No reverse navigation needed on User for Uploads
            .HasForeignKey(mc => mc.UploadedBy)
            .OnDelete(DeleteBehavior.Restrict);

        // 3. Medicine Relationships (CreatedBy vs PatientId)
        modelBuilder.Entity<Medicine>()
            .HasOne(m => m.Patient)
            .WithMany(u => u.Medicines)
            .HasForeignKey(m => m.PatientId)
            .OnDelete(DeleteBehavior.Cascade);

        modelBuilder.Entity<Medicine>()
            .HasOne(m => m.Creator)
            .WithMany()
            .HasForeignKey(m => m.CreatedBy)
            .OnDelete(DeleteBehavior.Restrict);

        // Make Email unique in the database
        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        // "Latest location per patient" lookups (single + bulk endpoints) become an index seek.
        // This composite index also covers the PatientId foreign key, so EF drops the old single-column one.
        modelBuilder.Entity<LocationLog>()
            .HasIndex(l => new { l.PatientId, l.RecordedAt });
    }
}