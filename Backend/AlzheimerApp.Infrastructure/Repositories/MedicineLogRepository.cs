using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Repositories;

public class MedicineLogRepository : IMedicineLogRepository
{
    private readonly ApplicationDbContext _context;

    public MedicineLogRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<MedicineLog>> GetLogsByPatientAndDateAsync(Guid patientId, DateTime date)
    {
        // .Date strips the time away, so we only search for that specific day
        var targetDate = date.Date;

        return await _context.MedicineLogs
            .Include(ml => ml.Medicine) // Join the Medicine table so we can get the Name and Dosage!
            .Where(ml => ml.PatientId == patientId && ml.ScheduledAt.Date == targetDate)
            .OrderBy(ml => ml.ScheduledAt)
            .ToListAsync();
    }

    public async Task<MedicineLog?> GetByIdAsync(Guid id)
    {
        return await _context.MedicineLogs.FindAsync(id);
    }

    public async Task UpdateAsync(MedicineLog log)
    {
        _context.MedicineLogs.Update(log);
        await _context.SaveChangesAsync();
    }

    public async Task AddRangeAsync(IEnumerable<MedicineLog> logs)
    {
        await _context.MedicineLogs.AddRangeAsync(logs);
        await _context.SaveChangesAsync();
    }

    public async Task<List<MedicineLog>> GetPendingLogsBeforeAsync(DateTime cutoffDate)
    {
        return await _context.MedicineLogs
            .Where(ml => ml.Status == Domain.Enums.MedicineStatus.Pending && ml.ScheduledAt < cutoffDate)
            .ToListAsync();
    }

    public async Task UpdateRangeAsync(IEnumerable<MedicineLog> logs)
    {
        _context.MedicineLogs.UpdateRange(logs);
        await _context.SaveChangesAsync();
    }
}