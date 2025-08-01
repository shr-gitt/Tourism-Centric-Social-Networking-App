using Backend.Models;
using MongoDB.Driver;
using Microsoft.Extensions.Options;
using Backend.Data;

namespace Backend.Services.userPostService;

public class EditPost
{
    private readonly IMongoCollection<Post> _postsCollection;
    
    public EditPost(PostsContext postsContext,FeedbacksContext feedbacksContext)
    {
        _postsCollection = postsContext.Posts;
    }
    
    public async Task EditAsync(string id,Post post)=>
    await _postsCollection.ReplaceOneAsync(p => p.PostId == post.PostId, post);
}