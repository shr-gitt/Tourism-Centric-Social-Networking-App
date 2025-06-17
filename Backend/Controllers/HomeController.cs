using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Backend.Models;

namespace Backend.Controllers{
    [ApiController]
    [Route("[controller]/[action]")]
    public class HomeController : ControllerBase
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }
        [HttpGet]
        public IActionResult Index()
        {
            return Ok();
        }
        [HttpGet]
        public IActionResult Privacy()
        {
            return Ok();
        }
        [HttpGet]
        public IActionResult Posts()
        {
            return Ok();
        }

        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        [HttpGet]
        public IActionResult Error()
        {
            return Ok(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}