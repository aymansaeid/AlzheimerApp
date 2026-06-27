using AlzheimerApp.Application.DTOs.Medicines;
using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Application.Interfaces.Services;
using AlzheimerApp.Domain.Entities;

namespace AlzheimerApp.Application.Services;

public class MedicineService : IMedicineService
{
    private readonly IMedicineRepository _medicineRepository;

    private readonly IMedicineLogRepository _logRepository;

    public MedicineService(IMedicineRepository medicineRepository, IMedicineLogRepository logRepository)
    {
        _medicineRepository = medicineRepository;
        _logRepository = logRepository;
    }

    public async Task<MedicineResponse> AddMedicineAsync(MedicineRequest request)
    {
        var medicine = new Medicine
        {
            PatientId = request.PatientId,
            CreatedBy = request.CreatorId,
            Name = request.Name,
            Dosage = request.Dosage,
            Instructions = request.Instructions,
            ScheduleTime = request.ScheduleTime,
            DaysOfWeek = request.DaysOfWeek,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        };

        var savedEntity = await _medicineRepository.AddAsync(medicine);
        return MapToResponse(savedEntity);
    }

    public async Task<List<MedicineResponse>> GetPatientMedicinesAsync(Guid patientId)
    {
        var medicines = await _medicineRepository.GetActiveMedicinesByPatientIdAsync(patientId);
        return medicines.Select(MapToResponse).ToList();
    }

    private MedicineResponse MapToResponse(Medicine medicine)
    {
        return new MedicineResponse
        {
            Id = medicine.Id,
            PatientId = medicine.PatientId,
            Name = medicine.Name,
            Dosage = medicine.Dosage,
            Instructions = medicine.Instructions,
            ScheduleTime = medicine.ScheduleTime,
            DaysOfWeek = medicine.DaysOfWeek,
            IsActive = medicine.IsActive
        };
    }

    public async Task UpdateMedicineAsync(Guid id, UpdateMedicineRequest request)
    {
        var medicine = await _medicineRepository.GetByIdAsync(id);
        if (medicine == null) throw new Exception("Medicine not found.");

        medicine.Name = request.Name;
        medicine.Dosage = request.Dosage;
        medicine.Instructions = request.Instructions;
        medicine.ScheduleTime = request.ScheduleTime;
        medicine.DaysOfWeek = request.DaysOfWeek;
        medicine.StartDate = request.StartDate;
        medicine.EndDate = request.EndDate;
        medicine.IsActive = request.IsActive;

        await _medicineRepository.UpdateAsync(medicine);

        var futureLogs = await _logRepository.GetFuturePendingLogsByMedicineIdAsync(id, DateTime.UtcNow);
        if (futureLogs.Any())
        {
            await _logRepository.RemoveRangeAsync(futureLogs);
        }
    }

    public async Task DeleteMedicineAsync(Guid id)
    {
        var medicine = await _medicineRepository.GetByIdAsync(id);
        if (medicine == null) throw new Exception("Medicine not found.");

        var futureLogs = await _logRepository.GetFuturePendingLogsByMedicineIdAsync(id, DateTime.UtcNow);

        if (futureLogs.Any())
        {
            await _logRepository.RemoveRangeAsync(futureLogs);
        }

        await _medicineRepository.DeleteAsync(medicine);
    }
}