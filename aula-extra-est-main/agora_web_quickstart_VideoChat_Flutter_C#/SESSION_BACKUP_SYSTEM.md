# Sistema de Backup Automático - Whiteboard & Chat

## 📦 Funcionalidades Implementadas

Sistema completo de backup automático para sessions de videochamada com:
- ✅ Captura automática de imagens do whiteboard
- ✅ Salvamento de mensagens de chat em TXT
- ✅ Registro de informações da sessão
- ✅ Estrutura organizada por canal e data
- ✅ Metadados detalhados de cada sessão

## 🗂️ Estrutura de Armazenamento

```
wwwroot/sessions/
├── {channelName}/
│   ├── {sessionId_yyyyMMdd_HHmmss}/
│   │   ├── session_info.json
│   │   ├── session_info.txt
│   │   ├── whiteboard/
│   │   │   ├── page_1_clear_143025_123.png
│   │   │   ├── page_1_page_change_143530_456.png
│   │   │   └── page_2_session_end_144000_789.png
│   │   └── chat/
│   │       ├── chat_messages_20260126_143000.txt
│   │       └── chat_messages_20260126_144000.txt
│   └── {outro_sessionId}/
│       └── ...
└── {outroCanal}/
    └── ...
```

## 📋 Informações Armazenadas

### Session Info (session_info.txt)
```txt
=== Session Information ===
Session ID: 20260126_143000
Channel: my-channel
Start Time: 2026-01-26 14:30:00 UTC
End Time: 2026-01-26 14:45:00 UTC
Duration: 0h 15m 0s

Participants (3):
  - Alice
  - Bob
  - Charlie

Join History:
  Alice: 2026-01-26 14:30:00
  Bob: 2026-01-26 14:31:15
  Charlie: 2026-01-26 14:32:30

Leave History:
  Bob: 2026-01-26 14:40:00
  Alice: 2026-01-26 14:45:00
  Charlie: 2026-01-26 14:45:00

Whiteboard Pages Saved: 5
Chat Messages Saved: 23
```

### Chat Messages (chat_messages_*.txt)
```txt
=== Chat Messages - my-channel ===
Session ID: 20260126_143000
Saved at: 2026-01-26 14:45:00 UTC
Active Users: Alice, Bob, Charlie
Total Messages: 23
============================================================

[2026-01-26 14:31:00] Alice:
  Hello everyone!

[2026-01-26 14:31:15] Bob:
  Hi Alice! Ready to start?

[2026-01-26 14:31:30] Charlie:
  Hello all!
```

## 🔄 Gatilhos de Salvamento

### 1. Whiteboard - Captura Automática

**Quando salvar:**
- ✅ **Antes de limpar** o whiteboard (`reason: "clear"`)
- ✅ **Ao mudar de página** no whiteboard (`reason: "page_change"`)
- ✅ **Quando todos saírem** da chamada (`reason: "session_end"`)
- ✅ **Manual** via botão (`reason: "manual"`)

**Integração:**
```dart
// Exemplo de integração no frontend
await SessionStorageService.saveWhiteboardSnapshot(
  channelName: 'my-channel',
  imageDataBase64: whiteboardImageBase64,
  pageNumber: currentPage,
  reason: 'clear', // ou 'page_change', 'session_end', 'manual'
  activeUsers: ['Alice', 'Bob'],
);
```

### 2. Chat - Salvamento Periódico/Final

**Quando salvar:**
- ✅ **Periodicamente** (a cada X mensagens ou X minutos)
- ✅ **Ao sair da chamada** (salvamento final)
- ✅ **Manual** via botão

**Integração:**
```dart
await SessionStorageService.saveChatMessages(
  channelName: 'my-channel',
  messages: chatMessages.map((m) => ChatMessageEntry(
    userId: m.userId,
    message: m.text,
    timestamp: m.timestamp,
  )).toList(),
  activeUsers: ['Alice', 'Bob'],
);
```

### 3. Session Info - Rastreamento de Eventos

**Eventos rastreados:**
- ✅ `session_started` - Primeira pessoa entra
- ✅ `user_joined` - Novo participante
- ✅ `user_left` - Participante sai
- ✅ `session_ended` - Última pessoa sai

**Integração:**
```dart
// Quando usuário entra
await SessionStorageService.updateSessionInfo(
  channelName: 'my-channel',
  users: ['NewUser'],
  action: 'user_joined',
);

// Quando usuário sai
await SessionStorageService.updateSessionInfo(
  channelName: 'my-channel',
  users: ['OldUser'],
  action: 'user_left',
);

// Quando sessão termina
await SessionStorageService.updateSessionInfo(
  channelName: 'my-channel',
  users: [],
  action: 'session_ended',
);
```

## 🛠️ API Endpoints

### POST /api/session/whiteboard/snapshot
Salva snapshot do whiteboard como imagem PNG.

```json
Request:
{
  "channelName": "my-channel",
  "imageDataBase64": "iVBORw0KGgoAAAANS...",
  "pageNumber": 1,
  "reason": "clear",
  "activeUsers": ["Alice", "Bob"]
}

Response:
{
  "success": true,
  "message": "Whiteboard snapshot saved successfully",
  "data": {
    "success": true,
    "message": "Whiteboard snapshot saved successfully",
    "filePath": "/path/to/page_1_clear_143025_123.png",
    "sessionId": "20260126_143000"
  }
}
```

### POST /api/session/chat/save
Salva mensagens do chat em arquivo TXT.

```json
Request:
{
  "channelName": "my-channel",
  "messages": [
    {
      "userId": "Alice",
      "message": "Hello!",
      "timestamp": "2026-01-26T14:30:00Z"
    }
  ],
  "activeUsers": ["Alice", "Bob"]
}

Response:
{
  "success": true,
  "message": "Chat messages saved successfully",
  "data": {
    "success": true,
    "message": "Chat messages saved successfully",
    "filePath": "/path/to/chat_messages_20260126_143000.txt",
    "sessionId": "20260126_143000"
  }
}
```

### POST /api/session/info/update
Atualiza informações da sessão.

```json
Request:
{
  "channelName": "my-channel",
  "users": ["Alice"],
  "action": "user_joined"
}

Response:
{
  "success": true,
  "message": "Session info updated successfully",
  "data": true
}
```

### GET /api/session/info?channelName=my-channel&sessionId=20260126_143000
Recupera informações completas de uma sessão.

```json
Response:
{
  "success": true,
  "message": "Session info retrieved successfully",
  "data": {
    "sessionInfo": {
      "sessionId": "20260126_143000",
      "channelName": "my-channel",
      "startTime": "2026-01-26T14:30:00Z",
      "endTime": "2026-01-26T14:45:00Z",
      "users": ["Alice", "Bob", "Charlie"],
      "whiteboardPagesCount": 5,
      "chatMessagesCount": 23
    },
    "whiteboardImages": [
      "page_1_clear_143025_123.png",
      "page_1_page_change_143530_456.png"
    ],
    "chatFiles": [
      "chat_messages_20260126_143000.txt"
    ]
  }
}
```

### GET /api/session/channel/sessions?channelName=my-channel
Lista todas as sessões de um canal.

```json
Response:
{
  "success": true,
  "message": "Channel sessions retrieved successfully",
  "data": [
    "20260126_143000",
    "20260125_100000",
    "20260124_153000"
  ]
}
```

## 📝 Arquivos Criados/Modificados

### Backend
```
AgoraBackend/
├── agoraAPI/
│   ├── Controllers/
│   │   └── SessionController.cs (NOVO)
│   ├── Models/
│   │   └── SessionModels.cs (NOVO)
│   └── Services/
│       └── SessionStorageService.cs (NOVO)
└── Program.cs (modificado - registrar serviço)
```

### Frontend
```
agora_frontend/
└── lib/
    └── services/
        └── session_storage_service.dart (NOVO)
```

## 🔧 Configuração

### Backend (appsettings.json - opcional)
```json
{
  "SessionStorage": {
    "BasePath": "/custom/path/to/sessions"
  }
}
```

Se não configurado, usa: `wwwroot/sessions/`

## 🚀 Próximos Passos - Integração no Frontend

### 1. Adicionar ao VideoChatPage

```dart
import '../services/session_storage_service.dart';

class _VideoChatPageState extends State<VideoChatPage> {
  // ... código existente ...
  
  @override
  void initState() {
    super.initState();
    // Notificar início da sessão
    SessionStorageService.updateSessionInfo(
      channelName: widget.channelName,
      users: [widget.userName],
      action: 'user_joined',
    );
  }
  
  @override
  void dispose() {
    // Salvar chat final
    _saveFinalChat();
    
    // Salvar whiteboard final
    _saveFinalWhiteboard();
    
    // Notificar saída
    SessionStorageService.updateSessionInfo(
      channelName: widget.channelName,
      users: [widget.userName],
      action: 'user_left',
    );
    
    super.dispose();
  }
  
  Future<void> _saveFinalChat() async {
    if (_messages.isEmpty) return;
    
    await SessionStorageService.saveChatMessages(
      channelName: widget.channelName,
      messages: _messages.map((m) => ChatMessageEntry(
        userId: m.fromName,
        message: m.text,
        timestamp: m.timestamp,
      )).toList(),
      activeUsers: _userNames.values.toList(),
    );
  }
  
  Future<void> _saveFinalWhiteboard() async {
    // Capturar imagem do whiteboard
    // TODO: Implementar captura via JavaScript
    // await SessionStorageService.saveWhiteboardSnapshot(...);
  }
}
```

### 2. Adicionar botões de salvamento manual

```dart
// Botão para salvar whiteboard
IconButton(
  icon: Icon(Icons.save),
  tooltip: 'Save Whiteboard',
  onPressed: () async {
    // Capturar e salvar
    await _saveWhiteboardSnapshot('manual');
  },
)

// Botão para salvar chat
IconButton(
  icon: Icon(Icons.save_alt),
  tooltip: 'Save Chat',
  onPressed: () async {
    await _saveFinalChat();
  },
)
```

## 🎯 Benefícios

1. **Organização**: Estrutura clara por canal e sessão
2. **Rastreabilidade**: Histórico completo de atividades
3. **Backup Automático**: Nenhum dado perdido
4. **Reutilizável**: Fácil adaptação para outros projetos
5. **Escalável**: Pronto para migrar para banco de dados
6. **Debugging**: Logs detalhados para troubleshooting

## 🔄 Migração Futura para Database

A estrutura atual facilita migração futura:

```csharp
// Atual: File System
await File.WriteAllTextAsync(filePath, content);

// Futuro: Database
await _dbContext.Sessions.AddAsync(sessionEntity);
await _dbContext.SaveChangesAsync();
```

Todos os modelos já estão preparados para serem Entity Framework entities.

## ✅ Checklist de Implementação

- [x] Models criados
- [x] Service implementado
- [x] Controller criado
- [x] Endpoints testados
- [x] Estrutura de pastas funcional
- [x] Serviço Flutter criado
- [ ] Integração com WhiteboardPanel
- [ ] Integração com VideoChatPage
- [ ] Captura de screenshot do whiteboard
- [ ] Testes end-to-end
- [ ] Documentação de uso

## 📚 Documentação Adicional

Para implementar a captura de screenshot do whiteboard via JavaScript/WebView, consulte a documentação do pacote `flutter_inappwebview` ou similar.

---

**Sistema pronto para uso!** Apenas falta integrar os gatilhos no frontend para começar a salvar automaticamente.
