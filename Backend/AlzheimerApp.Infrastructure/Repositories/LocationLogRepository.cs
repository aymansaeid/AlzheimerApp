using AlzheimerApp.Application.DTOs.Locations;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Domain.Enums;
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
    public async Task<List<PatientLatestLocationResponse>> GetLatestLocationsForPatientsAsync(Guid? followerId, CancellationToken cancellationToken = default)
    {
        IQueryable<User> patients = _context.Users.AsNoTracking();

        patients = followerId.HasValue
            // Caregiver: only patients linked to this follower (same rule as /api/Follower/my-patients).
            ? patients.Where(u => u.Followers.Any(pf => pf.FollowerId == followerId.Value))
            // System admin: every patient account.
            : patients.Where(u => u.Role == UserRole.Patient);

        // ONE SQL round-trip. Each latest-location column is a correlated scalar subquery
        // (ORDER BY "RecordedAt" DESC, "Id" DESC LIMIT 1), which PostgreSQL answers with a single backward seek on
        // IX_LocationLogs_PatientId_RecordedAt — cost grows with the number of patients, not with the size of
        // LocationLogs. (Projecting the whole row with .FirstOrDefault() would instead make EF emit a
        // ROW_NUMBER() OVER (PARTITION BY ...) join that scans every location ever logged.)
        // The "Id" tie-breaker guarantees all columns come from the same row.
        var rows = await patients
            .OrderBy(u => u.FullName)
            .Select(u => new
            {
                u.Id,
                u.FullName,
                u.ProfilePhotoUrl,
                u.Phone,
                Timestamp = u.LocationLogs
                    .OrderByDescending(l => l.RecordedAt).ThenByDescending(l => l.Id)
                    .Select(l => (DateTime?)l.RecordedAt).FirstOrDefault(),
                Latitude = u.LocationLogs
                    .OrderByDescending(l => l.RecordedAt).ThenByDescending(l => l.Id)
                    .Select(l => (double?)l.Latitude).FirstOrDefault(),
                Longitude = u.LocationLogs
                    .OrderByDescending(l => l.RecordedAt).ThenByDescending(l => l.Id)
                    .Select(l => (double?)l.Longitude).FirstOrDefault(),
                IsOutsideZone = u.LocationLogs
                    .OrderByDescending(l => l.RecordedAt).ThenByDescending(l => l.Id)
                    .Select(l => (bool?)l.IsOutsideZone).FirstOrDefault(),
                BatteryLevel = u.LocationLogs
                    .OrderByDescending(l => l.RecordedAt).ThenByDescending(l => l.Id)
                    .Select(l => l.BatteryLevel).FirstOrDefault(),
                IsCharging = u.LocationLogs
                    .OrderByDescending(l => l.RecordedAt).ThenByDescending(l => l.Id)
                    .Select(l => l.IsCharging).FirstOrDefault()
            })
            .ToListAsync(cancellationToken);

        // Shape the flat rows in memory. No timestamp = the patient has never sent a location.
        return rows.Select(r => new PatientLatestLocationResponse
        {
            PatientId = r.Id,
            FullName = r.FullName,
            ProfilePhotoUrl = r.ProfilePhotoUrl,
            Phone = string.IsNullOrWhiteSpace(r.Phone) ? null : r.Phone,
            LatestLocation = r.Timestamp == null
                ? null
                 : new LatestLocationResponse
                 {
                     Latitude = r.Latitude ?? 0,
                     Longitude = r.Longitude ?? 0,
                     Timestamp = r.Timestamp.Value,
                     IsInsideSafeZone = !(r.IsOutsideZone ?? false),
                     BatteryLevel = r.BatteryLevel,
                     IsCharging = r.IsCharging
                 }
        }).ToList();
    }
}