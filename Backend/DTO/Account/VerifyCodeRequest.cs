using System.ComponentModel.DataAnnotations;

namespace Backend.DTO.Account;

public class VerifyCodeRequest
{
    [Required]
    public string Provider { get; set; }
    [Required]
    public string Code { get; set; }
    public string ReturnUrl { get; set; }
    public bool RememberBrowser { get; set; }
    public bool RememberMe { get; set; }
}