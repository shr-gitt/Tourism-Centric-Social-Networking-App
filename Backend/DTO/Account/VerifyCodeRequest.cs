using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Account;

public class VerifyCodeRequest
{
    [Required] public string Email { get; set; }
    [Required] public string Purpose { get; set; }
    [Required] public string Code { get; set; }
}