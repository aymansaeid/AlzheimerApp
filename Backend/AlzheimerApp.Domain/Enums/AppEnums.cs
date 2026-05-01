namespace AlzheimerApp.Domain.Enums;

public enum UserRole
{
    Patient,
    Follower,
    Admin
}

public enum AlertType
{
    SafeZoneBreach,
    AnomalyDetected,
    MedicineMissed,
    Emergency
}

public enum MedicineStatus
{
    Pending,
    Taken,
    Missed
}

public enum MemoryContentType
{
    Photo,
    Voice,
    IdentityCard
}