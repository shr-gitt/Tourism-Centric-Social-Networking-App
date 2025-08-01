using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Manage;

public class DisplayRecoveryCodesRequest
{
    [Required]
    public IEnumerable<string> Codes { get; set; }
}