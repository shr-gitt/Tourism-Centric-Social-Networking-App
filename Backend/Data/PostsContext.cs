using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Backend.Data
{
    public class PostsContext
    {
        private readonly IMongoDatabase _database;

        public PostsContext(IOptions<MongoDbSettings> settings, IMongoClient client)
        {
            _database = client.GetDatabase(settings.Value.DatabaseName);
        }

        public IMongoCollection<Post> Posts =>
            _database.GetCollection<Post>("TouristPosts");
    }
}
