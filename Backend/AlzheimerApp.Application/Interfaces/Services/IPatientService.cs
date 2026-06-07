using AlzheimerApp.Application.DTOs.Patients;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IPatientService
{
    Task<PatientDashboardResponse> GetDashboardAsync(Guid patientId);
}