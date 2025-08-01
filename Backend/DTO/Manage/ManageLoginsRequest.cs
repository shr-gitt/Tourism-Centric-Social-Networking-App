using Microsoft.AspNetCore.Identity;

namespace Backend.DTO.Manage;

public class ManageLoginsRequest
{
    public IList<UserLoginInfo> CurrentLogins { get; set; }
    public IList<UserLoginInfo> OtherLogins { get; set; }
}