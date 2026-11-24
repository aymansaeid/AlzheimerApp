using AlzheimerApp.Application.Interfaces.Repositories;
using AlzheimerApp.Domain.Entities;
using AlzheimerApp.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace AlzheimerApp.Infrastructure.Repositories;

public class MedicineRepository : IMedicineRepository
{
    private readonly ApplicationDbContext _context;

    public MedicineRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<Medicine> AddAsync(Medicine medicine)
    {
        await _context.Medicines.AddAsync(medicine);
        await _context.SaveChangesAsync();
        return medicine;
    }

    public async Task<List<Medicine>> GetActiveMedicinesByPatientIdAsync(Guid patientId)
    {
        return await _context.Medicines
            .Where(m => m.PatientId == patientId && m.IsActive)
           .OrderBy(m => m.Name) // Order by name!
            .ToListAsync();
    }

    public async Task<Medicine?> GetByIdAsync(Guid id)
    {
        return await _context.Medicines.FindAsync(id);
    }

    public async Task UpdateAsync(Medicine medicine)
    {
        _context.Medicines.Update(medicine);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Medicine medicine)
    {
        _context.Medicines.Remove(medicine);
        await _context.SaveChangesAsync();
    }
    public async Task<List<Medicine>> GetAllActiveMedicinesAsync()
    {
        // Fetches every active medicine in the entire system
        return await _context.Medicines
            .Where(m => m.IsActive)
            .ToListAsync();
    }
}