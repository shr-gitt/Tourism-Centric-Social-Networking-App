using Backend.Models;
using Microsoft.AspNetCore.Mvc;
using Backend.Services;
using Backend.Services.userPostService;
using Backend.Services.userService;

namespace Backend.Controllers;
[ApiController]
[Route("api/users")]
public class UsersController:ControllerBase
{
    private readonly UserServices _userServices;
    private readonly DeleteUser _deleteService;
    private readonly EditUser _editService;
    private readonly SaveUser _saveService;

    public UsersController(UserServices userServices, DeleteUser deleteUser, EditUser editUser, SaveUser saveUser)
    {
        _userServices = userServices;
        _deleteService = deleteUser;
        _editService = editUser;
        _saveService = saveUser;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var users= await _userServices.GetAsync();
        return Ok(users);
    }
    // GET: api/users/{id}
    [HttpGet("{userid}")]
    public async Task<IActionResult> GetById(string userid)
    {
        if (string.IsNullOrWhiteSpace(userid))
            return BadRequest("Id cannot be null or empty.");

        var user = await _userServices.GetByIdAsync(userid);
        if (user == null)
            return NotFound();

        return Ok(user);
    }

    public class CreateuserRequest
    {
        public string? Title { get; set; }
        public string? Location { get; set; }
        public string? Content { get; set; }
        public List<IFormFile>? Images { get; set; }
    }
        
        // user: api/users
    /*[HttpPost("create")]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> Create([FromForm] CreateuserRequest request)
    {
        var imagePaths = new List<string>();

        foreach (var file in request.Images)
        {
            var imagePath = new UploadImage().Upload(file);
            imagePaths.Add(imagePath);
        }

        var user = new User
        {
            CreatedAt = DateTime.Now,
        };
        
        return CreatedAtAction(nameof(GetById), new { id = user.UserId }, user);
    }*/
        
    // PUT: api/users/{id}
    [HttpPost("update/{userid}")]
    public async Task<IActionResult> Update(string userid, [FromForm] CreateuserRequest request)
    {
        if (!ModelState.IsValid)
        {
            var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
            return BadRequest(new { Errors = errors });
        }
            
        var existinguser = await _userServices.GetByIdAsync(userid);
        if (existinguser == null)
            return NotFound();

        var imagePaths = new List<string>();

        if (request.Images != null)
        {
            foreach (var file in request.Images)
            {
                var imagePath = new UploadImage().Upload(file);
                imagePaths.Add(imagePath);
            }
        }

        var user = new User
        {
            CreatedAt = existinguser.CreatedAt
        };
            
        await _editService.EditAsync(user);
        return NoContent();
    }
        
    // DELETE: api/users/{id}
    [HttpDelete("{userid}")]
    public async Task<IActionResult> Delete(string userid)
    {
        if (string.IsNullOrWhiteSpace(userid))
            return BadRequest("Id cannot be null or empty.");

        var user = await _userServices.GetByIdAsync(userid);
        if (user == null)
            return NotFound();

        await _deleteService.DeleteAsync(userid);

        return NoContent(); // 204 No Content on successful delete
    }
        
    [HttpPost("save")]
    public async Task<IActionResult> SaveData([FromBody] User input)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        await _saveService.SaveAsync(input);
        return Ok();
    }
}