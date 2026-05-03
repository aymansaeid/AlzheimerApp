using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Repositories;

public class SafeZoneRepository : ISafeZoneRepository
{
    private readonly ApplicationDbContext _context;

    public SafeZoneRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<SafeZone>> GetActiveSafeZonesByPatientIdAsync(Guid patientId)
    {
        return await _context.SafeZones
            .Where(sz => sz.PatientId == patientId && sz.IsActive)
            .ToListAsync();
    }
    public async Task<SafeZone> AddAsync(SafeZone safeZone)
    {
        await _context.SafeZones.AddAsync(safeZone);
        await _context.SaveChangesAsync();
        return safeZone;
    }

    public async Task<SafeZone?> GetByIdAsync(Guid id)
    {
        return await _context.SafeZones.FindAsync(id);
    }

    public async Task UpdateAsync(SafeZone safeZone)
    {
        _context.SafeZones.Update(safeZone);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(SafeZone safeZone)
    {
        _context.SafeZones.Remove(safeZone);
        await _context.SaveChangesAsync();
    }
}