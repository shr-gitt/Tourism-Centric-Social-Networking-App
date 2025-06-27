using Microsoft.AspNetCore.Mvc;
using Backend.Services;
using Backend.Models;
using Backend.Services.userPostFeedbacksService;

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
        
        [HttpGet("{id}")]
        public async Task<IActionResult> GetById(string id)
        {
            if (string.IsNullOrWhiteSpace(id))
                return BadRequest("Id cannot be null or empty.");

            var post = await _feedbacksService.GetByIdAsync(id);
            if (post == null)
                return NotFound();

            return Ok(post);
        }
        
        [HttpPost]
        public async Task<ActionResult> AddFeedback([FromBody] Feedback feedback)
        {
            if (string.IsNullOrWhiteSpace(feedback.PostId))
                return BadRequest("Post ID is required.");

            if (string.IsNullOrWhiteSpace(feedback.Comment) && feedback.Like == null)
                return BadRequest("Either comment or like/dislike must be provided.");

            var created = await _createFeedback.CreateAsync(feedback);
            if (!created)
                return BadRequest("Post not found. Feedback cannot be added.");

            return CreatedAtAction(nameof(GetById), new { id = feedback.Id }, feedback);
        }

        
        [HttpGet("post/{postId}")]
        public async Task<IActionResult> GetByPostId(string postId)
        {
            if (string.IsNullOrWhiteSpace(postId))
                return BadRequest("Post ID is required.");
    
            var feedbacks = await _feedbacksService.GetByPostIdAsync(postId);
            return Ok(feedbacks);
        }
        
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteFeedback(string id)
        {
            var deleted = await _deleteFeedback.DeleteAsync(id);
            if (!deleted)
                return NotFound("Feedback not found.");
    
            return NoContent();
        }

        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateFeedback(string id, [FromBody] Feedback feedback)
        {
            if(id!=feedback.Id)
                return BadRequest("Feedback IDs do not match.");
            
            if(!ModelState.IsValid)
                return BadRequest(ModelState);
            
            var existingFeedback = await _feedbacksService.GetByIdAsync(id);
            
            if(existingFeedback == null)
                return NotFound();
            
            await _editFeedback.Edit(feedback);
            
            return NoContent();
        }

        [HttpPost("save")]
        public async Task<IActionResult> SaveFeedback([FromBody] Feedback feedback)
        {
            if(!ModelState.IsValid)
                return BadRequest(ModelState);
            
            await _saveFeedback.SaveAsync(feedback);
            return CreatedAtAction(nameof(GetById), new { id = feedback.Id }, feedback);
        }
    }
}