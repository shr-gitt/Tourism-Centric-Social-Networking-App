using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Manage;

public class SetPasswordRequest
{
    [Required]
    [DataType(DataType.Password)]
    public string NewPassword { get; set; }
    
    [DataType(DataType.Password)]
    [Compare("NewPassword")]
    public string ConfirmPassword { get; set; }
}