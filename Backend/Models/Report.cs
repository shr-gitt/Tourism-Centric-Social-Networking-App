using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace Backend.Models;

public class Report
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    [BsonElement("_id")]
    public string? ReportId { get; set; }
    
    public required string PostId { get; set; }
    
    public required string UserId { get; set; }
    
    public required string Title { get; set; }
}