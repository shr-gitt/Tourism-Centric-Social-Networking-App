using Backend.Data;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services
{
    public class FeedbacksService
    {
        private readonly IMongoCollection<Feedback> _feedbacksCollection;

        public FeedbacksService(FeedbacksContext feedbacksContext)
        {
            _feedbacksCollection = feedbacksContext.Feedbacks;
        }

        public async Task<List<Feedback>> GetAsync() =>
            await _feedbacksCollection.Find(_ => true).ToListAsync();

        public async Task<Feedback?> GetByIdAsync(string id) =>
            await _feedbacksCollection.Find(f => f.Id == id).FirstOrDefaultAsync();

        public async Task<List<Feedback>> GetByPostIdAsync(string postId) =>
            await _feedbacksCollection.Find(f => f.PostId == postId).ToListAsync();

    }
}