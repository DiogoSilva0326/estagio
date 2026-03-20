using System;
using System.Linq;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Communication.Models;
using ConfidantPostgreSQL.Modules.Communication.Repository;
using Microsoft.AspNetCore.SignalR;

namespace ConfidantPostgreSQL.Modules.Communication.Hubs
{
    public class ChatHub : Hub
    {
        private readonly ICommunicationRepository _repo;

        public ChatHub(ICommunicationRepository repo)
        {
            _repo = repo;
        }

        public async Task JoinRoom(string channelName, string userId, string displayName)
        {
            try 
            {
                await Groups.AddToGroupAsync(Context.ConnectionId, channelName);

                var parts = channelName.Split('_');
                
                // Tenta converter os IDs de forma segura (sem rebentar se for "1" ou "ID_NAO_ENCONTRADO")
                if (parts.Length == 3 && 
                    Guid.TryParse(parts[1], out var id1) && 
                    Guid.TryParse(parts[2], out var id2))
                {
                    Guid.TryParse(userId, out var userGuid);
                    var allMessages = await _repo.GetMessagesAllAsync();
                    
                    var history = allMessages
                        .Where(m => (m.SenderUserId == id1 && m.ReceiverUserId == id2) ||
                                    (m.SenderUserId == id2 && m.ReceiverUserId == id1))
                        .OrderBy(m => m.SentAt)
                        .Select(m => new {
                            messageId = m.IdMessage.ToString(),
                            senderId = m.SenderUserId.ToString(),
                            senderName = m.SenderUserId == userGuid ? displayName : "Outro",
                            content = m.MessageContent,
                            timestamp = m.SentAt?.ToString("o"),
                            type = "text"
                        }).ToList();

                    await Clients.Caller.SendAsync("RoomJoined", new { messages = history });
                }
                else
                {
                    // Se os IDs não forem Guids válidos, devolve histórico vazio e não rebenta
                    await Clients.Caller.SendAsync("RoomJoined", new { messages = new object[] { } });
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erro crítico no JoinRoom: {ex.Message}");
                await Clients.Caller.SendAsync("RoomJoined", new { messages = new object[] { } });
            }
        }

        public async Task LeaveRoom(string channelName)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, channelName);
        }

        public async Task SendMessage(string channelName, string senderId, string content)
        {
            try 
            {
                var parts = channelName.Split('_');
                if (parts.Length != 3) return;

                // Verifica se os IDs são válidos antes de inserir na base de dados
                if (!Guid.TryParse(parts[1], out var id1) || 
                    !Guid.TryParse(parts[2], out var id2) || 
                    !Guid.TryParse(senderId, out var senderGuid)) 
                {
                    Console.WriteLine("IDs inválidos no SendMessage. A mensagem não foi guardada.");
                    return;
                }
                
                var receiverGuid = (senderGuid == id1) ? id2 : id1;

                var newMessage = new Message
                {
                    IdMessage = Guid.NewGuid(),
                    SenderUserId = senderGuid,
                    ReceiverUserId = receiverGuid,
                    MessageContent = content,
                    IsRead = false,
                    SentAt = DateTime.UtcNow
                };

                // Guarda na BD PostgreSQL
                var messageId = await _repo.InsertMessageAsync(newMessage);

                var formattedMessage = new {
                    messageId = messageId.ToString(),
                    senderId = senderId,
                    senderName = "User", 
                    content = content,
                    timestamp = newMessage.SentAt?.ToString("o"),
                    type = "text"
                };

                await Clients.Group(channelName).SendAsync("MessageReceived", formattedMessage);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Erro crítico no SendMessage: {ex.Message}");
            }
        }
    }
}