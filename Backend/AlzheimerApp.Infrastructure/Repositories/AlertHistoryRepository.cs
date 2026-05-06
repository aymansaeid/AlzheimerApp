using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Repositories;

public class AlertHistoryRepository : IAlertHistoryRepository
{
    private readonly ApplicationDbContext _context;

    public AlertHistoryRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task AddAsync(AlertHistory alert)
    {
        await _context.AlertHistories.AddAsync(alert);
        await _context.SaveChangesAsync();
    }

    public async Task<AlertHistory?> GetByIdAsync(Guid id)
    {
        return await _context.AlertHistories.FindAsync(id);
    }

    public async Task<List<AlertHistory>> GetPatientAlertsAsync(Guid patientId)
    {
        return await _context.AlertHistories
            .Where(a => a.PatientId == patientId)
            .OrderByDescending(a => a.SentAt) // Newest alerts first!
            .ToListAsync();
    }

    public async Task UpdateAsync(AlertHistory alert)
    {
        _context.AlertHistories.Update(alert);
        await _context.SaveChangesAsync();
    }
}