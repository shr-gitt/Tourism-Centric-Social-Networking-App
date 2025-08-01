using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Manage;

public class VerifyPhoneNumberRequest
{
    [Required]
    public string Code { get; set; }
    [Required]
    [DataType(DataType.PhoneNumber)]
    public string PhoneNumber { get; set; }
}