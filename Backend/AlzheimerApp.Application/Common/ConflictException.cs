namespace AlzheimerApp.Application.Common;

/// <summary>
/// The request conflicts with existing data (e.g. the e-mail address is already in use). Maps to HTTP 409.
/// </summary>
public class ConflictException : Exception
{
    public ConflictException(string message) : base(message) { }
}