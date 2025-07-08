using Backend.Models;
using Microsoft.Extensions.Options;
using MongoDB.Driver;
using Backend.Data;

namespace Backend.Services
{
    public class PostServices
    {
        private readonly IMongoCollection<Post> _postsCollection;

        public PostServices(PostsContext postsContext)
        {
            _postsCollection = postsContext.Posts;
        }

        public async Task<List<Post>> GetAsync() =>
            await _postsCollection.Find(_ => true).ToListAsync();

        public async Task<Post?> GetByIdAsync(string id) =>
            await _postsCollection.Find(p => p.PostId == id).FirstOrDefaultAsync();
    }
}