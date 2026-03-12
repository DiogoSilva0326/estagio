# Implementação de Chat - Agora Video Chat

## Visão Geral

Este documento descreve a implementação completa da funcionalidade de chat no projeto `agora_web_quickstart_VideoChat_Flutter_C#`, baseada na lógica do projeto `agora_quickstart_Chat`.

## Arquitetura

A implementação segue o padrão MVC (Model-View-Controller) no backend C# e o padrão Provider no frontend Flutter.

### Backend (C# .NET)

#### 1. Models (`AgoraBackend/agoraAPI/Models/ChatModels.cs`)

Classes de modelos para representar dados de chat:

- **LoginRequest**: Dados de login (UserId, Token)
- **SendMessageRequest**: Dados para enviar mensagem (To, Message, MessageType)
- **LoginResponse**: Resposta do login com sucesso/falha
- **SendMessageResponse**: Resposta do envio de mensagem
- **ChatMessage**: Modelo de mensagem completa com timestamp
- **ApiResponse<T>**: Wrapper genérico para respostas da API

#### 2. Services (`AgoraBackend/agoraAPI/Services/AgoraChatService.cs`)

Interface `IAgoraChatService` e implementação `AgoraChatService`:

- **LoginAsync**: Valida e registra usuário
- **SendMessageAsync**: Envia mensagem entre usuários
- **GetMessagesAsync**: Recupera mensagens do usuário (últimas 100)
- **LogoutAsync**: Remove sessão do usuário

**Características**:
- Armazenamento em memória (in-memory) para demonstração
- Sistema de sessões ativas com tokens
- Logging integrado para rastreamento

#### 3. Controllers (`AgoraBackend/agoraAPI/Controllers/ChatController.cs`)

Endpoints REST API:

- `POST /api/chat/login` - Login de usuário
- `POST /api/chat/send?userId={id}` - Enviar mensagem
- `GET /api/chat/messages?userId={id}` - Buscar mensagens
- `POST /api/chat/logout?userId={id}` - Logout

Todos os endpoints retornam `ApiResponse<T>` com:
- `Success`: boolean
- `Message`: string de descrição
- `Data`: dados tipados

#### 4. Registro de Serviço (`AgoraBackend/Program.cs`)

```csharp
builder.Services.AddSingleton<IAgoraChatService, AgoraChatService>();
```

### Frontend (Flutter)

#### 1. Service Layer (`lib/services/chat_api_service.dart`)

Classe `ChatApiService` com métodos estáticos:

- **login()**: Autenticação de usuário
- **sendMessage()**: Envio de mensagem
- **getMessages()**: Recuperação de mensagens
- **logout()**: Encerramento de sessão

**Classes de modelo**:
- `LoginResponse`
- `SendMessageResponse`
- `ChatMessage`

#### 2. State Management (`lib/providers/chat_provider.dart`)

Provider `ChatProvider` (ChangeNotifier):

**Estado**:
- `userId`, `token`, `peerId`
- `isChatLoggedIn`
- `logs`: lista de eventos
- `messages`: lista de mensagens

**Métodos**:
- `login()`: Autentica usuário
- `sendMessage()`: Envia mensagem e atualiza lista
- `fetchMessages()`: Busca mensagens periodicamente
- `logout()`: Limpa estado e encerra sessão

#### 3. UI Layer (`lib/pages/chat_page.dart`)

Interface dividida em dois estados:

**Tela de Login**:
- Campos: User ID, Token
- Botão de login
- Painel de logs

**Tela de Chat**:
- Campo: Peer User ID
- Campo de mensagem com botão enviar
- Lista de mensagens com bubbles (estilo WhatsApp)
- Painel de logs
- Botão de logout

**Características**:
- Polling automático de mensagens (3 segundos)
- Auto-scroll nos logs
- Diferenciação visual de mensagens enviadas/recebidas
- Timestamp nas mensagens

#### 4. Integração na Aplicação (`lib/main.dart`)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ChatProvider()),
  ],
  child: const AgoraApp(),
)
```

Nova rota: `/chat`

#### 5. Navegação (`lib/pages/home_page.dart`)

Adicionado:
- Botão "Open Chat" na tela principal
- Ícone de chat no AppBar
- Feature "Text Chat" na lista de recursos

## Dependências Adicionadas

### Flutter (`pubspec.yaml`)
```yaml
provider: ^6.1.2
```

## Como Usar

### 1. Iniciar o Backend

```bash
cd AgoraBackend
dotnet run
```

O servidor estará disponível em `http://localhost:8082`

### 2. Iniciar o Frontend

```bash
cd agora_frontend
flutter pub get
flutter run
```

### 3. Usar o Chat

1. Na tela inicial, clique em "Open Chat" ou no ícone de chat no AppBar
2. Na tela de login do chat:
   - Digite um **User ID** (ex: user1)
   - Digite um **Token** (qualquer string, ex: token123)
   - Clique em "Login"
3. Após login:
   - Digite o **Peer User ID** (ID do destinatário)
   - Digite sua mensagem
   - Clique em "Send"
4. As mensagens aparecem automaticamente (polling de 3 segundos)

### 4. Testar com Múltiplos Usuários

Abra duas instâncias do aplicativo:
- **Instância 1**: Login como "user1"
- **Instância 2**: Login como "user2"

Em cada instância, defina o Peer ID como o ID do outro usuário e envie mensagens.

## Endpoints da API

### POST /api/chat/login
```json
Request:
{
  "userId": "user1",
  "token": "token123"
}

Response:
{
  "success": true,
  "message": "User user1 logged in successfully",
  "data": {
    "success": true,
    "message": "User user1 logged in successfully",
    "userId": "user1",
    "token": "token123"
  }
}
```

### POST /api/chat/send?userId=user1
```json
Request:
{
  "to": "user2",
  "message": "Hello!",
  "messageType": "txt"
}

Response:
{
  "success": true,
  "message": "Message sent to user2",
  "data": {
    "success": true,
    "message": "Message sent to user2",
    "messageId": "guid-here",
    "timestamp": "2026-01-26T12:00:00Z"
  }
}
```

### GET /api/chat/messages?userId=user1
```json
Response:
{
  "success": true,
  "message": "Messages retrieved successfully",
  "data": [
    {
      "messageId": "guid-here",
      "from": "user1",
      "to": "user2",
      "content": "Hello!",
      "type": "txt",
      "timestamp": "2026-01-26T12:00:00Z"
    }
  ]
}
```

### POST /api/chat/logout?userId=user1
```json
Response:
{
  "success": true,
  "message": "Logged out successfully",
  "data": true
}
```

## Diferenças da Implementação Original

1. **Armazenamento**: Mantido em memória (não persistente) - ideal para demonstração
2. **Tema**: Adaptado para tema dark do aplicativo
3. **Integração**: Totalmente integrada com a navegação existente
4. **Provider**: Usado para gerenciamento de estado global
5. **Polling**: Implementado no frontend para simular atualizações em tempo real

## Melhorias Futuras

1. **Persistência**: Adicionar banco de dados (PostgreSQL, MongoDB)
2. **WebSockets**: Substituir polling por conexão em tempo real
3. **Autenticação**: Integrar com sistema de autenticação Agora
4. **Notificações**: Push notifications para novas mensagens
5. **Histórico**: Paginação de mensagens antigas
6. **Anexos**: Suporte a imagens e arquivos
7. **Status de leitura**: Indicadores de mensagens lidas
8. **Digitando...**: Indicador quando usuário está digitando
9. **Grupos**: Suporte a chat em grupo
10. **Criptografia**: E2E encryption para segurança

## Testando a API

### Usando cURL

```bash
# Login
curl -X POST http://localhost:8082/api/chat/login \
  -H "Content-Type: application/json" \
  -d '{"userId":"user1","token":"token123"}'

# Enviar mensagem
curl -X POST "http://localhost:8082/api/chat/send?userId=user1" \
  -H "Content-Type: application/json" \
  -d '{"to":"user2","message":"Hello!","messageType":"txt"}'

# Buscar mensagens
curl -X GET "http://localhost:8082/api/chat/messages?userId=user1"

# Logout
curl -X POST "http://localhost:8082/api/chat/logout?userId=user1"
```

## Estrutura de Arquivos Criados/Modificados

```
AgoraBackend/
├── Program.cs (modificado - registra serviço de chat)
└── agoraAPI/
    ├── Controllers/
    │   └── ChatController.cs (novo)
    ├── Models/
    │   └── ChatModels.cs (novo)
    └── Services/
        └── AgoraChatService.cs (novo)

agora_frontend/
├── pubspec.yaml (modificado - adiciona provider)
├── lib/
│   ├── main.dart (modificado - adiciona provider e rota)
│   ├── pages/
│   │   ├── home_page.dart (modificado - adiciona botão chat)
│   │   └── chat_page.dart (novo)
│   ├── providers/
│   │   └── chat_provider.dart (novo)
│   └── services/
│       └── chat_api_service.dart (novo)
```

## Conclusão

A implementação está completa e funcional, seguindo as melhores práticas de:
- Separação de responsabilidades (MVC)
- Gerenciamento de estado (Provider)
- Comunicação REST API
- UI/UX consistente com o aplicativo

O sistema está pronto para uso e pode ser expandido com as melhorias sugeridas.
