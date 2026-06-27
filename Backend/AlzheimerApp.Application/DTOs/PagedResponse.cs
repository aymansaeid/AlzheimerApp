namespace AlzheimerApp.Application.DTOs;

public class PagedResponse<T>
{
    public List<T> Items { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }

    // Toplam sayfa sayısını otomatik hesaplar
    public int TotalPages => (int)Math.Ceiling((double)TotalCount / PageSize);
}