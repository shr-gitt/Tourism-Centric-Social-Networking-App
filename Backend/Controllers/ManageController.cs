using MongoDB.Bson;
using Backend.Models;
using Backend.DTO.Manage;
using Backend.Services.userAccount;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    /// <summary>
    /// Manages user account settings like passwords, 2FA, and phone numbers.
    /// </summary>
    [ApiController]
    [Authorize(AuthenticationSchemes = "Bearer")]
    [Route("api/[controller]/[action]")]
    //[ApiExplorerSettings(GroupName = "Manage")]
    public class ManageController : ControllerBase
    {
        private readonly UserManager<ApplicationUser> _userManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IEmailSender _emailSender;
        private readonly ILogger<ManageController> _logger;

        public ManageController(
            UserManager<ApplicationUser> userManager,
            SignInManager<ApplicationUser> signInManager,
            IEmailSender emailSender,
            ILogger<ManageController> logger)
        {
            _userManager = userManager;
            _signInManager = signInManager;
            _emailSender = emailSender;
            _logger = logger;
        }

        /// <summary>Gets current user account settings.</summary>
        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> Index()
        {
            var user = await GetCurrentUserAsync();
            if (user == null)
            {
                _logger.LogInformation("User not found in Index of ManageController.");
                return Unauthorized();
            }

            var response = new
            {
                HasPassword = await _userManager.HasPasswordAsync(user),
                PhoneNumber = await _userManager.GetPhoneNumberAsync(user),
                TwoFactorEnabled = await _userManager.GetTwoFactorEnabledAsync(user),
                ExternalLogins = await _userManager.GetLoginsAsync(user),
                RememberedBrowser = await _signInManager.IsTwoFactorClientRememberedAsync(user),
                AuthenticatorKey = await _userManager.GetAuthenticatorKeyAsync(user)
            };
            return Ok(response);
        }

        /// <summary>Changes the user's password.</summary>
        [HttpPost]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> ChangePassword(ChangePasswordRequest model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            var result = await _userManager.ChangePasswordAsync(user, model.OldPassword, model.NewPassword);
            if (!result.Succeeded)
                return BadRequest(new { Errors = result.Errors.Select(e => e.Description) });

            await _signInManager.SignInAsync(user, false);
            _logger.LogInformation("User changed their password.");
            return Ok(new { Message = "Password changed successfully." });
        }

        /// <summary>Sets a password for a user without one.</summary>
        [HttpPost]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> SetPassword(SetPasswordRequest model)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            var result = await _userManager.AddPasswordAsync(user, model.NewPassword);
            if (!result.Succeeded)
                return BadRequest(new { Errors = result.Errors.Select(e => e.Description) });

            await _signInManager.SignInAsync(user, false);
            return Ok(new { Message = "Password set successfully." });
        }

        /// <summary>Sends a verification SMS to the provided phone number.</summary>
        /*[HttpPost]
        public async Task<IActionResult> AddPhone(AddPhoneNumberRequest model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            var code = await _userManager.GenerateChangePhoneNumberTokenAsync(user, model.PhoneNumber);
            await _smsSender.SendSmsAsync(model.PhoneNumber, $"Your security code is {code}. It expires in 5 minutes.");

            return Ok(new { Message = "Verification code sent." });
        }

        /// <summary>Verifies and sets the user's phone number.</summary>
        [HttpPost]
        public async Task<IActionResult> VerifyPhone(VerifyPhoneNumberRequest model)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            var result = await _userManager.ChangePhoneNumberAsync(user, model.PhoneNumber, model.Code);
            if (!result.Succeeded)
                return BadRequest(new { Errors = result.Errors.Select(e => e.Description) });

            await _signInManager.SignInAsync(user, false);
            return Ok(new { Message = "Phone number verified." });
        }

        /// <summary>Removes the user's phone number.</summary>
        [HttpPost]
        public async Task<IActionResult> RemovePhone()
        {
            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            var result = await _userManager.SetPhoneNumberAsync(user, null);
            if (!result.Succeeded)
                return BadRequest("Failed to remove phone number.");

            await _signInManager.SignInAsync(user, false);
            return Ok(new { Message = "Phone number removed." });
        }*/

        /// <summary>Enables or Disables two-factor authentication for the user.</summary>
        [HttpPost]
        public async Task<IActionResult> TwoFactor(bool ans)
        {
            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            await _userManager.SetTwoFactorEnabledAsync(user, ans);
            await _signInManager.SignInAsync(user, false);
            _logger.LogInformation("User changed to 2FA.{value}",ans);
            return Ok(new { Message = "Two-factor authentication enabled." });
        }
/*
        /// <summary>Resets the user's authenticator key (used for app-based 2FA).</summary>
        [HttpPost]
        public async Task<IActionResult> ResetAuthenticatorKey()
        {
            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            await _userManager.ResetAuthenticatorKeyAsync(user);
            _logger.LogInformation("Authenticator key reset.");
            return Ok(new { Message = "Authenticator key reset." });
        }

        /// <summary>Generates new recovery codes for 2FA.</summary>
        [HttpPost]
        public async Task<IActionResult> GenerateRecoveryCodes()
        {
            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            var codes = await _userManager.GenerateNewTwoFactorRecoveryCodesAsync(user, 5);
            _logger.LogInformation("Recovery codes generated.");
            return Ok(new { RecoveryCodes = codes });
        }

        /// <summary>Removes an external login provider from the user's account.</summary>
        [HttpPost]
        public async Task<IActionResult> RemoveExternalLogin(RemoveLoginRequest model)
        {
            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            var result = await _userManager.RemoveLoginAsync(user, model.LoginProvider, model.ProviderKey);
            if (!result.Succeeded)
                return BadRequest(new { Errors = result.Errors.Select(e => e.Description) });

            await _signInManager.SignInAsync(user, false);
            return Ok(new { Message = "External login removed." });
        }

        /// <summary>Links an external login provider (e.g., Google, Facebook).</summary>
        [HttpPost]
        public async Task<IActionResult> LinkExternalLogin(string provider)
        {
            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();
    
            var redirectUrl = Url.Action(nameof(LinkExternalLoginCallback), "Manage");
            var props = _signInManager.ConfigureExternalAuthenticationProperties(provider, redirectUrl, user.Id.ToString());
            return Challenge(props, provider);
        }

        /// <summary>Callback for linking an external login.</summary>
        [HttpGet]
        public async Task<IActionResult> LinkExternalLoginCallback()
        {
            var user = await GetCurrentUserAsync();
            if (user == null) return Unauthorized();

            var info = await _signInManager.GetExternalLoginInfoAsync(await _userManager.GetUserIdAsync(user));
            if (info == null) return BadRequest("Error loading external login info.");

            var result = await _userManager.AddLoginAsync(user, info);
            if (!result.Succeeded)
                return BadRequest(new { Errors = result.Errors.Select(e => e.Description) });

            return Ok(new { Message = "External login linked." });
        }
        */
        private async Task<ApplicationUser?> GetCurrentUserAsync()
        {
            // Get all NameIdentifier claims
            var nameIdentifierClaims = User.FindAll(ClaimTypes.NameIdentifier).ToList();
    
            _logger.LogInformation("Found {Count} NameIdentifier claims", nameIdentifierClaims.Count);
    
            // Try each NameIdentifier claim to find the one that's a valid ObjectId
            foreach (var claim in nameIdentifierClaims)
            {
                _logger.LogInformation("Trying NameIdentifier claim: {Value}", claim.Value);
        
                if (ObjectId.TryParse(claim.Value, out var objectId))
                {
                    _logger.LogInformation("Successfully parsed ObjectId: {ObjectId}", objectId);
                    var user = await _userManager.FindByIdAsync(objectId.ToString());
                    if (user != null)
                    {
                        _logger.LogInformation("User found: {UserName}", user.UserName);
                        return user;
                    }
                }
            }
    
            _logger.LogWarning("No valid ObjectId found in NameIdentifier claims");
            return null;
        }
    }
}
