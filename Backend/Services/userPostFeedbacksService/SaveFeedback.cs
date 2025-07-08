using Backend.Data;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services.userPostFeedbacksService;

public class SaveFeedback
{
    private readonly IMongoCollection<Feedback> _feedbacksCollection;

    public SaveFeedback(FeedbacksContext feedbacksContext)
    {
        _feedbacksCollection = feedbacksContext.Feedbacks;
    }

   /* public async Task<bool> SaveAsync(Feedback feedback)
    {
        if (string.IsNullOrWhiteSpace(feedback.PostId))
            throw new ArgumentException("PostId is required.");

        await _feedbacksCollection.InsertOneAsync(feedback);
        return true;
    }*/
   public async Task<bool> SaveAsync(Feedback feedback)
   {
       if (string.IsNullOrWhiteSpace(feedback.PostId)){
           throw new ArgumentException("PostId and UserId are required.");
       }
       var filter = Builders<Feedback>.Filter.Where(f =>
           f.PostId == feedback.PostId);

       var update = Builders<Feedback>.Update
           .Set(f => f.Like, feedback.Like)
           .Set(f => f.Comment, feedback.Comment)
           .Set(f => f.CreatedAt, DateTime.UtcNow); 

       var options = new UpdateOptions { IsUpsert = true };

       var result = await _feedbacksCollection.UpdateOneAsync(filter, update, options);

       return result.IsAcknowledged;
   }
}