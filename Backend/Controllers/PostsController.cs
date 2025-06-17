using Backend.Models;
using Backend.Services;
using Backend.Services.userPostService;
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

        public PostsController(
            PostServices postServices,
            CreatePost createService,
            EditPost editService,
            DeletePost deleteService)
        {
            _postServices = postServices;
            _createService = createService;
            _editService = editService;
            _deleteService = deleteService;
        }

        // GET: api/posts
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var posts = await _postServices.GetAsync();
            return Ok(posts);
        }

        // GET: api/posts/{id}
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            if (string.IsNullOrWhiteSpace(id))
                return BadRequest("Id cannot be null or empty.");

            var post = await _postServices.GetByIdAsync(id);
            if (post == null)
                return NotFound();

            return Ok(post);
        }

        // POST: api/posts
        [HttpPost]
        public async Task<IActionResult> Create(Post post)
        {
            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            await _createService.CreateAsync(post);

            // Return 201 Created with location header pointing to GetById
            return CreatedAtAction(nameof(GetById), new { id = post.Id }, post);
        }

        // PUT: api/posts/{id}
        [HttpPut("{id}")]
        public async Task<IActionResult> Update(string id, Post post)
        {
            if (id != post.Id)
                return BadRequest("Id in URL and body do not match.");

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var existingPost = await _postServices.GetByIdAsync(id);
            if (existingPost == null)
                return NotFound();

            await _editService.EditAsync(id, post);

            return NoContent(); // 204 No Content on successful update
        }

        // DELETE: api/posts/{id}
        [HttpDelete("{id}")]
        public async Task<IActionResult> Delete(string id)
        {
            if (string.IsNullOrWhiteSpace(id))
                return BadRequest("Id cannot be null or empty.");

            var post = await _postServices.GetByIdAsync(id);
            if (post == null)
                return NotFound();

            await _deleteService.DeleteAsync(id, post);

            return NoContent(); // 204 No Content on successful delete
        }
    }
}
