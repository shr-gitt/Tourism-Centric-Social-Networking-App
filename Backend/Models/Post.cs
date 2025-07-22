using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;
using Backend.Models;

namespace Backend.Models
{
    public class Post
    {
        [BsonId]
        [BsonRepresentation(BsonType.ObjectId)]
        public string? PostId { get; set; }

        [BsonRepresentation(BsonType.ObjectId)]
        public required string UserId { get; set; }

        public required string Title { get; set; }
        public string? Location { get; set; }
        public required string Content { get; set; }
        public DateTime? Created { get; set; } = DateTime.Now;
        public List<string>? Image { get; set; }

        public FeedbackSummary? Feedback { get; set; }
    }
    
    public class FeedbackSummary
    {
        public int likeCount { get; set; }
        public int dislikeCount { get; set; }
        public int commentCount { get; set; }
    }
}
