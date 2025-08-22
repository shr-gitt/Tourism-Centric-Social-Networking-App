using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Account;

public class DeleteAccountRequest
{
    [Required]public string Email { get; set; } = null!;
    [Required]public string Password { get; set; } = null!;
}