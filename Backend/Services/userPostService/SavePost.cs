using Backend.Models;
using MongoDB.Driver;
using Microsoft.Extensions.Options;

namespace Backend.Services.userPostService
{
    public class SavePost
    {
        private readonly IMongoCollection<Post> _postsCollection;

        public SavePost(IOptions<MongoDbSettings> settings,IMongoClient mongoClient)
        {
            var database = mongoClient.GetDatabase(settings.Value.DatabaseName);
            _postsCollection = database.GetCollection<Post>(settings.Value.PostsCollectionName);
        }

        public async Task SaveInputAsync(Post post)
        {
            await _postsCollection.InsertOneAsync(post);
        }
    }
}