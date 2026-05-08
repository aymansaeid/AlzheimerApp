using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Repositories;

public class PatientFollowerRepository : IPatientFollowerRepository
{
    private readonly ApplicationDbContext _context;

    public PatientFollowerRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<User>> GetFollowersByPatientIdAsync(Guid patientId)
    {
        // This joins the tables and returns the actual User accounts of the followers!
        return await _context.PatientFollowers
            .Where(pf => pf.PatientId == patientId)
            .Include(pf => pf.Follower)
            .Select(pf => pf.Follower!)
            .ToListAsync();
    }

    public async Task<PatientFollower> AddAsync(PatientFollower patientFollower)
    {
        await _context.PatientFollowers.AddAsync(patientFollower);
        await _context.SaveChangesAsync();
        return patientFollower;
    }

    public async Task<bool> RelationshipExistsAsync(Guid patientId, Guid followerId)
    {
        return await _context.PatientFollowers
            .AnyAsync(pf => pf.PatientId == patientId && pf.FollowerId == followerId);
    }
    public async Task<bool> HasPrimaryFollowerAsync(Guid patientId)
    {
        return await _context.PatientFollowers
            .AnyAsync(pf => pf.PatientId == patientId && pf.IsPrimary);
    }
    public async Task<PatientFollower?> GetRelationshipAsync(Guid patientId, Guid followerId)
    {
        return await _context.PatientFollowers
            .FirstOrDefaultAsync(pf => pf.PatientId == patientId && pf.FollowerId == followerId);
    }

    public async Task UpdateAsync(PatientFollower relationship)
    {
        _context.PatientFollowers.Update(relationship);
        await _context.SaveChangesAsync();
    }
}