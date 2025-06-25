using MongoDB.Driver;
using Backend.Models;
using Backend.Data;

namespace Backend.Services.userPostFeedbacksService.LikeServices;

public class CreateLike
{
    private readonly IMongoCollection<Feedbacks> _interactionsCollection;

    public CreateLike(FeedbacksContext feedbacksContext)
    {
        _interactionsCollection = feedbacksContext.feedbacks;
    }
    
    public async Task CreateAsync(Feedbacks feedbacks) => 
        await _interactionsCollection.InsertOneAsync(feedbacks);
}