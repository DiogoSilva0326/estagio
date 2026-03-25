using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.SignalR;
using ConfidantPostgreSQL.Modules.Communication.Repository;
using ConfidantPostgreSQL.Modules.Communication.Models;

namespace ConfidantPostgreSQL.Modules.Communication.Hubs
{
    public class ChatHub : Hub
    {
        private readonly ICommunicationRepository _repository;

        public ChatHub(ICommunicationRepository repository)
        {
            _repository = repository;
        }

        // Quando o Utilizador abre a app, regista-se no Hub com o seu ID pessoal
        public async Task JoinMyPersonalRoom(string myUserId)
        {
            // O SignalR cria um "tubo" exclusivo para este utilizador
            await Groups.AddToGroupAsync(Context.ConnectionId, myUserId);
        }

        // Método para enviar a mensagem em tempo real e guardar na BD
        public async Task SendPrivateMessage(string senderId, string receiverId, string content)
        {
            // 1. Guardar na Base de Dados usando o repositório que já limpámos!
            var message = new Message 
            {
                SenderUserId = Guid.Parse(senderId),
                ReceiverUserId = Guid.Parse(receiverId),
                MessageContent = content,
                IsRead = false,
                SentAt = DateTime.UtcNow
            };
            
            await _repository.InsertMessageAsync(message);

            // 2. Enviar a mensagem pelo WebSocket para o Ecrã da outra pessoa (e para nós mesmos)
            // O evento chama-se "MessageReceived" para o Flutter o conseguir apanhar
            string timeLabel = message.SentAt.Value.ToString("o"); // Formato ISO para o Flutter ler
            
            await Clients.Group(receiverId).SendAsync("MessageReceived", senderId, content, timeLabel);
            await Clients.Group(senderId).SendAsync("MessageReceived", senderId, content, timeLabel);
        }
    }
}