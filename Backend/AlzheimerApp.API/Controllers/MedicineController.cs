using AlzheimerApp.Application.DTOs.Medicines;
using AlzheimerApp.Application.Interfaces.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace AlzheimerApp.API.Controllers;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class MedicineController : ControllerBase
{
    private readonly IMedicineService _medicineService;

    public MedicineController(IMedicineService medicineService)
    {
        _medicineService = medicineService;
    }

    [Authorize(Roles = "Follower,Admin")]
    [HttpPost]
    public async Task<IActionResult> AddMedicine([FromBody] MedicineRequest request)
    {
        try
        {
            var response = await _medicineService.AddMedicineAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [HttpGet("patient/{patientId}")]
    public async Task<IActionResult> GetPatientMedicines(Guid patientId)
    {
        try
        {
            var response = await _medicineService.GetPatientMedicinesAsync(patientId);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { Error = ex.Message });
        }
    }

    [Authorize(Roles = "Follower,Admin")]
    [HttpPut("{id}")]
    public async Task<IActionResult> UpdateMedicine(Guid id, [FromBody] UpdateMedicineRequest request)
    {
        try
        {
            await _medicineService.UpdateMedicineAsync(id, request);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }

    [Authorize(Roles = "Follower,Admin")]
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteMedicine(Guid id)
    {
        try
        {
            await _medicineService.DeleteMedicineAsync(id);
            return NoContent();
        }
        catch (Exception ex)
        {
            return NotFound(new { Error = ex.Message });
        }
    }
}