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

        public async Task CreateAsync(Post post)
        {
            Console.WriteLine("Preparing to insert post...");

            try
            {
                await _postsCollection.InsertOneAsync(post);
                Console.WriteLine("Insert successful");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Insert failed: " + ex.Message);
            }

        }

        public async Task UpdateAsync(string id, Post updated) =>
            await _postsCollection.ReplaceOneAsync(p => p.Id == id, updated);

        public async Task DeleteAsync(string id) =>
            await _postsCollection.DeleteOneAsync(p => p.Id == id);
    }
}