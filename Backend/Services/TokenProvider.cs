using System.Security.Claims;
using Microsoft.AspNetCore.Identity;
using System.Threading.Tasks;
using System.Linq;
using System;

namespace Backend.Services
{
    public class TokenProvider<ApplicationUser> : IUserTwoFactorTokenProvider<ApplicationUser> where ApplicationUser : class
    {
        public async Task<string> GenerateAsync(string purpose, UserManager<ApplicationUser> manager, ApplicationUser user)
        {
            var random = new Random();
            var code = random.Next(100000, 999999).ToString(); // 6-digit code

            // Store code with expiration in user claim
            var expiration = DateTime.UtcNow.AddMinutes(5);
            var claim = new Claim(purpose, $"{code}|{expiration:O}");

            // Get existing claims and remove if necessary
            var claims = await manager.GetClaimsAsync(user);
            var existingClaim = claims.FirstOrDefault(c => c.Type == purpose);
            if (existingClaim != null)
                await manager.RemoveClaimAsync(user, existingClaim);

            // Add the new claim
            await manager.AddClaimAsync(user, claim);

            return code;
        }

        public async Task<bool> ValidateAsync(string purpose, string token, UserManager<ApplicationUser> manager, ApplicationUser user)
        {
            var claims = await manager.GetClaimsAsync(user);
            var resetClaim = claims.FirstOrDefault(c => c.Type == purpose);

            if (resetClaim == null)
                return false;

            var parts = resetClaim.Value.Split('|');
            if (parts.Length != 2)
                return false;

            var storedCode = parts[0];
            if (storedCode != token)
                return false;

            if (!DateTime.TryParse(parts[1], out var expiration) || expiration < DateTime.UtcNow)
                return false;

            return true;
        }

        public Task<bool> CanGenerateTwoFactorTokenAsync(UserManager<ApplicationUser> manager, ApplicationUser user)
            => Task.FromResult(true);
    }
}
