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

    public async Task<List<MemoryContent>> GetActiveContentByPatientIdAsync(Guid patientId, Guid? uploaderId = null, string? personName = null, int? contentType = null)
    {
        var query = _context.MemoryContents
            .Include(mc => mc.Uploader) // name + profile photo for the feed post header
            .Where(mc => mc.PatientId == patientId && mc.IsActive)
            .AsQueryable();

        if (uploaderId.HasValue)
        {
            query = query.Where(mc => mc.UploadedBy == uploaderId.Value);
        }

        if (!string.IsNullOrWhiteSpace(personName))
        {
            query = query.Where(mc => mc.PersonName.ToLower().Contains(personName.ToLower()));
        }

        if (contentType.HasValue)
        {
            query = query.Where(mc => (int)mc.ContentType == contentType.Value);
        }

        return await query.OrderByDescending(mc => mc.CreatedAt).ToListAsync();
    }

    public async Task<MemoryContent?> GetByIdAsync(Guid id)
    {
        return await _context.MemoryContents.FindAsync(id);
    }

    public async Task UpdateAsync(MemoryContent content)
    {
        _context.MemoryContents.Update(content);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(MemoryContent content)
    {
        _context.MemoryContents.Remove(content);
        await _context.SaveChangesAsync();
    }
}