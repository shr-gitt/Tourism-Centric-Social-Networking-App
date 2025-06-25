using Backend.Data;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services.userPostFeedbacksService.DislikeServices;

public class CreateDislike
{
    private readonly IMongoCollection<Feedbacks> _feedbacksCollection;

    public CreateDislike(FeedbacksContext feedbacksContext)
    {
        _feedbacksCollection = feedbacksContext.feedbacks;
    }
    
    public async Task CreateAsync(Feedbacks feedbacks)=>
        await _feedbacksCollection.InsertOneAsync(feedbacks);
}