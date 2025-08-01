using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Manage;

public class ChangePasswordRequest
{
    [Required]
    [DataType(DataType.Password)]
    public string OldPassword { get; set; }
    [Required]
    [DataType(DataType.Password)]
    public string NewPassword { get; set; }
    [Required]
    [DataType(DataType.Password)]
    [Compare("NewPassword", ErrorMessage = "The password and confirmation password do not match.")]
    public string ConfirmPassword { get; set; }
}