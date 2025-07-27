using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Backend.DTO;
using Backend.Models;
//using Backend.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.UI.Services;
using Microsoft.IdentityModel.Tokens;

namespace Backend.Controllers;

[ApiController]
[Route("api/[controller]/[action]")]
public class AccountController:ControllerBase
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;
    private readonly IEmailSender _emailSender;
    //private readonly ISmsSender _smsSender;
    private readonly ILogger _logger;
    private readonly IConfiguration _configuration;

    public AccountController(UserManager<ApplicationUser> userManager, 
        SignInManager<ApplicationUser> signInManager,
        IEmailSender emailSender, 
        //ISmsSender smsSender, 
        ILoggerFactory loggerFactory,
        IConfiguration configuration
        )
    {
        _userManager = userManager;
        _signInManager = signInManager;
        _emailSender = emailSender;
        //_smsSender = smsSender;
        _logger = loggerFactory.CreateLogger<AccountController>();
        _configuration=configuration;
    }
    
    private async Task<string> GenerateJwtToken(ApplicationUser user)
    {
        var userRoles = await _userManager.GetRolesAsync(user);
        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.UserName ?? ""),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new Claim("uid", user.Id.ToString())
        };

        foreach (var role in userRoles)
        {
            claims.Add(new Claim(ClaimTypes.Role, role));
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        // Parse LifespanMinutes from configuration
        if (!int.TryParse(_configuration["Jwt:LifespanMinutes"], out var lifespanMinutes))
        {
            lifespanMinutes = 30; // fallback default in case config is missing or invalid
        }
        
        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(lifespanMinutes),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private void AddErrors(IdentityResult result)
    {
        foreach (var error in result.Errors)
        {
            ModelState.AddModelError(string.Empty, error.Description);
        }
    }
    
    [HttpPost]
    [AllowAnonymous]
    //[ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginRequest model)
    {
        if(!ModelState.IsValid)
            return BadRequest(ModelState);
        
        var user = await _userManager.FindByEmailAsync(model.Email);
        if(user == null)
            return Unauthorized(new {Message = "Invalid email"});
        
        var passwordValid = await _userManager.CheckPasswordAsync(user, model.Password);
        if(!passwordValid)
            return Unauthorized(new {Message = "Invalid password"});
        
        if(await _userManager.IsLockedOutAsync(user))
            return Forbid("You are not allowed to log in.");

        await _userManager.AddToRoleAsync(user, "LoggedIn");
        var token = await GenerateJwtToken(user);
        
        _logger.LogInformation("User logged in.");

        return Ok(new
            {
                Token = token,
                Message = $"User {user.UserName} successfully logged in."
            }
        );
    }
    
    [HttpPost]
    [AllowAnonymous]
    public IActionResult UseAsGuest()
    {
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.Role, "Guest"),
            new Claim("uid", Guid.NewGuid().ToString())  // some guest UID or anonymous
        };

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);
        var token = new JwtSecurityToken(
            issuer: _configuration["Jwt:Issuer"],
            audience: _configuration["Jwt:Audience"],
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(30),
            signingCredentials: creds);

        var jwtToken = new JwtSecurityTokenHandler().WriteToken(token);

        return Ok(new { Token = jwtToken, Message = "Logged in as Guest" });
    }

    [HttpPost]
    [AllowAnonymous]
    public async Task<IActionResult> Register(RegisterRequest model)
    {
        if(!ModelState.IsValid)
            return BadRequest(ModelState);

        var user = new ApplicationUser {UserName = model.UserName, Email = model.Email};
        
        var result = await _userManager.CreateAsync(user, model.Password);
        if (result.Succeeded)
        {
            await _signInManager.SignInAsync(user, false);
            _logger.LogInformation("User created a new account with password.");
            return Ok(new {Message = "User created successfully"});
        }
        AddErrors(result);
        return BadRequest(ModelState);
    }
}