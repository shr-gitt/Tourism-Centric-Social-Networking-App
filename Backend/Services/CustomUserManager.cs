using Microsoft.AspNetCore.Identity;
using Backend.Models;
using Microsoft.Extensions.Options;

namespace Backend.Services;

public class CustomUserManager : UserManager<ApplicationUser>
{
    public CustomUserManager(
        IUserStore<ApplicationUser> store,
        IOptions<IdentityOptions> optionsAccessor,
        IPasswordHasher<ApplicationUser> passwordHasher,
        IEnumerable<IUserValidator<ApplicationUser>> userValidators,
        IEnumerable<IPasswordValidator<ApplicationUser>> passwordValidators,
        ILookupNormalizer keyNormalizer,
        IdentityErrorDescriber errors,
        IServiceProvider services,
        ILogger<UserManager<ApplicationUser>> logger
    ) : base(store, optionsAccessor, passwordHasher, userValidators, passwordValidators, keyNormalizer, errors, services, logger)
    {
    }

    public override Task<string> GeneratePasswordResetTokenAsync(ApplicationUser user)
    {
        // Use your custom provider explicitly
        return GenerateUserTokenAsync(user, "TokenProvider", ResetPasswordTokenPurpose);
    }

    public override Task<string> GenerateEmailConfirmationTokenAsync(ApplicationUser user)
    {
        return GenerateUserTokenAsync(user, "TokenProvider", "TwoFactor");
    }
}