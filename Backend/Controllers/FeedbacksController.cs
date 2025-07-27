using Microsoft.AspNetCore.Mvc;
using Backend.Services;
using Backend.Models;
using Backend.Services.userPostFeedbacksService;
using Microsoft.AspNetCore.Authorization;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class FeedbacksController : ControllerBase
    {
        private readonly FeedbacksService _feedbacksService;
        private readonly CreateFeedback _createFeedback;
        private readonly EditFeedback _editFeedback;
        private readonly DeleteFeedback _deleteFeedback;
        private readonly SaveFeedback _saveFeedback;

        public FeedbacksController(FeedbacksService feedbacksService, CreateFeedback createFeedback, EditFeedback editFeedback, DeleteFeedback deleteFeedback, SaveFeedback saveFeedback)
        {
            _feedbacksService = feedbacksService;
            _createFeedback=createFeedback;
            _editFeedback=editFeedback;
            _deleteFeedback=deleteFeedback;
            _saveFeedback=saveFeedback;
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
        [Authorize(Roles = "LoggedIn")]
        public async Task<ActionResult> AddFeedback([FromBody] Feedback feedback)
        {
            if (string.IsNullOrWhiteSpace(feedback.PostId))
                return BadRequest("Post ID is required.");

            if (string.IsNullOrWhiteSpace(feedback.Comment) && feedback.Like == null)
                return BadRequest("Either comment or like/dislike must be provided.");

            var created = await _createFeedback.CreateAsync(feedback);
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

            await _editFeedback.Edit(feedback);

            return NoContent();
        }

        [HttpDelete("{feedbackid}")]
        public async Task<IActionResult> DeleteFeedback(string feedbackid)
        {
            var deleted = await _deleteFeedback.DeleteAsync(feedbackid);
            if (!deleted)
                return NotFound("Feedback not found.");
    
            return NoContent();
        }
        
        [HttpPost("save")]
        public async Task<IActionResult> SaveFeedback([FromBody] Feedback feedback)
        {
            if(!ModelState.IsValid)
                return BadRequest(ModelState);
            
            await _saveFeedback.SaveAsync(feedback);
            return CreatedAtAction(nameof(GetById), new { feedbackid = feedback.FeedbackId }, feedback);
        }
    }
}