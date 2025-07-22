using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using Backend.Models;
using Backend.Services;
using Backend.Services.userPostService;

namespace Backend.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController : ControllerBase
{
    private readonly AuthServices _authServices;

    public AuthController(AuthServices authServices)
    {
        _authServices = authServices;
    }

    public class RegisterRequest
    {
        [Required]
        public string UserName { get; set; }  
        [Required]
        public string Name { get; set; }
        [Required, EmailAddress]
        public string Email { get; set; }
        [Required, MinLength(6)]
        public string Password { get; set; }
        public IFormFile Image { get; set; }
    }
    
    public class LoginRequest
    {
        [Required, EmailAddress]
        public string Email { get; set; }
        public string Password { get; set; }
    }

    [HttpPost("register")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> Register([FromForm] RegisterRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        string imagePath=null;
        if (request.Image != null)
        {
            imagePath=new UploadImage().Upload(request.Image);
        }
        
        var user = new User
        {
            Email = request.Email,
            Password = request.Password,
            UserName = request.UserName,
            Name = request.Name,
            Image=imagePath,
            CreatedAt = DateTime.UtcNow
        };

        var result = await _authServices.RegisterAsync(user);

        if (!result.Success)
            return Conflict(new { result.ErrorMessage });

        return NoContent();  
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        var user = new User
        {
            Email = request.Email,
            Password = request.Password,
        };

        var result = await _authServices.LoginAsync(user);

        if (!result.Success)
            return Unauthorized(new { result.ErrorMessage });

        return Ok(new { UserId = result.current_uid });
    }
}