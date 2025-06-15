using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using System.ComponentModel.DataAnnotations;

namespace Backend.Models;

public class Post
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string Id { get; set; }
    public string Title { get; set; }
    public string Location { get; set; } = "Nepal";
    public string Content { get; set; }
    public DateTime? Created { get; set; } = DateTime.Now;
    public string? Image { get; set; }
}