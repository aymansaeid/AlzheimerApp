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
}