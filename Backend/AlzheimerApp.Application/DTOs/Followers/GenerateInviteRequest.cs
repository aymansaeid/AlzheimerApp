namespace AlzheimerApp.Application.DTOs.Followers;

public class GenerateInviteRequest
{
    public Guid PatientId { get; set; }
    public bool IsPrimaryInvite { get; set; } // Patient sends True, Caregiver sends False
}