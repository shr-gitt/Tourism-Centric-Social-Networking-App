using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using Backend.Models;

namespace Backend.Models;

public class Feedback
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    [BsonElement("id")] 
    public string? FeedbackId { get; set; }
    
    [BsonRepresentation(BsonType.ObjectId)]
    public string? UserId { get; set; }
    
    [BsonRepresentation(BsonType.ObjectId)]
    [BsonElement("PostId")]
    public string PostId { get; set; } = null!;
    public bool? Like { get; set; }
    public string? Comment { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}


