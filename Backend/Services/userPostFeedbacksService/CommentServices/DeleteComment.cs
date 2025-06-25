using Backend.Data;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services.userPostFeedbacksService.CommentServices;

public class DeleteComment
{
    private readonly IMongoCollection<Feedbacks> _feedbacksCollection;

    public DeleteComment(FeedbacksContext feedbacksContext)
    {
        _feedbacksCollection = feedbacksContext.feedbacks;
    }
    
    public async Task DeleteAsync(Feedbacks feedbacks)=>
        await _feedbacksCollection.DeleteOneAsync(x => x.Id == feedbacks.Id);
}