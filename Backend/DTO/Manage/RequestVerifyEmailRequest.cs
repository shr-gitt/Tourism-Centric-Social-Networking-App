using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Manage;

public class RequestVerifyEmailRequest
{
    [Required] public string Email { get; set; }
}