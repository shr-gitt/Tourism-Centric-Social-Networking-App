using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Account
{
    public class UpdateUserRequest
    {
        [Required]
        public string? UserName { get; set; }

        [Required]
        public string? Name { get; set; }

        [Required, Phone]
        public string? Phone { get; set; }

        [Required, EmailAddress]
        public string? Email { get; set; }

        public IFormFile? Image { get; set; }
    }
}