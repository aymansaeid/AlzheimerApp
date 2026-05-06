using AlzheimerApp.Application.DTOs.Alerts;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;

namespace AlzheimerApp.Application.Services;

public class AlertService : IAlertService
{
    private readonly IAlertHistoryRepository _alertRepository;

    public AlertService(IAlertHistoryRepository alertRepository)
    {
        _alertRepository = alertRepository;
    }

    public async Task<List<AlertResponse>> GetPatientAlertsAsync(Guid patientId)
    {
        var alerts = await _alertRepository.GetPatientAlertsAsync(patientId);

        return alerts.Select(a => new AlertResponse
        {
            Id = a.Id,
            PatientId = a.PatientId,
            AlertType = a.AlertType,
            Message = a.Message,
            IsRead = a.IsRead,
            SentAt = a.SentAt
        }).ToList();
    }

    public async Task MarkAlertAsReadAsync(Guid alertId)
    {
        var alert = await _alertRepository.GetByIdAsync(alertId);
        if (alert == null) throw new Exception("Alert not found.");

        alert.IsRead = true;
        await _alertRepository.UpdateAsync(alert);
    }
}