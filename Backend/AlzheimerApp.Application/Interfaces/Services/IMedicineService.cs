using AlzheimerApp.Application.DTOs.Medicines;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IMedicineService
{
    Task<MedicineResponse> AddMedicineAsync(MedicineRequest request);
    Task<List<MedicineResponse>> GetPatientMedicinesAsync(Guid patientId);
}