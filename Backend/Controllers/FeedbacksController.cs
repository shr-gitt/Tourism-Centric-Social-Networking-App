using Microsoft.AspNetCore.Mvc;
using Backend.Services;
using Backend.Models;
using Microsoft.AspNetCore.Authorization;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]/[action]")]
    public class FeedbacksController : ControllerBase
    {
        private readonly FeedbacksService _feedbacksService;

        public FeedbacksController(FeedbacksService feedbacksService)
        {
            _feedbacksService = feedbacksService;
        }

        [HttpGet]
        public async Task<ActionResult> GetAll()
        {
            try
            {
                var interactions = await _feedbacksService.GetAsync();
                return Ok(interactions);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred while retrieving feedbacks: {ex.Message}");
            }
        }

        [HttpGet("{feedbackid}")]
        public async Task<IActionResult> GetById(string feedbackid)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(feedbackid))
                    return BadRequest("Id cannot be null or empty.");

                var post = await _feedbacksService.GetByIdAsync(feedbackid);
                if (post == null)
                    return NotFound();

                return Ok(post);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred while retrieving the feedback: {ex.Message}");
            }
        }

        [HttpGet("post/{postId}")]
        public async Task<IActionResult> GetByPostId(string postId)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(postId))
                    return BadRequest("Post ID is required.");

                var feedbacks = await _feedbacksService.GetByPostIdAsync(postId);
                return Ok(feedbacks);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred while retrieving feedbacks for the post: {ex.Message}");
            }
        }

        public class AddFeedbackRequest
        {
            public string UserId { get; set; }
            public string PostId { get; set; }
            public bool? Like { get; set; }
            public string? Comment { get; set; }
        }

        [HttpPost]
        [Authorize(Roles = "LoggedIn")]
        public async Task<ActionResult> AddFeedback([FromBody] AddFeedbackRequest request)
        {
            try
            {
                if (string.IsNullOrWhiteSpace(request.PostId))
                    return BadRequest("Post ID is required.");

                if (string.IsNullOrWhiteSpace(request.Comment) && request.Like == null)
                    return BadRequest("Either comment or like/dislike must be provided.");

                var feedback = new Feedback
                {
                    Username = request.UserId,
                    PostId = request.PostId,
                    Like = request.Like,
                    Comment = request.Comment
                };

                var created = await _feedbacksService.CreateAsync(feedback);
                if (!created)
                    return BadRequest("Post not found. Feedback cannot be added.");

                return CreatedAtAction(nameof(GetById), new { feedbackid = feedback.FeedbackId }, request);
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred while adding feedback: {ex.Message}");
            }
        }

        public class UpdateFeedbackRequest
        {
            public bool? Like { get; set; }
            public string? Comment { get; set; }
        }

        [HttpPatch("{feedbackid}")]
        public async Task<IActionResult> UpdateFeedback(string feedbackid, [FromBody] UpdateFeedbackRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
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
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred while updating feedback: {ex.Message}");
            }
        }

        [HttpDelete("{feedbackid}")]
        public async Task<IActionResult> DeleteFeedback(string feedbackid)
        {
            try
            {
                var deleted = await _feedbacksService.DeleteAsync(feedbackid);
                if (!deleted)
                    return NotFound("Feedback not found.");

                return NoContent();
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"An error occurred while deleting feedback: {ex.Message}");
            }
        }
    }
}
