using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Backend.Models;
using Swashbuckle.AspNetCore.Annotations;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HomeController : ControllerBase
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        /// <summary>
        /// Get API status message.
        /// </summary>
        [HttpGet("status")]
        [SwaggerOperation(Summary = "Get API status", Description = "Returns a message indicating the API is running.")]
        [SwaggerResponse(200, "API status returned successfully")]
        public IActionResult Status()
        {
            return Ok(new { message = "API is running", timestamp = System.DateTime.UtcNow });
        }

        /// <summary>
        /// Get privacy info.
        /// </summary>
        [HttpGet("privacy")]
        [SwaggerOperation(Summary = "Get privacy information")]
        [SwaggerResponse(200, "Privacy info returned")]
        public IActionResult Privacy()
        {
            // Example response, replace with actual data if needed
            return Ok(new { privacy = "This is the privacy information." });
        }

        /// <summary>
        /// Get posts placeholder.
        /// </summary>
        [HttpGet("posts")]
        [SwaggerOperation(Summary = "Get posts placeholder")]
        [SwaggerResponse(200, "Posts returned successfully")]
        public IActionResult Posts()
        {
            // Return dummy posts or integrate with your service
            return Ok(new[] { new { id = 1, title = "Post 1" }, new { id = 2, title = "Post 2" } });
        }

        /// <summary>
        /// Get error details.
        /// </summary>
        [HttpGet("error")]
        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        [SwaggerOperation(Summary = "Get error details")]
        [SwaggerResponse(200, "Error details returned")]
        public IActionResult Error()
        {
            return Ok(new ErrorViewModel
            {
                RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier
            });
        }
    }
}
