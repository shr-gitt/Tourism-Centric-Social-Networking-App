using Backend.Data;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services.userPostFeedbacksService;

public class SaveFeedback
{
    private readonly IMongoCollection<Feedback> _feedbacksCollection;

    public SaveFeedback(FeedbacksContext feedbacksContext)
    {
        _feedbacksCollection = feedbacksContext.Feedbacks;
    }

    public async Task<bool> SaveAsync(Feedback feedback)
    {
        if (string.IsNullOrWhiteSpace(feedback.PostId))
            throw new ArgumentException("PostId is required.");

        await _feedbacksCollection.InsertOneAsync(feedback);
        return true;
    }
}