using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Repositories;

public class MemoryContentRepository : IMemoryContentRepository
{
    private readonly ApplicationDbContext _context;

    public MemoryContentRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<MemoryContent> AddAsync(MemoryContent content)
    {
        await _context.MemoryContents.AddAsync(content);
        await _context.SaveChangesAsync();
        return content;
    }

    public async Task<List<MemoryContent>> GetActiveContentByPatientIdAsync(Guid patientId)
    {
        return await _context.MemoryContents
            .Where(mc => mc.PatientId == patientId && mc.IsActive)
            .OrderByDescending(mc => mc.CreatedAt) // Show newest memories first
            .ToListAsync();
    }
}