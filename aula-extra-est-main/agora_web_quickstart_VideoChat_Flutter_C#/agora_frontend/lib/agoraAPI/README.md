# AgoraAPI - Módulo Reutilizável

Este módulo contém toda a lógica necessária para integração com Agora RTC, facilitando a reutilização em outros projetos Flutter.

## Funcionalidades

✅ Chamadas de vídeo e áudio em tempo real
✅ Compartilhamento de tela
✅ Whiteboard colaborativo integrado (Netless)
✅ Gerenciamento de nomes de usuários
✅ Data streams para mensagens personalizadas
✅ Suporte multi-plataforma (Web, iOS, Android, macOS)

## Estrutura

```
agoraAPI/
├── agora_api.dart          # Arquivo barrel (export principal)
├── agora_manager.dart      # Gerenciador centralizado
├── services/
│   ├── agora_service.dart  # Wrapper do RTC Engine
│   └── token_service.dart  # Comunicação com backend
├── widgets/
│   └── whiteboard_panel.dart  # Widget do whiteboard
└── pages/
    └── video_call_page.dart   # Página de chamada de vídeo
```

## Como Usar em Outro Projeto

### 1. Copiar a Pasta

Copie a pasta `agoraAPI/` inteira para o diretório `lib/` do seu projeto.

### 2. Configurar Variáveis de Ambiente

Crie um arquivo `.env` na raiz do seu projeto:

```env
AGORA_APP_ID=your_agora_app_id
TOKEN_SERVER_URL=http://localhost:8082/fetch_rtc_token
WHITEBOARD_SERVER_URL=http://localhost:8082/fetch_whiteboard_token
DEFAULT_CHANNEL=test-channel
```

### 3. Adicionar Dependências no pubspec.yaml

```yaml
dependencies:
  agora_rtc_engine: ^6.3.2
  flutter_dotenv: ^5.1.0
  http: ^1.2.0
  permission_handler: ^11.3.0
  webview_flutter: ^4.7.0  # Para whiteboard
  webview_flutter_web: ^0.2.2+4  # Para whiteboard na web
```

### 4. Usar no Código

#### Opção A: Usar o AgoraManager (Recomendado)

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'agoraAPI/agora_api.dart';

// No main
await dotenv.load(fileName: '.env');

// Na sua página
final agoraManager = AgoraManager();

// Inicializar
await agoraManager.initialize(dotenv.env['AGORA_APP_ID']!);

// Configurar callbacks
agoraManager.onJoinSuccess = () {
  print('Entrou no canal!');
};

agoraManager.onUserJoined = (uid) {
  print('Usuário $uid entrou');
};

// Entrar em um canal
await agoraManager.joinChannel(
  channelName: 'meu-canal',
  displayName: 'João Silva',
);

// Compartilhar tela
await agoraManager.startScreenShare();

// Sair
await agoraManager.leaveChannel();
await agoraManager.dispose();
```

#### Opção B: Usar os Serviços Diretamente

```dart
import 'agoraAPI/services/agora_service.dart';
import 'agoraAPI/services/token_service.dart';

final agoraService = AgoraService();
final tokenService = TokenService();

// Inicializar
await agoraService.initialize(appId);

// Buscar token
final token = await tokenService.fetchRtcToken(
  channelName: 'canal',
  uid: 123,
);

// Entrar no canal
await agoraService.joinChannel(
  token: token,
  channelName: 'canal',
  uid: 123,
  displayName: 'Nome',
  appId: appId,
);
```

## Backend Necessário

O módulo requer um backend para gerar tokens de segurança. O backend está incluído na pasta `AgoraBackend/agoraAPI/`.

### Endpoints Necessários

```
POST /fetch_rtc_token
Body: { "uid": 123, "channelName": "canal", "role": 1 }
Response: { "token": "006abc...", "code": "200" }

POST /fetch_whiteboard_token
Body: { "uid": 123, "channelName": "canal" }
Response: { "uuid": "room-uuid", "token": "NETLESSROOM_..." }
```

### Executar o Backend

```bash
cd AgoraBackend
dotnet run
```

O servidor estará disponível em `http://localhost:8082`.

## Personalização

### Alterar a URL do Backend

Edite o arquivo `.env`:

```env
TOKEN_SERVER_URL=https://seu-backend.com/fetch_rtc_token
WHITEBOARD_SERVER_URL=https://seu-backend.com/fetch_whiteboard_token
```

### Adicionar Callbacks Personalizados

```dart
agoraManager.onError = (error) {
  // Seu código para tratar erros
};

agoraManager.onUserNameUpdated = (uid, name) {
  // Seu código quando um nome é atualizado
};

agoraManager.onScreenShareStateChanged = (isSharing) {
  // Seu código quando o estado de compartilhamento muda
};
```

## Troubleshooting

### "Unable to resolve service for type 'System.String'"
- Certifique-se de que o backend foi compilado após a reorganização
- Execute `dotnet build` na pasta AgoraBackend

### "Missing env var: AGORA_APP_ID"
- Verifique se o arquivo `.env` existe e está carregado
- Adicione `await dotenv.load(fileName: '.env');` antes de usar o módulo

### Permissões negadas (iOS/Android)
- Adicione permissões no `Info.plist` (iOS) e `AndroidManifest.xml` (Android)
- O módulo usa `permission_handler` automaticamente

## Licença

Este módulo é parte do projeto AgoraAPI e segue a mesma licença do projeto principal.
