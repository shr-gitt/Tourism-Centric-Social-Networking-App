using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    // [ApiController]
    // [Route("api/[controller]")]
    public class PostsController: Controller
    {
        private readonly PostServices _service;

        public PostsController(PostServices service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<IActionResult> Index()
        {
            var posts = await _service.GetAsync();
            return View(posts);
        }

        /*[HttpPost]
        public async Task<IActionResult> Post(Post post)
        {
            await _service.CreateAsync(post);
            return RedirectToAction(nameof(Index));
        }*/
        
        public IActionResult Create()
        {
            return View();
        }
        
        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> Create(Post post)
        {
            if (ModelState.IsValid)
            {
                await _service.CreateAsync(post);
                return RedirectToAction(nameof(Index));
            }
            return View(post);
        }
        
        public async Task<IActionResult> Edit(string id)
        {
            if (id == null)
            {
                return NotFound();
            }
        
            var post = await _service.GetByIdAsync(id);
            if (post == null)
            {
                return NotFound();
            }
        
            return View(post);
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
                await _service.UpdateAsync(id, post);
                return RedirectToAction(nameof(Index));
            }
        
            return View(post);
        }

        public async Task<IActionResult> Delete(string id)
        {
            if (id == null)
            {
                return NotFound();
            }
        
            var post = await _service.GetByIdAsync(id);
            if (post == null)
            {
                return NotFound();
            }
        
            return View(post);
        }

        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteConfirmed(string id)
        {
            await _service.DeleteAsync(id);
            return RedirectToAction(nameof(Index));
        }
    }
}
