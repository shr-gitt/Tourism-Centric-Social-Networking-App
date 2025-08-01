namespace Backend.Services.userAccount
{
    public interface ISmsSender
    {
        Task  SendSmsAsync(string number, string message);
    }
}