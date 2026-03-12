# AgoraAPI Backend - Módulo Reutilizável

Este módulo contém toda a lógica de backend necessária para integração com Agora RTC, facilitando a reutilização em outros projetos C# ASP.NET Core.

## Funcionalidades

✅ Geração de tokens RTC do Agora (segurança)
✅ Integração com Netless Whiteboard (criação de salas e tokens)
✅ Caching de UUIDs de salas por canal (evita duplicação)
✅ Arquitetura MVC com Dependency Injection
✅ Suporte a CORS para aplicações web

## Estrutura

```
agoraAPI/
├── Models/
│   ├── AppConfig.cs                  # Configuração (env vars)
│   ├── RoomResponse.cs              # Response do Netless
│   ├── RtcTokenRequest.cs           # Request de token RTC
│   └── WhiteboardTokenRequest.cs    # Request de token whiteboard
├── Services/
│   ├── RtcTokenService.cs           # Geração de tokens RTC
│   └── WhiteboardService.cs         # Workflow completo do whiteboard
├── Repository/
│   └── WhiteboardRoomRepository.cs  # Cache de UUIDs de salas
└── Controllers/
    └── TokenController.cs           # Endpoints HTTP
```

## Como Usar em Outro Projeto

### 1. Copiar a Pasta

Copie a pasta `agoraAPI/` inteira para o seu projeto ASP.NET Core.

### 2. Atualizar o Program.cs

```csharp
using AgoraBackend.agoraAPI.Models;
using AgoraBackend.agoraAPI.Services;
using AgoraBackend.agoraAPI.Repository;

var builder = WebApplication.CreateBuilder(args);

// Registrar configuração
builder.Services.AddSingleton<AppConfig>(sp =>
{
    var agoraAppId = Environment.GetEnvironmentVariable("AGORA_APP_ID") ?? "";
    var agoraAppCertificate = Environment.GetEnvironmentVariable("AGORA_APP_CERTIFICATE") ?? "";
    var netlessSdkToken = Environment.GetEnvironmentVariable("NETLESS_SDK_TOKEN") ?? "";
    var netlessRegion = Environment.GetEnvironmentVariable("NETLESS_REGION") ?? "us-sv";

    if (string.IsNullOrWhiteSpace(agoraAppId))
        throw new InvalidOperationException("missing AGORA_APP_ID");
    if (string.IsNullOrWhiteSpace(agoraAppCertificate))
        throw new InvalidOperationException("missing AGORA_APP_CERTIFICATE");
    if (string.IsNullOrWhiteSpace(netlessSdkToken))
        throw new InvalidOperationException("missing NETLESS_SDK_TOKEN");

    return new AppConfig(agoraAppId, agoraAppCertificate, netlessSdkToken, netlessRegion);
});

// Registrar serviços
builder.Services.AddHttpClient("netless");
builder.Services.AddSingleton<IRtcTokenService, RtcTokenService>();
builder.Services.AddSingleton<IWhiteboardRoomRepository, WhiteboardRoomRepository>();
builder.Services.AddSingleton<IWhiteboardService, WhiteboardService>();

// Adicionar controllers
builder.Services.AddControllers();

// CORS (se necessário)
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
        policy.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod());
});

var app = builder.Build();

app.UseCors("AllowAll");
app.MapControllers();

app.Run();
```

### 3. Configurar Variáveis de Ambiente

Crie um arquivo `.env` na raiz do projeto:

```env
AGORA_APP_ID=your_agora_app_id
AGORA_APP_CERTIFICATE=your_agora_app_certificate
NETLESS_SDK_TOKEN=your_netless_sdk_token
NETLESS_REGION=us-sv
PORT=8082
```

Ou configure diretamente no sistema/launchSettings.json.

### 4. Adicionar Dependências no .csproj

```xml
<ItemGroup>
  <PackageReference Include="AgoraIO.Media" Version="4.3.1" />
  <PackageReference Include="DotNetEnv" Version="3.1.1" />
</ItemGroup>
```

### 5. Executar

```bash
dotnet restore
dotnet build
dotnet run
```

O servidor estará disponível em `http://localhost:8082`.

## Endpoints Disponíveis

### 1. Gerar Token RTC

```http
POST /fetch_rtc_token
Content-Type: application/json

{
  "uid": 123,
  "channelName": "meu-canal",
  "role": 1
}

Response:
{
  "token": "006abc123...",
  "code": "200"
}
```

**Parâmetros:**
- `uid` (uint): ID único do usuário (1 - 4294967295)
- `channelName` (string): Nome do canal
- `role` (uint): 1 = Publisher, 2 = Subscriber

### 2. Gerar Token Whiteboard

```http
POST /fetch_whiteboard_token
Content-Type: application/json

{
  "uid": 123,
  "channelName": "meu-canal"
}

Response:
{
  "uuid": "room-uuid-123",
  "token": "NETLESSROOM_..."
}
```

**Nota:** Usuários no mesmo `channelName` receberão o mesmo `uuid` (sala compartilhada).

### 3. Health Check

```http
GET /

Response: "AgoraBackend OK"
```

## Arquitetura

### Models
- **AppConfig**: Record imutável com configurações do ambiente
- **RtcTokenRequest**: DTO para requisições de token RTC
- **WhiteboardTokenRequest**: DTO para requisições de token whiteboard
- **RoomResponse**: DTO para resposta da API Netless

### Services
- **IRtcTokenService**: Interface para geração de tokens RTC
- **RtcTokenService**: Implementação usando AgoraIO.Media
- **IWhiteboardService**: Interface para workflow do whiteboard
- **WhiteboardService**: Orquestra repositório + Netless API

### Repository
- **IWhiteboardRoomRepository**: Interface para gerenciar UUIDs
- **WhiteboardRoomRepository**: Cache thread-safe usando ConcurrentDictionary

### Controllers
- **TokenController**: Endpoints REST com injeção de dependências

## Benefícios da Arquitetura

1. **Separação de Responsabilidades**: Cada camada tem uma responsabilidade clara
2. **Testabilidade**: Interfaces permitem mocking fácil para testes
3. **Dependency Injection**: Reduz acoplamento e facilita manutenção
4. **Thread-Safe**: ConcurrentDictionary garante acesso seguro ao cache
5. **Reutilizável**: Copie a pasta `agoraAPI/` para qualquer projeto ASP.NET Core

## Customização

### Alterar Porta do Servidor

No `Program.cs`:

```csharp
var port = Environment.GetEnvironmentVariable("PORT");
if (int.TryParse(port, out var portNumber) && portNumber > 0)
{
    app.Urls.Add($"http://localhost:{portNumber}");
}
else
{
    app.Urls.Add("http://localhost:8082");
}
```

### Adicionar Autenticação

Adicione middleware de autenticação no `Program.cs`:

```csharp
builder.Services.AddAuthentication(/* ... */);
app.UseAuthentication();
app.UseAuthorization();
```

### Configurar CORS Específico

```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("MyPolicy", policy =>
        policy.WithOrigins("https://meusite.com")
              .AllowAnyHeader()
              .AllowAnyMethod());
});
```

## Troubleshooting

### "missing AGORA_APP_ID"
- Verifique se as variáveis de ambiente estão configuradas
- Use DotNetEnv ou configure no launchSettings.json

### "Unable to resolve service for type 'System.String'"
- Certifique-se de que `AppConfig` está registrado como singleton
- Verifique se as classes do agoraAPI recebem `AppConfig` (não strings diretas)

### Erro CORS
- Adicione `app.UseCors("AllowAll");` antes de `app.MapControllers();`
- Configure a política CORS adequadamente

## Licença

Este módulo é parte do projeto AgoraAPI e segue a mesma licença do projeto principal.
