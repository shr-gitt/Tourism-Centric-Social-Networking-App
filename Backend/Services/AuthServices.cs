using MongoDB.Driver;
using Backend.Models;

namespace Backend.Services;

public class AuthServices
{
    private readonly IMongoCollection<User> _users;
    
    private readonly IMongoCollection<Feedback> _feedbacksCollection;

    public AuthServices(IMongoCollection<User> users, IMongoCollection<Feedback> feedbacksCollection)
    {
        _users = users;
        _feedbacksCollection = feedbacksCollection;
    }
    
    public class AuthResult
    {
        public bool Success { get; set; }
        public string? ErrorMessage { get; set; }
        public string? current_uid { get; set; }
    }
    
    public async Task<List<Feedback>> GetAsync() =>
    await _feedbacksCollection.Find(_ => true).ToListAsync();
    
    public async Task<Feedback?> GetByIdAsync(string id) =>
    await _feedbacksCollection.Find(f => f.FeedbackId == id).FirstOrDefaultAsync();

    public async Task<AuthResult> RegisterAsync(User user)
    {
        var existingUser = await _users.Find(u => u.Email == user.Email).FirstOrDefaultAsync();
        if (existingUser != null)
        {
            return new AuthResult
            {
                Success = false,
                ErrorMessage = "User already exists."
            };
        }

        user.Password=BCrypt.Net.BCrypt.HashPassword(user.Password);
        await _users.InsertOneAsync(user);
        
        return new AuthResult
        {
            Success = true,
        };
    }

    public async Task<AuthResult> LoginAsync(User user)
    {
        var existingUser = await _users.Find(u => u.Email == user.Email).FirstOrDefaultAsync();

        if (existingUser == null)
        {
            return new AuthResult
            {
                Success = false,
                ErrorMessage = "User not found."
            };
        }

        if (!BCrypt.Net.BCrypt.Verify(user.Password, existingUser.Password))
        {
            return new AuthResult
            {
                Success = false,
                ErrorMessage = "Invalid credentials."
            };
        }

        return new AuthResult
        {
            Success = true,
            current_uid = existingUser.UserId,
        };
    }
}