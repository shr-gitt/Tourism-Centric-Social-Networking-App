namespace Backend.DTO.Account;

public class LoginResponse
{
    public bool Code { get; set; }
    public string Token { get; set; } = null!;
    public string RefreshToken { get; set; } = null!;
    public DateTime RefreshTokenExpiry { get; set; }
}
