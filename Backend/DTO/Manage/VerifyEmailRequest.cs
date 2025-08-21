using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Manage;

public class VerifyEmailRequest
{
    [Required] public string Email { get; set; }
    [Required] public string Code { get; set; }
}