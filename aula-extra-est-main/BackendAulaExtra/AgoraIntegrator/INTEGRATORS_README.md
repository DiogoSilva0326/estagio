# Synget Integrators — Guia de Utilização

Este documento explica a arquitetura, funcionamento e como utilizar os Integrators com a API para implementar funcionalidades de vídeo chamadas (Agora RTC) e chat em tempo real (SignalR/WebSockets).

---

## Visão Geral da Arquitetura

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         Synget.AgoraIntegrator.API                      │
│                      (ASP.NET Core Web API + SignalR)                   │
├─────────────────────────────────────────────────────────────────────────┤
│  Controllers (REST)           │  Hubs (WebSocket/SignalR)               │
│  ├── TokenController          │  └── ChatHub                            │
│  ├── SessionController        │      (camada de transporte - thin)      │
│  ├── WhiteboardController     │                                         │
│  ├── ContactsController       │                                         │
│  └── StandaloneChatController │                                         │
└──────────────┬────────────────┴─────────────────┬───────────────────────┘
               │                                   │
               ▼                                   ▼
┌──────────────────────────────┐   ┌──────────────────────────────────────┐
│   Synget.AgoraIntegrator     │   │       Synget.ChatIntegrator          │
│   (.NET Class Library)       │   │       (.NET Class Library)           │
├──────────────────────────────┤   ├──────────────────────────────────────┤
│ Interface: IAgora            │   │ Interface: IChat                     │
│ ├── TokenGenerate()          │   │ ├── Room Operations                  │
│ ├── SessionCreate()          │   │ ├── Participant Operations           │
│ ├── SessionJoin()            │   │ ├── Message Operations               │
│ ├── SessionLeave()           │   │ ├── Contact Operations               │
│ └── Whiteboard Operations    │   │ ├── Standalone Chat (DM/Groups)      │
│                              │   │ └── High-Level Hub Operations        │
│ Implementação: AgoraService  │   │                                      │
│                              │   │ Implementação: ChatService           │
└──────────────────────────────┘   └──────────────────────────────────────┘
```

**Princípio de Design:**
- **Integrators** contêm toda a lógica de negócio (validação, persistência, transformações)
- **API/Hubs** são camadas finas de transporte (REST/WebSocket) que delegam ao Integrator
- Esta separação permite reutilizar os Integrators em diferentes contextos (API, console, testes)

---

## 1. Synget.AgoraIntegrator

### Propósito
Biblioteca para integração com Agora.io RTC (Real-Time Communication). Gera tokens, gere sessões de vídeo chamada e integra com o Agora Whiteboard (Netless).

### Ficheiros Principais
- `IAgora.cs` — Interface principal
- `AgoraService.cs` — Implementação
- `Models/` — DTOs e modelos de configuração

### Interface IAgora (métodos principais)

```csharp
public interface IAgora
{
    string Message { get; }  // Mensagem de erro/status da última operação
    
    // Inicialização
    bool Initialize(AgoraConfig config);
    
    // Geração de Tokens
    string? TokenGenerate(string channelName, int uid, int expirationSeconds = 3600);
    string? TokenGenerateWithAccount(string channelName, string userAccount, int expirationSeconds = 3600);
    
    // Gestão de Sessões
    AgoraSession? SessionCreate(string channelName, string creatorUserId, string displayName);
    AgoraSession? SessionJoin(string channelName, string uniqueUserId, string displayName);
    bool SessionLeave(string channelName, string uniqueUserId);
    AgoraSession? SessionGet(string channelName);
    AgoraSessionUser? SessionGetUser(string channelName, int agoraUid);
    List<AgoraSession> SessionGetAll();
    
    // Whiteboard
    string? WhiteboardTokenGenerate(string roomUuid, string region = "us-sv");
    WhiteboardRoomInfo? WhiteboardRoomCreate(string name, int limit = 0, string region = "us-sv");
}
```

### Como Usar na API

**1. Configuração em `Program.cs`:**

```csharp
// Carregar configuração
var agoraConfig = new AgoraConfig
{
    AppId = builder.Configuration["Agora:AppId"] ?? "",
    AppCertificate = builder.Configuration["Agora:AppCertificate"] ?? "",
    TokenExpirationSeconds = 3600,
    WhiteboardSdkToken = builder.Configuration["Whiteboard:NetlessSdkToken"] ?? "",
};

// Criar e inicializar
var agoraPlatformManager = new AgoraPlatformManager();
agoraPlatformManager.Initialize(agoraConfig);

// Registar como singleton
builder.Services.AddSingleton<IAgora>(agoraPlatformManager.Agora!);
```

**2. Injetar no Controller:**

```csharp
[ApiController]
[Route("api/[controller]")]
public class TokenController : ControllerBase
{
    private readonly IAgora _agora;
    
    public TokenController(IAgora agora)
    {
        _agora = agora;
    }
    
    [HttpPost]
    public IActionResult GenerateToken([FromBody] TokenRequest request)
    {
        var token = _agora.TokenGenerate(request.ChannelName, request.Uid);
        if (token == null)
            return BadRequest(_agora.Message);
            
        return Ok(new { token });
    }
}
```

### Endpoints REST Disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/api/token` | Gerar token RTC |
| POST | `/api/session` | Criar sessão de chamada |
| POST | `/api/session/{channel}/join` | Juntar-se a uma sessão |
| POST | `/api/session/{channel}/leave` | Sair de uma sessão |
| GET | `/api/session/{channel}` | Obter detalhes da sessão |
| GET | `/api/session/{channel}/user/{uid}` | Obter utilizador da sessão |
| POST | `/api/whiteboard/room` | Criar sala whiteboard |
| POST | `/api/whiteboard/token` | Gerar token whiteboard |

---

## 2. Synget.ChatIntegrator

### Propósito
Biblioteca para chat em tempo real. Gere salas de chat, participantes, mensagens, contactos e salas standalone (DMs e grupos). Desenhada para funcionar com SignalR mas é agnóstica ao transporte.

### Ficheiros Principais
- `IChat.cs` — Interface principal
- `ChatService.cs` — Implementação (armazenamento em memória)
- `Models/ChatModels.cs` — DTOs, modelos e resultados

### Interface IChat (resumo por categoria)

#### Operações de Sala
```csharp
ChatRoom? RoomGetOrCreate(string channelName);
ChatRoom? RoomGet(string channelName);
bool RoomClose(string channelName);
List<ChatRoom> RoomGetAll();
```

#### Operações de Participantes
```csharp
bool ParticipantJoin(string channelName, string userId, string displayName, string connectionId);
bool ParticipantLeave(string channelName, string userId);
ChatParticipant? ParticipantGet(string channelName, string userId);
ChatParticipant? ParticipantGetByConnection(string connectionId);
bool ParticipantUpdateConnection(string channelName, string userId, string newConnectionId);
```

#### Operações de Mensagens
```csharp
bool MessageStore(string channelName, ChatMessage message);
List<ChatMessage> MessageGetHistory(string channelName, int limit = 50, DateTime? beforeTimestamp = null);
bool MessageClearHistory(string channelName);
```

#### Operações de Contactos
```csharp
Contact? ContactAdd(string ownerId, string contactUserId, string displayName);
bool ContactRemove(string ownerId, string contactUserId);
List<Contact> ContactGetAll(string ownerId);
Contact? ContactGet(string ownerId, string contactUserId);
bool ContactUpdate(Contact contact);
```

#### Operações de Chat Standalone (DMs e Grupos)
```csharp
StandaloneChatRoom? DirectMessageCreate(string userId1, string userId2);
StandaloneChatRoom? DirectMessageGetOrCreate(string userId1, string userId2);
StandaloneChatRoom? GroupCreate(string creatorUserId, string groupName, IEnumerable<string> memberUserIds);
bool GroupAddMember(string roomId, string userId);
bool GroupRemoveMember(string roomId, string userId);
List<StandaloneChatRoom> StandaloneChatGetRooms(string userId);
StandaloneChatRoom? StandaloneChatGetRoom(string roomId);
```

#### Operações de Alto Nível para Hub (NOVO)
Estes métodos encapsulam toda a lógica e retornam DTOs prontos para broadcast:

```csharp
// Processa entrada na sala: regista participante, guarda mensagem de sistema, retorna histórico e participantes
JoinRoomResult ProcessJoinRoom(string channelName, string userId, string displayName, string connectionId);

// Processa saída da sala: guarda mensagem de sistema, remove participante, retorna evento
LeaveRoomResult ProcessLeaveRoom(string channelName, string connectionId);

// Processa envio de mensagem: valida, guarda, retorna DTO para broadcast
SendMessageResult ProcessSendMessage(string channelName, string content, string connectionId);

// Obtém histórico formatado para resposta do Hub
HistoryResult GetHistoryForHub(string channelName, int limit = 50, DateTime? beforeTimestamp = null);

// Obtém participantes formatados para resposta do Hub
ParticipantsResult GetParticipantsForHub(string channelName);

// Obtém evento de typing
UserEventDto? GetTypingEvent(string connectionId, bool isTyping);
```

### Como Usar na API

**1. Configuração em `Program.cs`:**

```csharp
// Adicionar SignalR
builder.Services.AddSignalR();

// Criar e registar ChatService
var chatService = new ChatService();
chatService.Initialize(new ChatConfig
{
    MaxMessagesPerRoom = 1000,
    MessageRetentionHours = 24
});
builder.Services.AddSingleton<IChat>(chatService);

// CORS para SignalR
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(_ => true)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

// ...

// Mapear Hub
app.MapHub<ChatHub>("/chathub");
```

**2. Implementação do Hub (camada fina):**

```csharp
public class ChatHub : Hub
{
    private readonly IChat _chat;
    private readonly ILogger<ChatHub> _logger;

    public ChatHub(IChat chat, ILogger<ChatHub> logger)
    {
        _chat = chat;
        _logger = logger;
    }

    public async Task JoinRoom(string channelName, string userId, string displayName)
    {
        // Adicionar ao grupo SignalR
        await Groups.AddToGroupAsync(Context.ConnectionId, channelName);

        // Toda a lógica está no Integrator
        var result = _chat.ProcessJoinRoom(channelName, userId, displayName, Context.ConnectionId);

        if (!result.Success)
        {
            await Clients.Caller.SendAsync("Error", result.Error);
            return;
        }

        // Enviar dados ao utilizador que entrou
        await Clients.Caller.SendAsync("RoomJoined", new
        {
            channelName = result.ChannelName,
            messages = result.Messages,
            participants = result.Participants
        });

        // Notificar outros
        if (result.UserEvent != null)
        {
            await Clients.OthersInGroup(channelName).SendAsync("UserJoined", result.UserEvent);
        }
    }

    public async Task SendMessage(string channelName, string content)
    {
        var result = _chat.ProcessSendMessage(channelName, content, Context.ConnectionId);

        if (!result.Success)
        {
            await Clients.Caller.SendAsync("Error", result.Error);
            return;
        }

        // Broadcast para todos na sala
        await Clients.Group(channelName).SendAsync("MessageReceived", result.Message);
    }
    
    // ... outros métodos seguem o mesmo padrão
}
```

**3. Controllers REST para Contactos e Chats Standalone:**

```csharp
[ApiController]
[Route("api/[controller]")]
public class ContactsController : ControllerBase
{
    private readonly IChat _chat;

    public ContactsController(IChat chat)
    {
        _chat = chat;
    }

    [HttpGet("{ownerId}")]
    public IActionResult GetContacts(string ownerId)
    {
        var contacts = _chat.ContactGetAll(ownerId);
        return Ok(contacts);
    }

    [HttpPost]
    public IActionResult AddContact([FromBody] AddContactRequest request)
    {
        var contact = _chat.ContactAdd(request.OwnerId, request.ContactUserId, request.DisplayName);
        if (contact == null)
            return BadRequest(_chat.Message);
        return Ok(contact);
    }
}
```

### Endpoints REST Disponíveis

| Método | Rota | Descrição |
|--------|------|-----------|
| GET | `/api/contacts/{ownerId}` | Listar contactos de um utilizador |
| POST | `/api/contacts` | Adicionar contacto |
| PUT | `/api/contacts` | Atualizar contacto |
| DELETE | `/api/contacts/{ownerId}/{contactUserId}` | Remover contacto |
| GET | `/api/standalonechat/user/{userId}` | Listar salas de chat de um utilizador |
| GET | `/api/standalonechat/room/{roomId}` | Obter detalhes de uma sala |
| POST | `/api/standalonechat/dm` | Criar/obter sala de DM |
| POST | `/api/standalonechat/group` | Criar grupo |
| POST | `/api/standalonechat/group/{roomId}/member` | Adicionar membro ao grupo |
| DELETE | `/api/standalonechat/group/{roomId}/member/{userId}` | Remover membro do grupo |

### Eventos WebSocket (SignalR Hub)

| Evento | Direção | Descrição |
|--------|---------|-----------|
| `RoomJoined` | Server → Client | Enviado ao caller após entrar na sala (histórico + participantes) |
| `UserJoined` | Server → Others | Notifica outros quando alguém entra |
| `UserLeft` | Server → Others | Notifica outros quando alguém sai |
| `MessageReceived` | Server → All | Nova mensagem na sala |
| `UserTyping` | Server → Others | Indicador de digitação |
| `Participants` | Server → Caller | Lista de participantes (resposta a GetParticipants) |
| `History` | Server → Caller | Histórico de mensagens (resposta a GetHistory) |
| `Error` | Server → Caller | Mensagem de erro |

### Métodos do Hub (Client → Server)

| Método | Parâmetros | Descrição |
|--------|------------|-----------|
| `JoinRoom` | channelName, userId, displayName | Entrar numa sala |
| `LeaveRoom` | channelName | Sair de uma sala |
| `SendMessage` | channelName, content | Enviar mensagem |
| `GetParticipants` | channelName | Obter lista de participantes |
| `GetHistory` | channelName, limit?, beforeTimestamp? | Obter histórico |
| `TypingIndicator` | channelName, isTyping | Enviar indicador de digitação |

---

## 3. DTOs de Resultado (Synget.ChatIntegrator)

Os DTOs de resultado encapsulam todos os dados necessários para o Hub fazer broadcast sem precisar de transformações:

```csharp
// Resultado de JoinRoom
public class JoinRoomResult
{
    public bool Success { get; set; }
    public string? Error { get; set; }
    public string ChannelName { get; set; }
    public List<MessageDto> Messages { get; set; }      // Histórico
    public List<ParticipantDto> Participants { get; set; } // Participantes atuais
    public UserEventDto? UserEvent { get; set; }        // Para broadcast de UserJoined
}

// Resultado de SendMessage
public class SendMessageResult
{
    public bool Success { get; set; }
    public string? Error { get; set; }
    public MessageDto? Message { get; set; }  // DTO pronto para broadcast
}

// DTO de mensagem (pronto para JSON)
public class MessageDto
{
    public string MessageId { get; set; }
    public string SenderId { get; set; }
    public string SenderName { get; set; }
    public string Content { get; set; }
    public DateTime Timestamp { get; set; }
    public string Type { get; set; }  // "text", "system", etc.
}
```

---

## 4. Boas Práticas

### Separação de Responsabilidades
- ✅ **Integrator**: Validação, lógica de negócio, persistência, transformações de dados
- ✅ **Hub/Controller**: Gestão de conexões, routing, serialização JSON, broadcast

### Reutilização
Os Integrators podem ser usados em:
- APIs Web (como demonstrado)
- Aplicações de consola
- Testes unitários
- Outros projetos .NET

### Thread Safety
O `ChatService` usa `lock(_lock)` para garantir thread safety nas operações de leitura/escrita.

### Extensibilidade
Para adicionar persistência em base de dados:
1. Criar nova implementação de `IChat` (ex: `ChatServiceSqlServer`)
2. Manter a mesma interface
3. Trocar a implementação em `Program.cs`

---

## 5. Exemplo Completo de Fluxo

### Fluxo de Entrada numa Sala de Chat

```
1. Cliente Flutter chama hub.invoke('JoinRoom', ['sala1', 'user123', 'João'])
   
2. ChatHub.JoinRoom() recebe a chamada:
   a. Adiciona ao grupo SignalR: Groups.AddToGroupAsync(connectionId, 'sala1')
   b. Chama Integrator: _chat.ProcessJoinRoom('sala1', 'user123', 'João', connectionId)
   
3. ChatService.ProcessJoinRoom() no Integrator:
   a. Valida parâmetros
   b. Chama ParticipantJoin() para registar o utilizador
   c. Cria e guarda mensagem de sistema "João joined the chat"
   d. Obtém histórico de mensagens
   e. Obtém lista de participantes
   f. Retorna JoinRoomResult com tudo pronto
   
4. ChatHub continua:
   a. Envia 'RoomJoined' ao caller com histórico e participantes
   b. Envia 'UserJoined' aos outros na sala
   
5. Cliente Flutter recebe eventos e atualiza a UI
```

---

## 6. Configuração (appsettings.json)

```json
{
  "Agora": {
    "AppId": "seu_app_id_aqui",
    "AppCertificate": "seu_certificate_aqui",
    "TokenExpirationSeconds": 3600
  },
  "Whiteboard": {
    "NetlessSdkToken": "seu_netless_sdk_token",
    "AppIdentifier": "seu_app_identifier",
    "Region": "us-sv"
  }
}
```

---

## 7. Execução

```bash
# Backend
cd Synget.AgoraIntegrator.API
dotnet run --urls "http://localhost:5050"

# Verificar endpoints
curl http://localhost:5050/swagger

# Testar SignalR negotiate
curl http://localhost:5050/chathub/negotiate
```

---

## Resumo

| Componente | Responsabilidade | Transporte |
|------------|------------------|------------|
| `Synget.AgoraIntegrator` | Tokens Agora, Sessões, Whiteboard | REST (via Controllers) |
| `Synget.ChatIntegrator` | Chat, Mensagens, Contactos, DMs, Grupos | REST + WebSocket (via Controllers + ChatHub) |
| `ChatHub` | Camada fina de transporte SignalR | WebSocket |
| Controllers | Camada fina de transporte REST | HTTP |

A arquitetura garante que toda a lógica reside nos Integrators, tornando o código testável, reutilizável e fácil de manter.
