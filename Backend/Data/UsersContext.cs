using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Backend.Data;

public class UsersContext
{
    private readonly IMongoDatabase _database;

    public UsersContext(IOptions<MongoDbSettings> settings, IMongoClient mongoClient)
    {
        _database = mongoClient.GetDatabase(settings.Value.DatabaseName);
    }
    
    public IMongoCollection<User> Users =>
        _database.GetCollection<User>("TouristUsers");
}