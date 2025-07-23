using Backend.Data;
using MongoDB.Driver;
using Backend.Models;
using Backend.Services.userPostService;

namespace Backend.Services.userPostFeedbacksService;

public class EditFeedback
{
    private readonly IMongoCollection<Feedback> _feedbackCollection;
    private readonly IMongoCollection<Post> _postsCollection;
    private readonly UpdateFeedback _updateFeedbackService;

    public EditFeedback(
        FeedbacksContext feedbacksContext,
        PostsContext postsContext,
        UpdateFeedback updateFeedbackService) 
    {
        _feedbackCollection = feedbacksContext.Feedbacks;
        _postsCollection = postsContext.Posts;
        _updateFeedbackService = updateFeedbackService;
    }

    public async Task<bool> Edit(Feedback feedback)
    {
        if (feedback == null || string.IsNullOrEmpty(feedback.FeedbackId))
            throw new ArgumentException("Feedback or Feedback.Id cannot be null.");

        var updates = new List<UpdateDefinition<Feedback>>();
        
        if (feedback.Like.HasValue)
            updates.Add(Builders<Feedback>.Update.Set(f => f.Like, feedback.Like.Value));
        
        if (feedback.Like != null)
            updates.Add(Builders<Feedback>.Update.Set(f => f.Like, feedback.Like));

        if (feedback.Comment != null)
            updates.Add(Builders<Feedback>.Update.Set(f => f.Comment, feedback.Comment));

        if (updates.Count == 0)
            return false;

        var updateDefinition = Builders<Feedback>.Update.Combine(updates);

        var result = await _feedbackCollection.UpdateOneAsync(
            f => f.FeedbackId == feedback.FeedbackId,
            updateDefinition);
        
        await _updateFeedbackService.UpdateAsync(feedback.PostId);

        return result.IsAcknowledged && result.ModifiedCount > 0;
    }
}