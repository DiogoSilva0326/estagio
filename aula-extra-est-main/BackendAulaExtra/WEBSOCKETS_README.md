# WebSockets / SignalR — Como o projeto usa WebSockets

Este documento descreve como o projeto implementa e usa WebSockets (SignalR) para o chat em tempo real e indica a rota/URL onde o hub WebSocket está hospedado.

**Resumo rápido**
- Backend: ASP.NET Core com SignalR (classe `ChatHub`).
- Rota do Hub: `/chathub` (mapeada em `Program.cs` via `app.MapHub<ChatHub>("/chathub")`).
- Endpoint base local usado pelo Flutter (padrão): `http://localhost:5050` → Hub: `http://localhost:5050/chathub`.
- Frontend (Flutter): usa o package `signalr_netcore` e cria `HubConnection` para `.../chathub`.

**Localização de ficheiros importantes**
- Backend (SignalR Hub):
  - `Synget.AgoraIntegrator.API/Hubs/ChatHub.cs` — implementação do hub (métodos: `JoinRoom`, `LeaveRoom`, `SendMessage`, `GetParticipants`, `GetHistory`, etc.).
  - `Synget.AgoraIntegrator.API/Program.cs` — configuração do servidor, CORS e mapeamento do hub: `app.MapHub<ChatHub>("/chathub");`.
- Biblioteca de Chat (server-side):
  - `Synget.ChatIntegrator` — contém modelos e lógica de persistência/manutenção das salas e participantes.
- Flutter (cliente SignalR):
  - `agora_test_app/lib/services/chat_service.dart` — cria a `HubConnection` com `HubConnectionBuilder().withUrl(_hubUrl)` e regista handlers para eventos do hub.


Como o backend expõe o WebSocket
--------------------------------
1. O projeto adiciona SignalR ao pipeline:
   - `builder.Services.AddSignalR();`
2. Define CORS para permitir conexões do frontend (o exemplo atual usa `AllowAll` com `AllowCredentials()` para suportar SignalR):
   - isto permite que aplicações web/Flutter se liguem ao hub.
3. Mapeia o hub na rota `/chathub` em `Program.cs`:
   - `app.MapHub<ChatHub>("/chathub");`

Quando o servidor estiver a correr em `http://localhost:5050`, o hub fica acessível (negotiate + upgrade) em:
- Negotiate: `http://localhost:5050/chathub/negotiate`
- WebSocket (após negotiate/upgrade): `ws://localhost:5050/chathub` (ou `wss://...` quando sobre HTTPS)

Observação: a infração real da ligação SignalR envolve primeiro uma requisição `negotiate`, que devolve informações para estabelecer/negociar o transporte (WebSockets, Server-Sent Events, Long Polling). O cliente SignalR trata automaticamente deste fluxo.

Como o Flutter (cliente) se liga
-------------------------------
Ficheiro: `agora_test_app/lib/services/chat_service.dart`

- Package usado: `signalr_netcore` (`import 'package:signalr_netcore/signalr_client.dart';`).
- O URL do hub é construído no getter `_hubUrl`:
  - Por defeito: `API_BASE_URL` (variável de ambiente) ou `http://localhost:5050` quando não existe.
  - `return '$cleanBase/chathub';`
- Conexão e handlers (exemplos do código):
  - `HubConnectionBuilder().withUrl(_hubUrl).withAutomaticReconnect().build();`
  - Eventos registados: `RoomJoined`, `MessageReceived`, `UserJoined`, `UserLeft`, `UserTyping`, `Participants`, `History`, `Error`.
  - Chamadas ao server (invoke): `JoinRoom`, `LeaveRoom`, `SendMessage`, `TypingIndicator`, `GetHistory`.

Fluxo de ligação (cliente):
1. Cria `HubConnection` com URL do hub.
2. Regista callbacks com `.on('EventName', handler)`.
3. `await _hubConnection.start();` — inicia a ligação (faz negotiate e tenta upgrade para WebSocket).
4. `invoke('JoinRoom', args: [channelName, userId, displayName])` — junta-se à sala (o server adiciona à SignalR group).

URLs / Endpoints relevantes
---------------------------
- Hub (negócio principal): `http://<HOST>:<PORT>/chathub` — Ex.: `http://localhost:5050/chathub`.
- Negotiate (internal SignalR): `http://localhost:5050/chathub/negotiate`.
- Para usar segurança TLS/HTTPS em produção, exponha o servidor sobre `https://` e então o transporte seguro será `wss://<host>/chathub`.

Como executar localmente e testar
--------------------------------
1. Backend (API + SignalR):
   - Abra uma shell na pasta do projeto da API (ex.: `Synget.AgoraIntegrator.API`).
   - Execute (exemplo de comando usado durante desenvolvimento):

```bash
cd /path/to/Synget.AgoraIntegrator.API
# start server on porta 5050
dotnet run --urls "http://localhost:5050"
```

2. Flutter (cliente):
   - Defina a variável `API_BASE_URL` para apontar para o seu backend. O projeto usa `flutter_dotenv`.
   - Crie um ficheiro `.env` em `agora_test_app/` com o conteúdo:

```
API_BASE_URL=http://localhost:5050
```

   - Inicie a app Flutter:

```bash
cd /path/to/agora_test_app
flutter pub get
flutter run
```

3. Testar com um cliente JavaScript (rápido exemplo de consola devtools):
```js
// Execute no browser console (assumindo @microsoft/signalr disponível, p.ex. num pequeno HTML)
const connection = new signalR.HubConnectionBuilder()
  .withUrl('http://localhost:5050/chathub')
  .build();

connection.on('MessageReceived', msg => console.log('msg', msg));
await connection.start();
console.log('Conectado');
await connection.invoke('JoinRoom', 'room1', 'user1', 'User One');
```

Dicas e resolução de problemas
------------------------------
- CORS/Senhas: o servidor define uma política `AllowAll` com `AllowCredentials()` para permitir conexões do cliente; em produção restrinja as origens permitidas.
- Se a conexão falhar, verifique:
  - Se o backend está a correr na mesma porta/host que o `API_BASE_URL` configurado no Flutter.
  - Se há mensagens de erro no log do backend (ver `dotnet run` output) e no console `debugPrint` do Flutter.
  - Se estiver a testar em iOS/Android, certifique-se de que dispositivos físicos simuladores conseguem alcançar `localhost` (em alguns casos é preciso usar o IP da máquina, ex.: `http://192.168.1.42:5050`).
- Para ver a negociação SignalR manualmente: aceda `http://localhost:5050/chathub/negotiate` (devolve JSON com informações de transporte). Não é comum manipular isto à mão, mas é útil para depuração.

Eventos e métodos que o cliente usa (resumo)
-------------------------------------------
- Eventos recebidos do servidor (handlers registados no cliente):
  - `RoomJoined` — enviado ao juntar-se; contém histórico e participantes.
  - `MessageReceived` — nova mensagem na sala.
  - `UserJoined` / `UserLeft` — presença de participantes.
  - `UserTyping` — indicador de digitação.
  - `Participants` — lista atual de participantes.
  - `History` — mensagens históricas.
  - `Error` — erros enviados pelo hub.

- Métodos invocados no hub pelo cliente (`invoke`):
  - `JoinRoom(channelName, userId, displayName)`
  - `LeaveRoom(channelName)`
  - `SendMessage(channelName, content)`
  - `TypingIndicator(channelName, isTyping)`
  - `GetHistory(channelName, limit, beforeTimestamp)`

Referências de ficheiros no projeto
----------------------------------
- `Synget.AgoraIntegrator.API/Hubs/ChatHub.cs` — implementação do Hub (server-side).
- `Synget.AgoraIntegrator.API/Program.cs` — adiciona SignalR e mapeia o hub: `app.MapHub<ChatHub>("/chathub");`.
- `agora_test_app/lib/services/chat_service.dart` — cliente SignalR em Flutter (usa `signalr_netcore`).

Perguntas/Próximos passos
------------------------
- Quer que eu adicione este ficheiro `WEBSOCKETS_README.md` ao repositório e faça um commit? (posso criar o commit/PR se quiseres).
- Quer também exemplos práticos de teste (um pequeno HTML/JS que liga ao hub) ou um script para validar negociações usando `curl`/`wscat`?

---
(Documento gerado automaticamente com base na estrutura do repositório e no código encontrado.)