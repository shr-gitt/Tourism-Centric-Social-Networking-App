namespace Backend.Services.userAccount
{
    public class AuthMessageSender : IEmailSender, ISmsSender
    {
        public Task SendEmailAsync(string email, string subject, string message)
        {
            return Task.FromResult(0);
        }

        public Task SendSmsAsync(string number, string message)
        {
            return Task.FromResult(0);
        }
    }
}