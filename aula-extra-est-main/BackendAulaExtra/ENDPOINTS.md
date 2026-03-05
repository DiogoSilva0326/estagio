**API Endpoints - Synget AgoraIntegrator**

Este documento lista os endpoints disponíveis na API `Synget.AgoraIntegrator.API` (rota base: `/api/<controller>`), com uma breve descrição do que cada um faz. Use isto como referência rápida para desenvolvimento e testes.

**Video Calls**
- **POST `/api/VideoCalls/start`**: Inicia uma nova videochamada (cria um registro de chamada). Recebe um `StartCallDto`.
- **POST `/api/VideoCalls/{callId}/join`**: Participar numa chamada existente pelo `callId`.
- **POST `/api/VideoCalls/{callId}/leave`**: Sair de uma chamada específica.
- **POST `/api/VideoCalls/{callId}/end`**: Encerrar uma chamada (host/end).
- **GET `/api/VideoCalls/{callId}`**: Obter detalhes de uma chamada específica.
- **GET `/api/VideoCalls/channel/{channelName}`**: Obter informações da chamada pelo `channelName`.
- **GET `/api/VideoCalls/check/{channelName}`**: Verificar se existe uma chamada ativa no `channelName`.
- **GET `/api/VideoCalls/active`**: Listar chamadas ativas no sistema.
- **GET `/api/VideoCalls/user/{userId}/history`**: Histórico de chamadas para um utilizador.
- **GET `/api/VideoCalls/{callId}/participants`**: Lista de participantes de uma chamada.
- **POST `/api/VideoCalls/start-by-username`**: Iniciar chamada usando username em vez de IDs.
- **POST `/api/VideoCalls/join-by-username`**: Juntar-se a chamada por username.
- **POST `/api/VideoCalls/leave-by-username`**: Sair de chamada por username.
- **POST `/api/VideoCalls/end-by-channel/{channelName}`**: Encerrar chamada pelo `channelName`.

**Files**
- **POST `/api/Files/upload`**: Fazer upload de um ficheiro (envia ficheiro para /uploads, cria registo metadata).
- **GET `/api/Files/{fileId}`**: Fazer download do ficheiro identificado por `fileId`.
- **GET `/api/Files/{fileId}/info`**: Obter informação/metadata do ficheiro.
- **DELETE `/api/Files/{fileId}`**: Eliminar um ficheiro do sistema.
- **GET `/api/Files/user/{username}`**: Listar ficheiros de um utilizador.
- **GET `/api/Files/room/{roomId}`**: Listar ficheiros enviados numa sala especificada.
- **GET `/api/Files/{fileId}/access/{username}`**: Gerar/validar acesso de um `username` a um ficheiro.

**Authentication**
- **POST `/api/Auth/register`**: Registar um novo utilizador.
- **POST `/api/Auth/login`**: Autenticar (login) e receber token/session.
- **POST `/api/Auth/logout`**: Terminar sessão do utilizador.
- **GET `/api/Auth/me`**: Obter dados do utilizador autenticado.
- **GET `/api/Auth/validate`**: Validar token/estado de sessão.
- **PUT `/api/Auth/users/{userId}/role`**: Atualizar role de um utilizador (admin action).
- **GET `/api/Auth/users`**: Listar utilizadores (possivelmente com paginação/filtragem).

**Professor Rooms**
- **GET `/api/ProfessorRooms`**: Listar todas as professor rooms.
- **GET `/api/ProfessorRooms/{id}`**: Obter detalhes de uma `ProfessorRoom` por ID.
- **GET `/api/ProfessorRooms/professor/{professorId}`**: Obter sala de um professor por ID.
- **GET `/api/ProfessorRooms/by-name/{roomName}`**: Obter sala por `roomName`.
- **GET `/api/ProfessorRooms/by-username/{username}`**: Obter sala por username do professor.
- **GET `/api/ProfessorRooms/check-name/{roomName}`**: Verificar disponibilidade/validade do nome da sala.
- **PUT `/api/ProfessorRooms/professor/{professorId}/room-name`**: Atualizar nome da sala do professor.
- **PUT `/api/ProfessorRooms/{id}`**: Atualizar dados da sala.

**Standalone Chat (DMs & Groups)**
- **GET `/api/StandaloneChat/rooms/{userId}`**: Obter lista de salas (DMs e grupos) de um utilizador.
- **GET `/api/StandaloneChat/room/{roomId}`**: Obter informação sobre uma sala específica.
- **POST `/api/StandaloneChat/dm`**: Criar/obter canal directo (DM) entre utilizadores.
- **POST `/api/StandaloneChat/group`**: Criar uma sala de grupo.
- **POST `/api/StandaloneChat/group/{roomId}/members`**: Adicionar membros a um grupo.
- **DELETE `/api/StandaloneChat/group/{roomId}/members/{userId}`**: Remover membro do grupo.
- **GET `/api/StandaloneChat/room/{roomId}/messages`**: Listar mensagens de uma sala (paginado/limitado).

**Messages**
- **GET `/api/Messages/room/{roomId}`**: Listar mensagens de uma sala (grupo ou DM).
- **GET `/api/Messages/dm/{userId1}/{userId2}`**: Listar mensagens entre dois utilizadores (DM history).

**Users**
- **POST `/api/Users/register`**: Registar utilizador (alternativa a `/api/Auth/register` dependendo do fluxo).
- **GET `/api/Users/{id}`**: Obter utilizador por ID.
- **GET `/api/Users/by-username/{username}`**: Obter utilizador por username.
- **PUT `/api/Users/{id}/display-name`**: Atualizar display name do utilizador.
- **GET `/api/Users`**: Listar utilizadores.

**Tokens**
- **POST `/api/Token/rtc`**: Gerar token RTC para chamadas de áudio/video (usado pelo cliente para conectar ao Agora).
- **POST `/api/Token/rtm`**: Gerar token RTM (messaging).
- **POST `/api/Token/screenshare`**: Gerar token para screen sharing (UID especial).
- **GET `/api/Token/screenshare/check/{uid}`**: Verificar se um UID é de screen share.

**ProfessorRooms / Misc (outros controllers notáveis)**
- **(Session / Whiteboard / VideoRoom / GroupRooms / Contacts / WhiteboardController)**: Estes controllers expõem endpoints para gestão de sessões, integração com whiteboard (Netless), criação/listagem de salas de vídeo, gestão de contactos e funcionalidades auxiliares (ver arquivos `agora_web_quickstart_VideoChat_Flutter_C#/AgoraBackend` para endpoints do backend de exemplo).

---

Observações & Dicas de Uso
- Rota base: se a API estiver mapeada para porta `5050` no host (Docker compose), a URL base será `http://localhost:5050/api/...` ou `https://<ngrok>/api/...` se estiveres a usar o ngrok.
- Alguns endpoints exigem autenticação/headers (tokens). Verifica os métodos `[Authorize]` nos controllers se aplicável.
- Para testar WebSockets/SignalR: rota hub `GET/POST <baseUrl>/chathub` (SignalR hub). O cliente Flutter usa `.../chathub` por padrão.

Se quiseres, eu:
- Executo uma varredura completa e gero descrições mais detalhadas (parâmetros/DTOs/response types) em `ENDPOINTS.md`.
- Adiciono exemplos `curl` para cada endpoint.
Diz-me qual preferência (resumo curto — como acima — ou documento detalhado com exemplos).