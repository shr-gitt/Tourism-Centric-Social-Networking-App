using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PostsController: Controller
    {
        private readonly PostServices _service;

        public PostsController(PostServices service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<List<Post>> Get() => await _service.GetAsync();

        [HttpPost]
        public async Task<IActionResult> Post(Post post)
        {
            await _service.CreateAsync(post);
            return CreatedAtAction(nameof(Get), new { id = post.Id }, post);
        }
    }
}