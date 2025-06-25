using Backend.Models;
using Backend.Data;
using MongoDB.Driver;

namespace Backend.Services.userPostService;

public class DeletePost
{
    private readonly IMongoCollection<Post> _postsCollection;
   
    public DeletePost(PostsContext postsContext)
    {
        _postsCollection = postsContext.Posts;
    }
    
    public async Task DeleteAsync(string id, Post post)=>
        await _postsCollection.DeleteOneAsync(p => p.Id == post.Id);
}