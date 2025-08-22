using Microsoft.AspNetCore.Mvc;
using Backend.Services;
using Backend.Models;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]

    public class FeedbacksController : ControllerBase
    {
        private readonly FeedbacksService _feedbacksService;

        public FeedbacksController(FeedbacksService feedbacksService)
        {
            _feedbacksService = feedbacksService;
        }
        
        [HttpGet]
        public async Task<ActionResult> GetAll(){
            var interactions = await _feedbacksService.GetAsync();
            return Ok(interactions);
        }
        
        [HttpGet("{feedbackid}")]
        public async Task<IActionResult> GetById(string feedbackid)
        {
            if (string.IsNullOrWhiteSpace(feedbackid))
                return BadRequest("Id cannot be null or empty.");

            var post = await _feedbacksService.GetByIdAsync(feedbackid);
            if (post == null)
                return NotFound();

            return Ok(post);
        }
        
        [HttpGet("post/{postId}")]
        public async Task<IActionResult> GetByPostId(string postId)
        {
            if (string.IsNullOrWhiteSpace(postId))
                return BadRequest("Post ID is required.");
    
            var feedbacks = await _feedbacksService.GetByPostIdAsync(postId);
            return Ok(feedbacks);
        }
        
        [HttpPost]
        public async Task<ActionResult> AddFeedback([FromBody] Feedback feedback)
        {
            if (string.IsNullOrWhiteSpace(feedback.PostId))
                return BadRequest("Post ID is required.");

            if (string.IsNullOrWhiteSpace(feedback.Comment) && feedback.Like == null)
                return BadRequest("Either comment or like/dislike must be provided.");

            var created = await _feedbacksService.CreateAsync(feedback);
            if (!created)
                return BadRequest("Post not found. Feedback cannot be added.");

            return CreatedAtAction(nameof(GetById), new { feedbackid = feedback.FeedbackId }, feedback);
        }

        public class UpdateFeedbackRequest
        {
            public bool? Like { get; set; }
            public string? Comment { get; set; }
        }
        
        [HttpPatch("{feedbackid}")]
        public async Task<IActionResult> UpdateFeedback(string feedbackid, [FromBody] UpdateFeedbackRequest request)
        {
            if(!ModelState.IsValid)
                return BadRequest(ModelState);
            
            var feedback = await _feedbacksService.GetByIdAsync(feedbackid);
            if (feedback == null)
                return NotFound();

            if (request.Like != null)
                feedback.Like = request.Like;

            if (!string.IsNullOrEmpty(request.Comment))
                feedback.Comment = request.Comment;

            await _feedbacksService.Edit(feedback);

            return NoContent();
        }

        [HttpDelete("{feedbackid}")]
        public async Task<IActionResult> DeleteFeedback(string feedbackid)
        {
            var deleted = await _feedbacksService.DeleteAsync(feedbackid);
            if (!deleted)
                return NotFound("Feedback not found.");
    
            return NoContent();
        }
        
        [HttpPost("save")]
        public async Task<IActionResult> SaveFeedback([FromBody] Feedback feedback)
        {
            if(!ModelState.IsValid)
                return BadRequest(ModelState);
            
            await _feedbacksService.SaveAsync(feedback);
            return CreatedAtAction(nameof(GetById), new { feedbackid = feedback.FeedbackId }, feedback);
        }
    }
}