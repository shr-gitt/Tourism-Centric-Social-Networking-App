using Backend.Data;
using MongoDB.Driver;
using Backend.Models;

namespace Backend.Services.userPostFeedbacksService;

public class EditFeedback
{
    private readonly IMongoCollection<Feedback> _feedbackCollection;

    public EditFeedback(FeedbacksContext feedbacksContext)
    {
        _feedbackCollection = feedbacksContext.Feedbacks;
    }
    
    public async Task<bool> Edit(Feedback feedback)
    {
        var result = await _feedbackCollection.ReplaceOneAsync(f => f.Id == feedback.Id, feedback);
        return result.IsAcknowledged && result.ModifiedCount > 0;
    }
}