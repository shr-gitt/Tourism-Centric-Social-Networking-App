using MongoDB.Driver;
using Backend.Models;
using Microsoft.Extensions.Options;

namespace Backend.Services.userPostService;

public class CreatePost
{
    private readonly IMongoCollection<Post> _postsCollection;
    
    public CreatePost(IOptions<MongoDbSettings> settings, IMongoClient mongoClient)
    {
        var database = mongoClient.GetDatabase(settings.Value.DatabaseName);
        _postsCollection = database.GetCollection<Post>(settings.Value.PostsCollectionName);
    }
    
    public async Task CreateAsync(Post post) => 
        await _postsCollection.InsertOneAsync(post);
}