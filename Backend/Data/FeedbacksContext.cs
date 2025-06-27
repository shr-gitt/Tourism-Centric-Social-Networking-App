using Microsoft.Extensions.Options;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Data
{
    public class FeedbacksContext
    {
        private readonly IMongoDatabase _database;
        private readonly string _feedbacksCollectionName;

        public FeedbacksContext(IOptions<MongoDbSettings> settings, IMongoClient mongoClient)
        {
            _database = mongoClient.GetDatabase(settings.Value.DatabaseName);
            _feedbacksCollectionName = settings.Value.FeedbacksCollectionName;
        }
        
        public IMongoCollection<Feedback> Feedbacks =>
            _database.GetCollection<Feedback>(_feedbacksCollectionName);
    }
}