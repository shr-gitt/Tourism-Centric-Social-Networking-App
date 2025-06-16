using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services.userPostService;

public class DeletePost
{
    private readonly IMongoCollection<Post> _postsCollection;
    
    public async Task DeleteAsync(Post post)=>
        await _postsCollection.DeleteOneAsync(p => p.Id == post.Id);
}