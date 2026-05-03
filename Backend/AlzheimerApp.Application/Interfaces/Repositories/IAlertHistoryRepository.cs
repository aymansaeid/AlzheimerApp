using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Interfaces.Repositories;

public interface IAlertHistoryRepository
{
    Task AddAsync(AlertHistory alert);
}