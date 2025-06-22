using Backend.Models;
using MongoDB.Driver;
using Microsoft.Extensions.Options;

namespace Backend.Services.userPostService;

public class DeletePost
{
    private readonly IMongoCollection<Post> _postsCollection;
   
    public DeletePost(IOptions<MongoDbSettings> settings, IMongoClient mongoClient)
    {
        var database = mongoClient.GetDatabase(settings.Value.DatabaseName);
        _postsCollection = database.GetCollection<Post>(settings.Value.PostsCollectionName);
    }
    
    public async Task DeleteAsync(string id, Post post)=>
        await _postsCollection.DeleteOneAsync(p => p.Id == post.Id);
}