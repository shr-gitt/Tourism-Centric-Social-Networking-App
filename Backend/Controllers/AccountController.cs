using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Backend.DTO;
using Backend.Models;
using Backend.Services;
using Backend.Services.userPostService;
using Microsoft.AspNetCore.Identity;
using Microsoft.IdentityModel.Tokens;
using MongoDB.Bson;

namespace Backend.Controllers;

[ApiController]
[Route("api/[controller]/[action]")]
public class AccountController:ControllerBase
{
    private readonly AccountServices _accountServices;
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;
    //private readonly IEmailSender _emailSender;
    //private readonly ISmsSender _smsSender;
    private readonly ILogger _logger;
    private readonly IConfiguration _configuration;
    private readonly RoleManager<ApplicationRole> _roleManager;

    public AccountController(
        AccountServices accountServices,
        UserManager<ApplicationUser> userManager, 
        SignInManager<ApplicationUser> signInManager,
        //IEmailSender emailSender, 
        //ISmsSender smsSender, 
        ILoggerFactory loggerFactory,
        IConfiguration configuration,
        RoleManager<ApplicationRole> roleManager
        )
    {
        _accountServices = accountServices;
        _userManager = userManager;
        _signInManager = signInManager;
        //_emailSender = emailSender;
        //_smsSender = smsSender;
        _logger = loggerFactory.CreateLogger<AccountController>();
        _configuration=configuration;
        _roleManager = roleManager;
    }
    
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var users= await _accountServices.GetAsync();
        return Ok(users);
    }
    
    // GET: api/users/{id}
    [HttpGet("{userid}")]
    public async Task<IActionResult> GetById(string userid)
    {
        if (string.IsNullOrWhiteSpace(userid))
            return BadRequest("Id cannot be null or empty.");

        var user = await _accountServices.GetByIdAsync(userid);
        if (user == null)
            return NotFound();

        return Ok(user);
    }
    
    [HttpGet("{username}")]
    public async Task<ApplicationUser> GetByUsernameAsync(string username)
    {
        var user = await _userManager.FindByNameAsync(username);
        /*if (user == null)
            return NotFound();*/
        return user;
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
        await EnsureRolesExist(); // Ensure the LoggedIn role exists

        var roles = await _userManager.GetRolesAsync(user);
        if (!roles.Contains(ApplicationRole.RoleNames.LoggedIn))
        {
            await _userManager.AddToRoleAsync(user, ApplicationRole.RoleNames.LoggedIn);
        }

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
            new Claim(ClaimTypes.NameIdentifier, ObjectId.GenerateNewId().ToString()),
            new Claim(ClaimTypes.Role, "Guest")                      
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
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> Register(RegisterRequest model)
    {
        if(!ModelState.IsValid)
            return BadRequest(ModelState);
        
        string imagePath=null;
        if (model.Image != null)
        {
            imagePath=new UploadImage().Upload(model.Image);
        }

        var user = new ApplicationUser {UserName = model.UserName,Name= model.Name,PhoneNumber = model.Phone, Email = model.Email, Image = imagePath??""};
        
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
    
    private async Task EnsureRolesExist()
    {
        if (!await _roleManager.RoleExistsAsync(ApplicationRole.RoleNames.LoggedIn))
        {
            var role = new ApplicationRole { Name = ApplicationRole.RoleNames.LoggedIn };
            await _roleManager.CreateAsync(role);
        }
    }

    private async Task<string> GenerateJwtToken(ApplicationUser user)
    {
        var userRoles = await _userManager.GetRolesAsync(user);
        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.UserName ?? ""),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            //new Claim(ClaimTypes.NameIdentifier, user.Id.ToString())
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
}