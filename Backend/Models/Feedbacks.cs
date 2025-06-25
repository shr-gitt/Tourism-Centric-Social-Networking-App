namespace Backend.Models;

public class Feedbacks
{
    public string? Id { get; set; }
    public bool? Like { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.Now;
}