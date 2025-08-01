using Microsoft.AspNetCore.Mvc.Rendering;

namespace Backend.DTO.Account
{
    public class SendCodeRequest
    {
        public string SelectedProvider { get; set; }
        public ICollection<SelectListItem> Providers { get; set; }
        public string ReturnUrl { get; set; }
        public bool RememberMe { get; set; }
    }
}