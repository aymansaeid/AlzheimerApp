namespace AlzheimerApp.Application.DTOs.Followers
{
    public class TrackedPatientResponse
    {
        public Guid PatientId { get; set; }
        public string FullName { get; set; }
        public string? ProfilePhotoUrl { get; set; }

        public bool IsPrimaryAdmin { get; set; }

        public PatientPermissions Permissions { get; set; } = PatientPermissions.None;
        public DateTime JoinedAt { get; set; }

    }
}
