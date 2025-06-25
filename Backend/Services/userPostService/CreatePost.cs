using MongoDB.Driver;
using Backend.Models;
using Backend.Data;
using Microsoft.Extensions.Options;

namespace Backend.Services.userPostService;

public class CreatePost
{
    private readonly IMongoCollection<Post> _postsCollection;
    
    public CreatePost(PostsContext postsContext)
    {
        _postsCollection = postsContext.Posts;
    }
    
    public async Task CreateAsync(Post post) => 
        await _postsCollection.InsertOneAsync(post);
}