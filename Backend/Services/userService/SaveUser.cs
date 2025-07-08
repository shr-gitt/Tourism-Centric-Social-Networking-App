using MongoDB.Driver;
using Backend.Models;
using Backend.Data;

namespace Backend.Services.userService;

public class SaveUser
{
    private readonly IMongoCollection<User> _usersCollection;

    public SaveUser(UsersContext usersContext)
    {
        _usersCollection = usersContext.Users;
    }
    
    public async Task SaveAsync(User user)=>
        await _usersCollection.InsertOneAsync(user);
}