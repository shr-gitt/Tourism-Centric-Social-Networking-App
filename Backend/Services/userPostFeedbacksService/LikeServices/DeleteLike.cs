using Backend.Data;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services.userPostFeedbacksService.LikeServices;

public class DeleteLike
{
    private readonly IMongoCollection<Feedbacks> _feedbacksCollection;

    public DeleteLike(FeedbacksContext feedbacksContext)
    {
        _feedbacksCollection = feedbacksContext.feedbacks;
    }
    
    public async Task DeleteAsync(Feedbacks feedbacks)=>
        await _feedbacksCollection.DeleteOneAsync(x => x.Id == feedbacks.Id);
}