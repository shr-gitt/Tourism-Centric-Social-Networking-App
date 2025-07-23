using Backend.Data;
using Backend.Models;
using Backend.Services.userPostService;
using MongoDB.Bson;
using MongoDB.Bson.Serialization.Conventions;
using MongoDB.Driver;

namespace Backend.Services.userPostFeedbacksService;

public class DeleteFeedback
{
    private readonly IMongoCollection<Feedback> _feedbackCollection;
    private readonly IMongoCollection<Post> _postsCollection;
    private readonly UpdateFeedback _updateFeedbackService;
    
    public DeleteFeedback(
        FeedbacksContext feedbacksContext,
        PostsContext postsContext,
        UpdateFeedback updateFeedbackService) 
    {
        _feedbackCollection = feedbacksContext.Feedbacks;
        _postsCollection = postsContext.Posts;
        _updateFeedbackService = updateFeedbackService;
    }
    
    public async Task<bool> DeleteAsync(string id)
    {
        if (string.IsNullOrWhiteSpace(id))
            throw new ArgumentException("Feedback id cannot be null or empty.", nameof(id));
        
        var feedback = await _feedbackCollection.Find(f => f.FeedbackId == id).FirstOrDefaultAsync();
    
        if (feedback == null)
            return false;

        var result = await _feedbackCollection.DeleteOneAsync(f => f.FeedbackId == id);
        
        await _updateFeedbackService.UpdateAsync(feedback.PostId);

        return result.DeletedCount > 0;
    }
}