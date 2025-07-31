using MongoDB.Driver;
using Backend.Models;
using Backend.Data;

namespace Backend.Services;

public class AccountServices
{
    private readonly IMongoCollection<ApplicationUser> _usersCollection;

    public AccountServices(AccountContext usersContext)
    {
        _usersCollection = usersContext.Users;
    }
    
    public async Task<List<ApplicationUser>> GetAsync()=>
        await _usersCollection.Find(_ => true).ToListAsync();

    public async Task<ApplicationUser?> GetByUserNameAsync(string username)
    {
        return await _usersCollection.Find(p => p.UserName == username).FirstOrDefaultAsync();
    }
}