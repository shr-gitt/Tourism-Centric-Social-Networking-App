using MongoDB.Driver;
using Backend.Models;

namespace Backend.Services.userPostService;

public class CreatePost
{
    private readonly IMongoCollection<Post> _postsCollection;

    public async Task CreateAsync(Post post) => 
        await _postsCollection.InsertOneAsync(post);
}