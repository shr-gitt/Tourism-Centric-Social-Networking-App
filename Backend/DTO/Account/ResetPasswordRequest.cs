using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Account
{
    public class ResetPasswordRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; }
        
        [Required]
        [DataType(DataType.Password)]
        public string Password { get; set; }
        
        public string Code { get; set; }
    }
}