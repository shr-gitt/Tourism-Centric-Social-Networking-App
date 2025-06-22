using Backend.Models;
using MongoDB.Driver;
using Microsoft.Extensions.Options;

namespace Backend.Services.userPostService;

public class EditPost
{
    private readonly IMongoCollection<Post> _postsCollection;
    
    public EditPost(IOptions<MongoDbSettings> settings, IMongoClient mongoClient)
    {
        var database = mongoClient.GetDatabase(settings.Value.DatabaseName);
        _postsCollection = database.GetCollection<Post>(settings.Value.PostsCollectionName);
    }
    
    public async Task EditAsync(string id,Post post)=>
    await _postsCollection.ReplaceOneAsync(p => p.Id == post.Id, post);
}