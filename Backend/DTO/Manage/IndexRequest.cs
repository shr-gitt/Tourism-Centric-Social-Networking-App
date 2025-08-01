using Microsoft.AspNetCore.Identity;

namespace Backend.DTO.Manage;

public class IndexRequest
{
    public bool HasPassword { get; set; }
    public IList<UserLoginInfo> Logins { get; set; }
    public string PhoneNumber { get; set; }
    public string TwoFactor { get; set; }
    public bool BrowserRemembered { get; set; }
    public string AuthenticatorKey { get; set; }
}