using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Manage;

public class AddPhoneNumberRequest
{
    [Required]
    [DataType(DataType.PhoneNumber)]
    public string PhoneNumber { get; set; }
}