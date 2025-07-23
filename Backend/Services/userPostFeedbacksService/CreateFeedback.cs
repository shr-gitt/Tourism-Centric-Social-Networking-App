using MongoDB.Driver;
using Backend.Models;
using Backend.Data;
using Backend.Services.userPostService;

namespace Backend.Services.userPostFeedbacksService;

public class CreateFeedback
{
    private readonly IMongoCollection<Feedback> _feedbackCollection;
    private readonly IMongoCollection<Post> _postsCollection;
    private readonly UpdateFeedback _updateFeedbackService;

    public CreateFeedback(
        FeedbacksContext feedbacksContext,
        PostsContext postsContext,
        UpdateFeedback updateFeedbackService) 
    {
        _feedbackCollection = feedbacksContext.Feedbacks;
        _postsCollection = postsContext.Posts;
        _updateFeedbackService = updateFeedbackService;
    }

    public async Task<bool> CreateAsync(Feedback feedback)
    {
        if (feedback == null) 
            throw new ArgumentNullException(nameof(feedback));

        var postExists = await _postsCollection.Find(p => p.PostId == feedback.PostId).AnyAsync();
        if (!postExists)
        {
            throw new InvalidOperationException($"Post with id {feedback.PostId} does not exist.");
        }

        await _feedbackCollection.InsertOneAsync(feedback);
        
        await _updateFeedbackService.UpdateAsync(feedback.PostId);

        return true;
    }
}