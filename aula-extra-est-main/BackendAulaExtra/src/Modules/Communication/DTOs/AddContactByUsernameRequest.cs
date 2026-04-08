namespace ConfidantPostgreSQL.Modules.Communication.DTOs
{
    public class AddContactByUsernameRequest
    {
        public string Username { get; set; } = string.Empty;
    }

    public class AddContactByUserIdRequest
    {
        public Guid UserId { get; set; }
    }
}
