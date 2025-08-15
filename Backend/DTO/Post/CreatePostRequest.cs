namespace Backend.DTO.Post;

public class CreatePostRequest
{
    public string? UserId { get; set; }
    public string? Title { get; set; }
    public string? Location { get; set; }
    public string? Content { get; set; }
    public List<IFormFile>? Images { get; set; }
}