using MailKit.Net.Smtp;
using MimeKit;

namespace Backend.Services.userAccount
{
    public class AuthMessageSender : IEmailSender
    {
        public async Task SendEmailAsync(string name, string email, string subject, string message)
        {
            var messageBody = new MimeMessage();
            
            messageBody.From.Add(
                new MailboxAddress(
                    "Tourism Centric Social Networking App (no - reply)","tourismcentricsocialnetworking@gmail.com"
                    )
                );
            
            messageBody.To.Add(new MailboxAddress(name,email));
            messageBody.Subject = subject;
            messageBody.Body = new TextPart("html")
            {
                Text = message
            };
            
            using var client = new SmtpClient();
            await client.ConnectAsync("smtp.gmail.com", 587,MailKit.Security.SecureSocketOptions.StartTls);
            await client.AuthenticateAsync("tourismcentricsocialnetworking@gmail.com", "hsqu iaip dskr nijd");
            await client.SendAsync(messageBody);
            await client.DisconnectAsync(true);
            //return Task.CompletedTask;
        }
    }
}