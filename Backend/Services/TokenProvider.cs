using Backend.Models;
using Microsoft.AspNetCore.Identity;

namespace Backend.Services;

public class TokenProvider<ApplicationUser> : IUserTwoFactorTokenProvider<ApplicationUser> where ApplicationUser : class
{
    public Task<string> GenerateAsync(string purpose, UserManager<ApplicationUser> manager, ApplicationUser user)
    {
        var random = new Random();
        var code = random.Next(100000, 999999).ToString(); // always 6 digits
        return Task.FromResult(code);
    }

    public Task<bool> ValidateAsync(string purpose, string token, UserManager<ApplicationUser> manager, ApplicationUser user)
    {
        return Task.FromResult(true);
    }
    
    public Task<bool> CanGenerateTwoFactorTokenAsync(UserManager<ApplicationUser> manager, ApplicationUser user)
    {
        return Task.FromResult(true);
    }
}