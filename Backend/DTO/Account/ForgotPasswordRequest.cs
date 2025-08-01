using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Account
{
    public class ForgotPasswordRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }
    }
}