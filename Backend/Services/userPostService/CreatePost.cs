using MongoDB.Driver;
using Backend.Models;
using Microsoft.Extensions.Options;

namespace Backend.Services.userPostService;

public class CreatePost
{
    private readonly IMongoCollection<Post> _postsCollection;
    
    public CreatePost(IOptions<MongoDbSettings> mongoDbSettings)
    {
        var mongoClient = new MongoClient(mongoDbSettings.Value.ConnectionString);
        var mongoDatabase = mongoClient.GetDatabase(mongoDbSettings.Value.DatabaseName);
        _postsCollection = mongoDatabase.GetCollection<Post>(mongoDbSettings.Value.PostsCollectionName);
    }
    
    public async Task CreateAsync(Post post) => 
        await _postsCollection.InsertOneAsync(post);
}