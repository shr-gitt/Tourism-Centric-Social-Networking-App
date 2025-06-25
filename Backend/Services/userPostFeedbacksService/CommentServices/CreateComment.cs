using Backend.Models;
using Backend.Data;
using MongoDB.Driver;

namespace Backend.Services.userPostFeedbacksService.CommentServices;

public class CreateComment
{
    private readonly IMongoCollection<Feedbacks> _feedbacksCollection;

    public CreateComment(FeedbacksContext feedbacksContext)
    {
        _feedbacksCollection = feedbacksContext.feedbacks;
    }
    
    public async Task CreateAsync(Feedbacks feedbacks)=>
        await _feedbacksCollection.InsertOneAsync(feedbacks);
}