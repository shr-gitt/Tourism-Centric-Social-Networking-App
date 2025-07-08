using Backend.Data;
using Backend.Models;
using MongoDB.Driver;

namespace Backend.Services.userService;

public class CreateUser
{
    private readonly IMongoCollection<User> _usersCollection;

    public CreateUser(UsersContext usersContext)
    {
        _usersCollection = usersContext.Users;
    }
    
    public async Task CreateAsync(User user)=> 
        await _usersCollection.InsertOneAsync(user);
}