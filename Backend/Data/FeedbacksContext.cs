using Microsoft.Extensions.Options;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Data;

public class FeedbacksContext
{
    private readonly IMongoDatabase _database;

    public FeedbacksContext(IOptions<MongoDbSettings> settings, IMongoClient mongoClient)
    {
        _database = mongoClient.GetDatabase(settings.Value.DatabaseName);
    }
    
    public IMongoCollection<Feedbacks> feedbacks =>
    _database.GetCollection<Feedbacks>("TouristInteractions");
}