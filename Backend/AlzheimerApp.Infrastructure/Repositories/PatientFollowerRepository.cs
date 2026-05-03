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
}