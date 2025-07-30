using Backend.Models;
using Backend.Services;
using Backend.Services.userPostService;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PostsController : ControllerBase
    {
        private readonly PostServices _postServices;
        private readonly CreatePost _createService;
        private readonly EditPost _editService;
        private readonly DeletePost _deleteService;
        private readonly SavePost _saveService;

        public PostsController(
            PostServices postServices,
            CreatePost createService,
            EditPost editService,
            DeletePost deleteService,
            SavePost saveService)
        {
            _postServices = postServices;
            _createService = createService;
            _editService = editService;
            _deleteService = deleteService;
            _saveService = saveService;
        }

        // GET: api/posts
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var posts = await _postServices.GetAsync();
            return Ok(posts);
        }

        // GET: api/posts/{id}
        [HttpGet("{postid}")]
        public async Task<IActionResult> GetById(string postid)
        {
            if (string.IsNullOrWhiteSpace(postid))
                return BadRequest("Id cannot be null or empty.");

            var post = await _postServices.GetByIdAsync(postid);
            if (post == null)
                return NotFound();

            return Ok(post);
        }

        public class CreatePostRequest
        {
            public string? UserId { get; set; }
            public string? Title { get; set; }
            public string? Location { get; set; }
            public string? Content { get; set; }
            public List<IFormFile>? Images { get; set; }
        }
        
        // POST: api/posts
        [HttpPost("create")]
        [Consumes("multipart/form-data")]
        //[Authorize (Roles = "LoggedIn")]
        public async Task<IActionResult> Create([FromForm] CreatePostRequest request)
        {
            var imagePaths = new List<string>();
            if (request.Images != null)
            {
                foreach (var file in request.Images)
                {
                    var imagePath = new UploadImage().Upload(file);
                    imagePaths.Add(imagePath);
                }
            }

            var post = new Post
            {
                UserId = request.UserId,
                Title = request.Title,
                Location = request.Location,
                Content = request.Content,
                Created = DateTime.Now,
                Image = imagePaths
            };
            
            if (string.IsNullOrEmpty(post.Location))
            {
                post.Location = "Nepal";
            }

            await _createService.CreateAsync(post);

            return CreatedAtAction(nameof(GetById), new { postid = post.PostId }, post);
        }
        
        // PUT: api/posts/{id}
        [HttpPost("edit/{postid}")]
        public async Task<IActionResult> Edit(string postid, [FromForm] CreatePostRequest request)
        {
            if (!ModelState.IsValid)
            {
                var errors = ModelState.Values.SelectMany(v => v.Errors).Select(e => e.ErrorMessage);
                return BadRequest(new { Errors = errors });
            }
            
            var existingPost = await _postServices.GetByIdAsync(postid);
            if (existingPost == null)
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

            var post = new Post
            {
                PostId = postid,
                UserId = request.UserId,
                Title = request.Title,
                Location = request.Location,
                Content = request.Content,
                Image = imagePaths,
                Created = existingPost.Created
            };
            
            await _editService.EditAsync(postid, post);
            return NoContent();
        }
        
        // DELETE: api/posts/{id}
        [HttpDelete("{postid}")]
        public async Task<IActionResult> Delete(string postid)
        {
            if (string.IsNullOrWhiteSpace(postid))
                return BadRequest("Id cannot be null or empty.");

            var post = await _postServices.GetByIdAsync(postid);
            if (post == null)
                return NotFound();

            await _deleteService.DeleteAsync(postid, post);

            return NoContent(); // 204 No Content on successful delete
        }
        
        [HttpPost("save")]
        public async Task<IActionResult> SaveData([FromBody] Post input)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            await _saveService.SaveInputAsync(input);
            return Ok();
        }
    }
}
