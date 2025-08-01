namespace Backend.DTO.Manage;

public class RemoveLoginRequest
{
    public string LoginProvider { get; set; }
    public string ProviderKey { get; set; }
}