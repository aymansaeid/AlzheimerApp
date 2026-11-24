using AlzheimerApp.Application.DTOs.Medicines;

namespace AlzheimerApp.Application.Interfaces.Services;

public interface IMedicineService
{
    /// <exception cref="ArgumentException">Validation failed.</exception>
    Task<MedicineResponse> AddMedicineAsync(Guid creatorId, MedicineRequest request);

    Task<List<MedicineResponse>> GetPatientMedicinesAsync(Guid patientId);

    /// <exception cref="KeyNotFoundException">No medicine with this id.</exception>
    Task<MedicineResponse> GetMedicineAsync(Guid id);

    /// <exception cref="ArgumentException">Validation failed.</exception>
    /// <exception cref="KeyNotFoundException">No medicine with this id.</exception>
    Task<MedicineResponse> UpdateMedicineAsync(Guid id, UpdateMedicineRequest request);

    /// <exception cref="KeyNotFoundException">No medicine with this id.</exception>
    Task DeleteMedicineAsync(Guid id);
}