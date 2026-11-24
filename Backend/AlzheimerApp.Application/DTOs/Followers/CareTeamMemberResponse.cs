namespace AlzheimerApp.Application.DTOs.Followers
{
    public class CareTeamMemberResponse
    {
        public Guid FollowerId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Phone { get; set; } = string.Empty;
        public string? ProfilePhotoUrl { get; set; }

        public string RelationshipType { get; set; } 
        public bool IsPrimary { get; set; }
        public DateTime JoinedAt { get; set; }


    }
}
