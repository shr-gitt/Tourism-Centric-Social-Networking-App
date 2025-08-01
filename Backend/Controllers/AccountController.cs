using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using Backend.Models;
using Backend.DTO.Account;
using Backend.Services.userAccount;
using Backend.Services.userPostService;

namespace Backend.Controllers;

/// <summary>
/// Handles user account operations like login, registration, external login, and 2FA.
/// </summary>
[ApiController]
[Route("api/[controller]/[action]")]
public class AccountController : ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;
    private readonly IEmailSender _emailSender;
    private readonly ISmsSender _smsSender;
    private readonly ILogger<AccountController> _logger;
    private readonly IConfiguration _configuration;
    private readonly RoleManager<ApplicationRole> _roleManager;
    private readonly UploadImage _uploadImage;

    public AccountController(
        UserManager<ApplicationUser> userManager,
        SignInManager<ApplicationUser> signInManager,
        IEmailSender emailSender,
        ISmsSender smsSender,
        ILogger<AccountController> logger,
        IConfiguration configuration,
        RoleManager<ApplicationRole> roleManager,
        UploadImage uploadImage)
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _emailSender = emailSender;
        _smsSender = smsSender;
        _logger = logger;
        _configuration = configuration;
        _roleManager = roleManager;
        _uploadImage = uploadImage;
    }

    /// <summary>
    /// User login with email and password, returns JWT + refresh token.
    /// </summary>
    [HttpPost]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<LoginResponse>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 401)]
    public async Task<IActionResult> Login(LoginRequest model)
    {
        if (!ModelState.IsValid)
            return BadRequest(new ApiResponse<object> { Success = false, Message = "Invalid data", Data = ModelState });

        // Rate limiting / CAPTCHA recommended here

        var user = await _userManager.FindByEmailAsync(model.Email.ToLowerInvariant());
        if (user == null || !await _userManager.CheckPasswordAsync(user, model.Password))
            return Unauthorized(new ApiResponse<object> { Success = false, Message = "Invalid email or password." });

        if (await _userManager.IsLockedOutAsync(user))
            return new ObjectResult(new ApiResponse<object> { Success = false, Message = "Your account is locked." })
            {
                StatusCode = StatusCodes.Status403Forbidden
            };

        await EnsureRolesExist();
        var roles = await _userManager.GetRolesAsync(user);
        if (!roles.Contains(ApplicationRole.RoleNames.LoggedIn))
            await _userManager.AddToRoleAsync(user, ApplicationRole.RoleNames.LoggedIn);

        var token = await GenerateJwtToken(user);
        var refreshToken = GenerateRefreshToken();

        await SaveRefreshToken(user, refreshToken);

        _logger.LogInformation("User {UserId} logged in.", user.Id);

        return Ok(new ApiResponse<LoginResponse>
        {
            Success = true,
            Message = $"User {user.UserName} logged in.",
            Data = new LoginResponse
            {
                Token = token,
                RefreshToken = refreshToken.Token,
                RefreshTokenExpiry = refreshToken.ExpiresAt
            }
        });
    }

    /// <summary>
    /// Register a new user. Returns JWT + refresh token.
    /// </summary>
    [HttpPost]
    [AllowAnonymous]
    [Consumes("multipart/form-data")]
    [ProducesResponseType(typeof(ApiResponse<string>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> Register([FromForm] RegisterRequest model)
    {
        if (!ModelState.IsValid)
            return BadRequest(new ApiResponse<object> { Success = false, Message = "Invalid data", Data = ModelState });

        string imagePath = "";
        try
        {
            if (model.Image != null)
                imagePath = _uploadImage.Upload(model.Image);
        }
        catch (Exception ex)
        {
            _logger.LogWarning("Image upload failed: {Error}", ex.Message);
            return BadRequest(new ApiResponse<object> { Success = false, Message = $"Image upload error: {ex.Message}" });
        }

        var user = new ApplicationUser
        {
            UserName = model.UserName.ToLowerInvariant(),
            Name = model.Name,
            PhoneNumber = model.Phone,
            Email = model.Email.ToLowerInvariant(),
            Image = imagePath
        };

        var result = await _userManager.CreateAsync(user, model.Password);
        if (!result.Succeeded)
            return IdentityErrorResponse(result);

        await EnsureRolesExist();
        await _userManager.AddToRoleAsync(user, ApplicationRole.RoleNames.LoggedIn);

        var token = await GenerateJwtToken(user);
        var refreshToken = GenerateRefreshToken();
        await SaveRefreshToken(user, refreshToken);

        _logger.LogInformation("User {UserId} registered.", user.Id);

        return Ok(new ApiResponse<LoginResponse>
        {
            Success = true,
            Message = "User registered successfully.",
            Data = new LoginResponse
            {
                Token = token,
                RefreshToken = refreshToken.Token,
                RefreshTokenExpiry = refreshToken.ExpiresAt
            }
        });
    }

    /// <summary>
    /// Logout the user by clearing cookies/session.
    /// </summary>
    [HttpPost]
    [Authorize]
    [ProducesResponseType(typeof(ApiResponse<string>), 200)]
    public async Task<IActionResult> Logout()
    {
        await _signInManager.SignOutAsync();
        _logger.LogInformation("User {UserId} logged out.", User.FindFirstValue(ClaimTypes.NameIdentifier));
        return Ok(new ApiResponse<string> { Success = true, Message = "User logged out." });
    }

    /// <summary>
    /// Initiate external login challenge.
    /// </summary>
    [HttpPost]
    [AllowAnonymous]
    [ProducesResponseType(401)]
    public IActionResult ExternalLogin(string provider, string returnUrl)
    {
        // Validate provider here if needed

        var redirectUrl = Url.Action(nameof(ExternalLoginCallback), "Account", new { ReturnUrl = returnUrl });
        var properties = _signInManager.ConfigureExternalAuthenticationProperties(provider, redirectUrl);

        return Challenge(properties, provider);
    }

    /// <summary>
    /// External login callback.
    /// </summary>
    [HttpGet]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<string>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    [ProducesResponseType(typeof(ApiResponse<object>), 401)]
    public async Task<IActionResult> ExternalLoginCallback(string returnUrl = null, string remoteError = null)
    {
        if (!string.IsNullOrEmpty(remoteError))
        {
            _logger.LogWarning("External login error: {Error}", remoteError);
            return BadRequest(new ApiResponse<object> { Success = false, Message = $"External provider error: {remoteError}" });
        }

        var info = await _signInManager.GetExternalLoginInfoAsync();
        if (info == null)
            return Unauthorized(new ApiResponse<object> { Success = false, Message = "Error loading external login info." });

        var signInResult = await _signInManager.ExternalLoginSignInAsync(info.LoginProvider, info.ProviderKey, false);

        if (signInResult.Succeeded)
        {
            await _signInManager.UpdateExternalAuthenticationTokensAsync(info);
            return Ok(new ApiResponse<string> { Success = true, Message = "External login successful." });
        }
        if (signInResult.IsLockedOut)
            return new ObjectResult(new ApiResponse<object> { Success = false, Message = "Your account is locked." })
            {
                StatusCode = StatusCodes.Status403Forbidden
            };
        if (signInResult.RequiresTwoFactor)
            return BadRequest(new ApiResponse<object> { Success = false, Message = "Two-factor authentication required." });

        var email = info.Principal.FindFirstValue(ClaimTypes.Email);
        return Ok(new ApiResponse<object>
        {
            Success = true,
            Message = "External login requires confirmation.",
            Data = new { Provider = info.LoginProvider, Email = email }
        });
    }

    /// <summary>
    /// External login confirmation endpoint to create a new local user.
    /// </summary>
    [HttpPost]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<string>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> ExternalLoginConfirmation(ExternalLoginConfirmationRequest model)
    {
        if (!ModelState.IsValid)
            return BadRequest(new ApiResponse<object> { Success = false, Message = "Invalid data", Data = ModelState });

        var info = await _signInManager.GetExternalLoginInfoAsync();
        if (info == null)
            return Unauthorized(new ApiResponse<object> { Success = false, Message = "External login info not found." });

        var user = new ApplicationUser
        {
            UserName = model.Email.ToLowerInvariant(),
            Email = model.Email.ToLowerInvariant()
        };

        var createResult = await _userManager.CreateAsync(user);
        if (!createResult.Succeeded)
            return IdentityErrorResponse(createResult);

        var loginResult = await _userManager.AddLoginAsync(user, info);
        if (!loginResult.Succeeded)
            return IdentityErrorResponse(loginResult);

        await _signInManager.SignInAsync(user, false);
        await _signInManager.UpdateExternalAuthenticationTokensAsync(info);

        return Ok(new ApiResponse<string> { Success = true, Message = "External account created and logged in." });
    }

    /// <summary>
    /// Request password reset link via email.
    /// </summary>
    [HttpPost]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<string>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest model)
    {
        if (!ModelState.IsValid)
            return BadRequest(new ApiResponse<object> { Success = false, Message = "Invalid data", Data = ModelState });

        var user = await _userManager.FindByEmailAsync(model.Email.ToLowerInvariant());
        if (user == null || !(await _userManager.IsEmailConfirmedAsync(user)))
        {
            // Always return success to avoid email enumeration
            return Ok(new ApiResponse<string> { Success = true, Message = "If this email exists, a reset link has been sent." });
        }

        var code = await _userManager.GeneratePasswordResetTokenAsync(user);

        // Provide the reset link so frontend app can handle it
        var frontendResetUrl = $"{_configuration["FrontendBaseUrl"]}/reset-password?code={Uri.EscapeDataString(code)}&email={Uri.EscapeDataString(user.Email)}";

        await _emailSender.SendEmailAsync(user.Email, "Reset Password",
            $"Please reset your password by clicking here: <a href='{frontendResetUrl}'>Reset Password</a>");

        return Ok(new ApiResponse<string> { Success = true, Message = "Reset email sent." });
    }

    /// <summary>
    /// Reset password using token.
    /// </summary>
    [HttpPost]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<string>), 200)]
    [ProducesResponseType(typeof(ApiResponse<object>), 400)]
    public async Task<IActionResult> ResetPassword(ResetPasswordRequest model)
    {
        if (!ModelState.IsValid)
            return BadRequest(new ApiResponse<object> { Success = false, Message = "Invalid data", Data = ModelState });

        var user = await _userManager.FindByEmailAsync(model.Email.ToLowerInvariant());
        if (user == null)
            return Ok(new ApiResponse<string> { Success = true, Message = "Password reset done." });

        var resetResult = await _userManager.ResetPasswordAsync(user, model.Code, model.Password);

        if (!resetResult.Succeeded)
            return IdentityErrorResponse(resetResult);

        return Ok(new ApiResponse<string> { Success = true, Message = "Password reset successful." });
    }

    /// <summary>
    /// Use as guest - create a temporary guest user and issue JWT.
    /// </summary>
    [HttpPost]
    [AllowAnonymous]
    [ProducesResponseType(typeof(ApiResponse<LoginResponse>), 200)]
    public async Task<IActionResult> UseAsGuest()
    {
        // Rate limiting recommended here

        var guestUser = new ApplicationUser
        {
            UserName = "guest-" + Guid.NewGuid(),
            EmailConfirmed = false,
            PhoneNumberConfirmed = false,
            LockoutEnabled = false,
            //IsGuest = true
        };

        var result = await _userManager.CreateAsync(guestUser);
        if (!result.Succeeded)
            return IdentityErrorResponse(result);

        await _userManager.AddToRoleAsync(guestUser, ApplicationRole.RoleNames.Guest);

        var token = await GenerateJwtToken(guestUser);
        var refreshToken = GenerateRefreshToken();
        await SaveRefreshToken(guestUser, refreshToken);

        _logger.LogInformation("Guest user {UserId} created.", guestUser.Id);

        return Ok(new ApiResponse<LoginResponse>
        {
            Success = true,
            Message = "Guest access granted.",
            Data = new LoginResponse
            {
                Token = token,
                RefreshToken = refreshToken.Token,
                RefreshTokenExpiry = refreshToken.ExpiresAt
            }
        });
    }

    #region Helpers

    private async Task EnsureRolesExist()
    {
        var roles = new[]
        {
            ApplicationRole.RoleNames.LoggedIn,
            ApplicationRole.RoleNames.Guest
        };

        foreach (var roleName in roles)
        {
            if (!await _roleManager.RoleExistsAsync(roleName))
            {
                var role = new ApplicationRole();
                role.Name = roleName;
                await _roleManager.CreateAsync(role);
            }
        }
    }

    private async Task<string> GenerateJwtToken(ApplicationUser user)
    {
        var jwtKey = _configuration["Jwt:Key"];
        var jwtIssuer = _configuration["Jwt:Issuer"];
        var jwtAudience = _configuration["Jwt:Audience"];

        if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < 32)
            throw new InvalidOperationException("JWT key is missing or too short in configuration.");

        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim(ClaimTypes.Name, user.UserName),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
        };

        var userRoles = await _userManager.GetRolesAsync(user);
        claims.AddRange(userRoles.Select(role => new Claim(ClaimTypes.Role, role)));

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: jwtIssuer,
            audience: jwtAudience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(30),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private RefreshToken GenerateRefreshToken()
    {
        return new RefreshToken
        {
            Token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(64)),
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(7)
        };
    }

    private async Task SaveRefreshToken(ApplicationUser user, RefreshToken refreshToken)
    {
        // Implement refresh token storage logic here
        // e.g. store in user claims, database, or dedicated refresh token store
        // This is app-specific and must be implemented for refresh token usage

        // Example:
        //user.RefreshTokens.Add(refreshToken);
        //await _userManager.UpdateAsync(user);

        await Task.CompletedTask;
    }

    private IActionResult IdentityErrorResponse(IdentityResult result)
    {
        var errors = result.Errors.Select(e => e.Description);
        return BadRequest(new ApiResponse<object> { Success = false, Message = "Identity errors", Data = errors });
    }
    
    public class RefreshToken
    {
        public string Token { get; set; } = null!;
        public DateTime CreatedAt { get; set; }
        public DateTime ExpiresAt { get; set; }
    }

    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; } = null!;
        public T Data { get; set; }
    }
    #endregion
}
