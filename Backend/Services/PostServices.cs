using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;

namespace Backend.Services
{
    public class PostServices
    {
        private readonly IMongoCollection<Post> _postsCollection;

        public PostServices(IOptions<MongoDbSettings> settings, IMongoClient mongoClient)
        {
            var database = mongoClient.GetDatabase(settings.Value.DatabaseName);
            _postsCollection = database.GetCollection<Post>(settings.Value.TouristPostsCollectionName);
        }

        public async Task<List<Post>> GetAsync() =>
            await _postsCollection.Find(_ => true).ToListAsync();

        public async Task<Post?> GetByIdAsync(string id) =>
            await _postsCollection.Find(p => p.Id == id).FirstOrDefaultAsync();
    }
}