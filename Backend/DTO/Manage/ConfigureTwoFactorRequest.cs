using Microsoft.AspNetCore.Mvc.Rendering;

namespace Backend.DTO.Manage;

public class ConfigureTwoFactorRequest
{
    public string email { get; set; }
    public bool state { get; set; }
}