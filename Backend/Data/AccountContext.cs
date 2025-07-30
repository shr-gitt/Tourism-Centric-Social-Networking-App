using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Backend.Data;

public class AccountContext
{

    private readonly IMongoDatabase _database;

    public AccountContext(IOptions<MongoDbSettings> settings, IMongoClient mongoClient)
    {
        _database = mongoClient.GetDatabase(settings.Value.DatabaseName);
    }
    
    public IMongoCollection<ApplicationUser> Users =>
        _database.GetCollection<ApplicationUser>("TouristUsers");

}