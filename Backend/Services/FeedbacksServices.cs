using Backend.Data;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services
{
    public class FeedbacksService
    {
        private readonly IMongoCollection<Feedback> _feedbacksCollection;
        private readonly PostServices _postServices;
        private readonly IMongoCollection<Post> _postsCollection;

        public FeedbacksService(
            FeedbacksContext feedbacksContext,
            PostServices postServices,
            PostsContext postsContext
            )
        {
            _feedbacksCollection = feedbacksContext.Feedbacks;
            _postServices = postServices;
            _postsCollection = postsContext.Posts;
        }

        public async Task<List<Feedback>> GetAsync() =>
            await _feedbacksCollection.Find(_ => true).ToListAsync();

        public async Task<Feedback?> GetByIdAsync(string id) =>
            await _feedbacksCollection.Find(f => f.FeedbackId == id).FirstOrDefaultAsync();

        public async Task<List<Feedback>> GetByPostIdAsync(string postId) =>
            await _feedbacksCollection.Find(f => f.PostId == postId).ToListAsync();

        public async Task<bool> CreateAsync(Feedback feedback)
        {
            if (feedback == null) 
                throw new ArgumentNullException(nameof(feedback));

            var postExists = await _postsCollection.Find(p => p.PostId == feedback.PostId).AnyAsync();
            if (!postExists)
            {
                throw new InvalidOperationException($"Post with id {feedback.PostId} does not exist.");
            }

            await _feedbacksCollection.InsertOneAsync(feedback);
        
            await _postServices.UpdateAsync(feedback.PostId);

            return true;
        }
        
        public async Task<bool> DeleteAsync(string id)
        {
            if (string.IsNullOrWhiteSpace(id))
                throw new ArgumentException("Feedback id cannot be null or empty.", nameof(id));
        
            var feedback = await _feedbacksCollection.Find(f => f.FeedbackId == id).FirstOrDefaultAsync();
    
            if (feedback == null)
                return false;

            var result = await _feedbacksCollection.DeleteOneAsync(f => f.FeedbackId == id);
        
            await _postServices.UpdateAsync(feedback.PostId);

            return result.DeletedCount > 0;
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

            var result = await _feedbacksCollection.UpdateOneAsync(
                f => f.FeedbackId == feedback.FeedbackId,
                updateDefinition);
        
            await _postServices.UpdateAsync(feedback.PostId);

            return result.IsAcknowledged && result.ModifiedCount > 0;
        }
    }
}