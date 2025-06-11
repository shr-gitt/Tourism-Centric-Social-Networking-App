using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Backend.Data
{
    public class PostsContext
    {
        public PostsContext(IOptions<MongoDBSettings> settings, IMongoClient client)
        {
            var config = settings.Value;
            var database = client.GetDatabase(config.DatabaseName);
            Posts = database.GetCollection<Post>(config.TouristPostsCollectionName);
        }

        public IMongoCollection<Post> Posts { get; }
    }

}