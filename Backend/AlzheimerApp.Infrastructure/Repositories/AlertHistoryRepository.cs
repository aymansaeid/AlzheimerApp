using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;

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
}