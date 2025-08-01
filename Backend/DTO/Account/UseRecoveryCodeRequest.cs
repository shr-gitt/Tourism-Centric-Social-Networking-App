using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Account;

public class UseRecoveryCodeRequest
{
    [Required]
    public string Code { get; set; }
    public string ReturnUrl { get; set; }
}