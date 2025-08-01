namespace Backend.DTO.Account;

public class RefreshTokenRequest
{
    public string Token { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; } 
}