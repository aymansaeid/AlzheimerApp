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
}