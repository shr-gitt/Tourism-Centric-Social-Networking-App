namespace Backend.Services.userAccount
{
    public interface IEmailSender
    {
        Task SendEmailAsync(string email, string subject, string message);
    }
}