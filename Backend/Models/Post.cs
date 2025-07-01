using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Backend.Models;

public class Post
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }
    public required string  Title { get; set; }
    public required string Location { get; set; } = "Nepal";
    public required string Content { get; set; }
    public DateTime? Created { get; set; } = DateTime.Now;
    public List<string>? Image { get; set; }
}