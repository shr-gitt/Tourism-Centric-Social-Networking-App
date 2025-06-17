using Backend.Models;
using Backend.Services;
using Backend.Services.userPostService;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PostsController: ControllerBase
    {
        private readonly PostServices _postServices;
        private readonly CreatePost _createservice;
        private readonly EditPost _editservice;
        private readonly DeletePost _deleteservice;

        public PostsController(PostServices service, CreatePost createservice, EditPost editservice, DeletePost deleteservice)
        {
            _postServices = service;
            _createservice = createservice;
            _editservice = editservice;
            _deleteservice = deleteservice;
        }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var posts = await _postServices.GetAsync();
            return Ok(posts);
        }

        [HttpPost]
        public async Task<IActionResult> Post(Post post)
        {
            await _postServices.GetAsync();
            return RedirectToAction(nameof(Index));
        }
        
        public IActionResult Create()
        {
            return Ok();
        }
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Post post)
        {
            if (ModelState.IsValid)
            {
                await _createservice.CreateAsync(post);
                return RedirectToAction(nameof(Index));
            }
            return Ok(post);
        }
        
        public async Task<IActionResult> Edit(string id)
        {
            if (id == null)
            {
                return NotFound();
            }
        
            var post = await _postServices.GetByIdAsync(id);
            if (post == null)
            {
                return NotFound();
            }
        
            return Ok(post);
        }
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Edit(string id, Post post)
        {
            if (id != post.Id)
            {
                return NotFound();
            }
        
            if (ModelState.IsValid)
            {
                await _editservice.EditAsync(id, post);
                return RedirectToAction(nameof(Index));
            }
        
            return Ok(post);
        }

        public async Task<IActionResult> Delete(string id)
        {
            if (id == null)
            {
                return NotFound();
            }
        
            var post = await _postServices.GetByIdAsync(id);
            if (post == null)
            {
                return NotFound();
            }
        
            return Ok(post);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string id, Post post)
        {
            await _deleteservice.DeleteAsync(id,post);
            return RedirectToAction(nameof(Index));
        }
    }
}
