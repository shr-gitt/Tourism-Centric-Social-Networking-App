using MongoDB.Driver;
using Backend.Models;
using Backend.Data;

namespace Backend.Services.userService;

public class DeleteUser
{
    private readonly IMongoCollection<User> _usersCollection;
    private readonly IMongoCollection<Post> _postsCollection;
    private readonly IMongoCollection<Feedback> _feedbacksCollection;

    public DeleteUser(UsersContext usersContext, PostsContext postsContext, FeedbacksContext feedbacksContext)
    {
        _usersCollection = usersContext.Users;
        _postsCollection = postsContext.Posts;
        _feedbacksCollection = feedbacksContext.Feedbacks;
    }

    public async Task DeleteAsync(string id)
    {
        await _feedbacksCollection.DeleteOneAsync(p => p.UserId == id);
        await _postsCollection.DeleteOneAsync(p => p.UserId == id);
        await _usersCollection.DeleteOneAsync(p => p.UserId == id);
    }
}