using AlzheimerApp.Application.DTOs.Alerts;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IAlertService
{
    Task<List<AlertResponse>> GetPatientAlertsAsync(Guid patientId);
    Task MarkAlertAsReadAsync(Guid alertId);
}