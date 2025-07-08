using MongoDB.Driver;
using Backend.Models;
using Backend.Data;

namespace Backend.Services.userService;

public class EditUser
{
    private readonly IMongoCollection<User> _usersCollection;

    public EditUser(UsersContext usersContext)
    {
        _usersCollection=usersContext.Users;
    }

    public async Task EditAsync(User user)
    {
        await _usersCollection.ReplaceOneAsync(p => p.UserId == user.UserId, user);
    }
}