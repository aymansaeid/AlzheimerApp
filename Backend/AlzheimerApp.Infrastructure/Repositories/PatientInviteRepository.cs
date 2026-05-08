using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Repositories;

public class PatientInviteRepository : IPatientInviteRepository
{
    private readonly ApplicationDbContext _context;

    public PatientInviteRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<PatientInvite> AddAsync(PatientInvite invite)
    {
        await _context.PatientInvites.AddAsync(invite);
        await _context.SaveChangesAsync();
        return invite;
    }

    public async Task<PatientInvite?> GetByCodeAsync(string inviteCode)
    {
        return await _context.PatientInvites
            .FirstOrDefaultAsync(i => i.InviteCode == inviteCode && i.IsActive);
    }

    public async Task UpdateAsync(PatientInvite invite)
    {
        _context.PatientInvites.Update(invite);
        await _context.SaveChangesAsync();
    }
}