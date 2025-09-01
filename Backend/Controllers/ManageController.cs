using MongoDB.Bson;
using Backend.Models;
using Backend.DTO.Manage;
using Backend.Services.userAccount;
using System.Security.Claims;
using Backend.DTO;
using Backend.Services;
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
        private readonly CustomUserManager _customUserManager;
        private readonly SignInManager<ApplicationUser> _signInManager;
        private readonly IEmailSender _emailSender;
        private readonly ILogger<ManageController> _logger;

        public ManageController(
            UserManager<ApplicationUser> userManager,
            CustomUserManager customUserManager,
            SignInManager<ApplicationUser> signInManager,
            IEmailSender emailSender,
            ILogger<ManageController> logger)
        {
            _userManager = userManager;
            _customUserManager = customUserManager;
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
            _logger.LogInformation("User found in Index of ManageController");

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
        
        /// <summary>
        /// Request verify email link via email.
        /// </summary>
        [HttpPost]
        [AllowAnonymous]
        [ProducesResponseType(typeof(ApiResponse<string>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        public async Task<IActionResult> RequestVerifyEmail(RequestVerifyEmailRequest model)
        {
            if (!ModelState.IsValid)
                return BadRequest(new ApiResponse<object> { Success = false, Message = "Invalid data", Data = ModelState });

            _logger.LogInformation("Verify Email request: {Email}",  model.Email);
            var user = await _userManager.FindByEmailAsync(model.Email.ToLowerInvariant());
            _logger.LogInformation("VerifyEmail user email: {Email}", user.Email);
            if (user == null)// || !(await _userManager.IsEmailConfirmedAsync(user)))
            {
                // Always return success to avoid email enumeration
                return Ok(new ApiResponse<string> { Success = true, Message = "If this email exists, a reset link has been sent." });
            }

            //var code = GenerateSixDigitCode();
            var code = await _customUserManager.GenerateEmailConfirmationTokenAsync(user);

            // Provide the reset link so frontend app can handle it
            try
            {
                await _emailSender.SendEmailAsync(
                    user.Name,
                    user.Email, 
                    "Verify Email",
                    $"Your password reset code is:<br><strong>{code}</strong><br>" +
                    $"This code is valid for 5 minutes from {DateTime.Now} Utc. Copy this code into the app to reset your password.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send verify email mail to {Email}", user.Email);
                return StatusCode(500, new ApiResponse<object> { Success = false, Message = "Failed to send email." });
            }
        
            return Ok(new ApiResponse<string> { Success = true, Message = "Verify email sent." });
        }

        /// <summary>
        /// Verify email via email.
        /// </summary>
        [HttpPost]
        [AllowAnonymous]
        [ProducesResponseType(typeof(ApiResponse<string>), 200)]
        [ProducesResponseType(typeof(ApiResponse<object>), 400)]
        public async Task<IActionResult> VerifyEmail(VerifyEmailRequest model)
        {
            if (!ModelState.IsValid)
                return BadRequest(new ApiResponse<object> { Success = false, Message = "Invalid data", Data = ModelState });

            _logger.LogInformation("Verify Email request: {Email}",  model.Email);
            var user = await _userManager.FindByEmailAsync(model.Email.ToLowerInvariant());
            _logger.LogInformation("VerifyEmail user email: {Email}", user.Email);
            if (user == null)// || !(await _userManager.IsEmailConfirmedAsync(user)))
            {
                // Always return success to avoid email enumeration
                return Ok(new ApiResponse<string> { Success = true, Message = "If this email exists, a reset link has been sent." });
            }

            //var code = GenerateSixDigitCode();
            var code = await _userManager.ConfirmEmailAsync(user,model.Code);

            // Provide the reset link so frontend app can handle it
            try
            {
                await _emailSender.SendEmailAsync(
                    user.Name,
                    user.Email,
                    "Email Verified",
                    $"Your email has been verified");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to verify email {Email}", user.Email);
                return StatusCode(500, new ApiResponse<object> { Success = false, Message = "Failed to verify email." });
            }
        
            return Ok(new ApiResponse<string> { Success = true, Message = "Email Verified." });
        }
        
        /*
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
        [HttpPost]
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
        public async Task<IActionResult> TwoFactor(ConfigureTwoFactorRequest model)
        {
            _logger.LogInformation("Inside Two-factor authentication enabled");
            if (!ModelState.IsValid)
                return BadRequest(new ApiResponse<object> { Success = false, Message = "Invalid data", Data = ModelState });

            _logger.LogInformation("Verify Email request: {Email}",  model.email);
            var user = await _userManager.FindByEmailAsync(model.email.ToLowerInvariant());
            if (user == null)// || !(await _userManager.IsEmailConfirmedAsync(user)))
            {
                // Always return success to avoid email enumeration
                return Ok(new ApiResponse<string> { Success = true, Message = "If this email exists, a reset link has been sent." });
            }
            await _userManager.SetTwoFactorEnabledAsync(user, model.state);
            await _signInManager.SignInAsync(user, false);
            _logger.LogInformation("User changed to 2FA.{value}",model.state);
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
