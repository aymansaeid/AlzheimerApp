using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Repositories;

public class LocationLogRepository : ILocationLogRepository
{
    private readonly ApplicationDbContext _context;

    public LocationLogRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<LocationLog> AddAsync(LocationLog locationLog)
    {
        await _context.LocationLogs.AddAsync(locationLog);
        await _context.SaveChangesAsync();
        return locationLog;
    }

    public async Task<List<LocationLog>> GetPatientLocationsAsync(Guid patientId, DateTime since)
    {
        return await _context.LocationLogs
            .Where(l => l.PatientId == patientId && l.RecordedAt >= since)
            .OrderByDescending(l => l.RecordedAt)
            .ToListAsync();
    }
    public async Task<LocationLog?> GetLatestLocationAsync(Guid patientId)
    {
        return await _context.LocationLogs
            .Where(l => l.PatientId == patientId)
            .OrderByDescending(l => l.RecordedAt)
            .FirstOrDefaultAsync();
    }
    public async Task<LocationLog?> GetLastLocationByPatientIdAsync(Guid patientId)
    {
        return await _context.LocationLogs
            .Where(l => l.PatientId == patientId)
            .OrderByDescending(l => l.RecordedAt)
            .FirstOrDefaultAsync();
    }
    public async Task<List<LocationLog>> GetLocationHistoryAsync(Guid patientId, DateTime startTime, DateTime endTime)
    {
        return await _context.LocationLogs
            .Where(l => l.PatientId == patientId && l.RecordedAt >= startTime && l.RecordedAt <= endTime)
            .OrderBy(l => l.RecordedAt) // Çizgi çizmek için eskiden yeniye sıralı olmalı
            .ToListAsync();
    }
}