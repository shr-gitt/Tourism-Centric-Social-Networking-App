using Backend.Data;
using Backend.Models;   
using MongoDB.Driver;

namespace Backend.Services
{
    public class FeedbacksServices
    {
        private readonly IMongoCollection<Feedbacks> _feedbacksCollection;

        public FeedbacksServices(FeedbacksContext feedbacksContext)
        {
            _feedbacksCollection = feedbacksContext.feedbacks;
        }
        
        public async Task<List<Feedbacks>> GetAsync() =>
            await _feedbacksCollection.Find(_ => true).ToListAsync();
    }
}