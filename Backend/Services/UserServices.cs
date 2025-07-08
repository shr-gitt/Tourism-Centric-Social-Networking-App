using MongoDB.Driver;
using Backend.Models;
using Backend.Data;

namespace Backend.Services;

public class UserServices
{
    private readonly IMongoCollection<User> _usersCollection;

    public UserServices(UsersContext usersContext)
    {
        _usersCollection = usersContext.Users;
    }
    
    public async Task<List<User>> GetAsync()=>
        await _usersCollection.Find(_ => true).ToListAsync();
    
    public async Task<User?> GetByIdAsync(string id) =>
        await _usersCollection.Find(p => p.UserId == id).FirstOrDefaultAsync();
}