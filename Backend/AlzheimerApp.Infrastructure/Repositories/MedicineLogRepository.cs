using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;
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

    public async Task<List<MedicineLog>> GetLogsByPatientInRangeAsync(Guid patientId, DateTime fromUtc, DateTime toUtc)
    {
        // A UTC range (not ScheduledAt.Date) so the local Turkish day is used and the index can be used.
        return await _context.MedicineLogs
            .Include(ml => ml.Medicine) // Join the Medicine table so we can get the Name and Dosage!
            .Where(ml => ml.PatientId == patientId && ml.ScheduledAt >= fromUtc && ml.ScheduledAt < toUtc)
            .OrderBy(ml => ml.ScheduledAt)
            .ToListAsync();
    }

    public async Task<List<MedicineLog>> GetLogsInRangeAsync(DateTime fromUtc, DateTime toUtc)
    {
        return await _context.MedicineLogs
            .Where(ml => ml.ScheduledAt >= fromUtc && ml.ScheduledAt < toUtc)
            .ToListAsync();
    }

    public async Task<List<MedicineLog>> GetPendingWithoutReminderAsync(DateTime scheduledBeforeUtc)
    {
        return await _context.MedicineLogs
            .Include(ml => ml.Medicine)
            .Include(ml => ml.Patient)
            .Where(ml => ml.Status == MedicineStatus.Pending && !ml.IsAlarmSent && ml.ScheduledAt <= scheduledBeforeUtc)
            .ToListAsync();
    }

    public async Task<List<MedicineLog>> GetPendingLogsBeforeAsync(DateTime cutoffUtc, Guid? patientId = null)
    {
        var query = _context.MedicineLogs
            .Include(ml => ml.Medicine)
            .Include(ml => ml.Patient)
            .Where(ml => ml.Status == MedicineStatus.Pending && ml.ScheduledAt <= cutoffUtc);

        if (patientId.HasValue) query = query.Where(ml => ml.PatientId == patientId.Value);

        return await query.ToListAsync();
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

    public async Task<List<MedicineLog>> AddRangeIgnoringDuplicatesAsync(IReadOnlyCollection<MedicineLog> logs)
    {
        if (logs.Count == 0) return new List<MedicineLog>();

        try
        {
            // Fast path: one round-trip for the whole batch.
            await _context.MedicineLogs.AddRangeAsync(logs);
            await _context.SaveChangesAsync();
            return logs.ToList();
        }
        catch (DbUpdateException)
        {
            // Another process inserted some of them first. Forget the failed batch and insert one by one.
            foreach (var log in logs) _context.Entry(log).State = EntityState.Detached;
        }

        var inserted = new List<MedicineLog>();
        foreach (var log in logs)
        {
            try
            {
                _context.MedicineLogs.Add(log);
                await _context.SaveChangesAsync();
                inserted.Add(log);
            }
            catch (DbUpdateException)
            {
                _context.Entry(log).State = EntityState.Detached; // duplicate: already exists
            }
        }
        return inserted;
    }

    public async Task UpdateRangeAsync(IEnumerable<MedicineLog> logs)
    {
        _context.MedicineLogs.UpdateRange(logs);
        await _context.SaveChangesAsync();
    }

    public async Task<List<MedicineLog>> GetFuturePendingLogsByMedicineIdAsync(Guid medicineId, DateTime fromDate)
    {
        return await _context.MedicineLogs
            .Where(ml => ml.MedicineId == medicineId
                      && ml.Status == MedicineStatus.Pending
                      && ml.ScheduledAt >= fromDate)
            .ToListAsync();
    }

    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }

    public async Task RemoveRangeAsync(IEnumerable<MedicineLog> logs)
    {
        _context.MedicineLogs.RemoveRange(logs);
        await _context.SaveChangesAsync();
    }
}