using Microsoft.AspNetCore.Mvc.Rendering;

namespace Backend.DTO.Manage;

public class ConfigureTwoFactorRequest
{
    public string SelectedProvider { get; set; }
    public ICollection<SelectListItem> Providers { get; set; }
}