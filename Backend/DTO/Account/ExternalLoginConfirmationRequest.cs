using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Account
{
    public class ExternalLoginConfirmationRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }
    }
}