using Backend.Models;
using Backend.Services;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReportController: ControllerBase
    {
        private readonly ReportServices _reportServices;
        
        public ReportController(
            ReportServices reportServices
        )
        {
            _reportServices = reportServices;
        }

        // GET: api/posts
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var posts = await _reportServices.GetAsync();
            return Ok(posts);
        }

        // GET: api/posts/{id}
        [HttpGet("{reportId}")]
        public async Task<IActionResult> GetById(string reportId)
        {
            if (string.IsNullOrWhiteSpace(reportId))
                return BadRequest("Id cannot be null or empty.");

            var post = await _reportServices.GetByIdAsync(reportId);
            if (post == null)
                return NotFound();

            return Ok(post);
        }
        
        [HttpPost]
        public async Task<ActionResult> CreateReport([FromBody] Report report)
        {
            if (string.IsNullOrWhiteSpace(report.PostId))
                return BadRequest("Post ID is required.");
            
            var created = await _reportServices.CreateAsync(report);
            if (!created)
                return BadRequest("Post not found. Report cannot be added.");

            return CreatedAtAction(nameof(GetById), new { reportid = report.ReportId }, report);
        }
        
        [HttpDelete("{reportId}")]
        public async Task<IActionResult> DeleteReport(string reportId, Report report)
        {
            var deleted = await _reportServices.DeleteAsync(reportId, report);
            if (!deleted)
                return NotFound("Report not found.");
    
            return NoContent();
        }
    }
}