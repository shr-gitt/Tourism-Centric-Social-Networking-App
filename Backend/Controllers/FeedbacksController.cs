using Microsoft.AspNetCore.Mvc;
using Backend.Services;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]

    public class FeedbacksController : ControllerBase
    {
        private readonly FeedbacksServices _feedbacksServices;

        public FeedbacksController(FeedbacksServices feedbacksServices)
        {
            _feedbacksServices = feedbacksServices;
        }
        
        [HttpGet]
        public async Task<ActionResult> GetAll(){
            var interactions = await _feedbacksServices.GetAsync();
            return Ok(interactions);
        }
    }
}