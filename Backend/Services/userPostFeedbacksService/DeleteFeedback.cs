using Backend.Data;
using Backend.Models;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Conventions;
using MongoDB.Driver;

namespace Backend.Services.userPostFeedbacksService;

public class DeleteFeedback
{
    private readonly IMongoCollection<Feedback> _feedbacksCollection;

    public DeleteFeedback(FeedbacksContext feedbacksContext)
    {
        _feedbacksCollection = feedbacksContext.Feedbacks;
    }
    
    public async Task<bool> DeleteAsync(string id)
    {
        if (string.IsNullOrWhiteSpace(id))
            throw new ArgumentException("Feedback id cannot be null or empty.", nameof(id));

        var result = await _feedbacksCollection.DeleteOneAsync(f => f.Id == id);
        return result.DeletedCount > 0;
    }
}