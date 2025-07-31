using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Backend.Data;

public class AccountContext
{
    private readonly IMongoDatabase _database;
    public IMongoCollection<ApplicationUser> Users { get; }

    public AccountContext(IOptions<MongoDbSettings> settings, IMongoClient mongoClient, IConfiguration configuration)
    {
        _database = mongoClient.GetDatabase(settings.Value.DatabaseName);
        Users = _database.GetCollection<ApplicationUser>("TouristUsers");

        var indexKeys = Builders<ApplicationUser>.IndexKeys.Ascending(u => u.NormalizedUserName);
        var indexOptions = new CreateIndexOptions { Unique = true };
        var indexModel = new CreateIndexModel<ApplicationUser>(indexKeys, indexOptions);
        Users.Indexes.CreateOne(indexModel);
    }
}