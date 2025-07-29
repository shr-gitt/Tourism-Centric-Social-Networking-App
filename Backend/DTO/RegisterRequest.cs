using System.ComponentModel.DataAnnotations;

namespace Backend.DTO;


public class RegisterRequest
{
    [Required]
    public string UserName { get; set; }=string.Empty;
    
    [Required]
    public string Name { get; set; }=string.Empty;
    
    [Required]
    [Phone]
    public string Phone { get; set; }=string.Empty;
    
    [Required]
    [EmailAddress]
    public string Email { get; set; }=string.Empty;
    [Required]
    [DataType(DataType.Password)]
    [StringLength(15, MinimumLength = 6)]
    public string Password { get; set; }=string.Empty;
    
    [Required]
    [DataType(DataType.Password)]
    [Compare("Password")]
    public string ConfirmPassword { get; set; }=string.Empty;
    
    public IFormFile? Image { get; set; }
}