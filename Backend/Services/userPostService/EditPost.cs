using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services.userPostService;

public class EditPost
{
    private readonly IMongoCollection<Post> _postsCollection;
    
    public async Task EditAsync(Post post)=>
    await _postsCollection.ReplaceOneAsync(p => p.Id == post.Id, post);
}