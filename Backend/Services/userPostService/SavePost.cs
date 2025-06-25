using Backend.Models;
using MongoDB.Driver;
using Backend.Data;

namespace Backend.Services.userPostService
{
    public class SavePost
    {
        private readonly IMongoCollection<Post> _postsCollection;

        public SavePost(PostsContext postsContext)
        {
            _postsCollection = postsContext.Posts;
        }

        public async Task SaveInputAsync(Post post)
        {
            await _postsCollection.InsertOneAsync(post);
        }
    }
}