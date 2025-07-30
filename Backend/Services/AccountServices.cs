using MongoDB.Driver;
using Backend.Models;
using Backend.Data;
using MongoDB.Bson;

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

    public async Task<ApplicationUser?> GetByIdAsync(string id)
    {
        if (!ObjectId.TryParse(id, out var objectId))
        {
            Console.WriteLine($"Invalid ObjectId format: {id}");
            return null; 
        }

        return await _usersCollection.Find(p => p.Id == objectId).FirstOrDefaultAsync();
        //await _usersCollection.Find(p => p.Id == ObjectId.Parse(id)).FirstOrDefaultAsync();
    }
}