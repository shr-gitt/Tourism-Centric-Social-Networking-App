using Backend.Models;
using MongoDB.Driver;
using Backend.Data;

namespace Backend.Services.userPostService;

public class UpdateFeedback
{
    private readonly IMongoCollection<Post> _postsCollection;
    private readonly IMongoCollection<Feedback> _feedbacksCollection;
    
    public UpdateFeedback(PostsContext postsContext, FeedbacksContext feedbacksContext)
    {
        _postsCollection = postsContext.Posts;
        _feedbacksCollection = feedbacksContext.Feedbacks;
    }

    public async Task UpdateAsync(string postId)
    {
        var likeCount = Convert.ToInt32(await _feedbacksCollection.CountDocumentsAsync(f => f.PostId == postId && f.Like == true));
        var dislikeCount = Convert.ToInt32(await _feedbacksCollection.CountDocumentsAsync(f => f.PostId == postId && f.Like == false));
        var commentCount = Convert.ToInt32(await _feedbacksCollection.CountDocumentsAsync(f => f.PostId == postId && !string.IsNullOrEmpty(f.Comment)));

        var update = Builders<Post>.Update.Set(p => p.Feedback, new FeedbackSummary
        {
            likeCount = likeCount,
            dislikeCount = dislikeCount,
            commentCount = commentCount
        });

        await _postsCollection.UpdateOneAsync(p => p.PostId == postId, update);
    }
}
