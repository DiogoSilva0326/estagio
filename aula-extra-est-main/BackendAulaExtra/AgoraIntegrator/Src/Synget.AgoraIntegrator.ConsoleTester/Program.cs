using Synget.AgoraIntegrator;
using Synget.AgoraIntegrator.Models;

Console.WriteLine("=== Synget.AgoraIntegrator Test ===\n");

// Configuração de exemplo (substitua com as suas credenciais reais)
var config = new AgoraConfig
{
    Platform = AgoraPlatform.RTC,
    AppId = "70b8d85f57ea4c12af5d6d33b3265563",           // Substitua pelo seu App ID
    AppCertificate = "1565913de61d487cbfa10e02fc36051f", // Substitua pelo seu App Certificate
    TokenExpirationSeconds = 3600,
    
    // Para Chat (opcional)
    // ChatAppKey = "your-org#your-app",
    // ChatClientId = "your-client-id",
    // ChatClientSecret = "your-client-secret"
};

// Inicializar a plataforma
var platform = new AgoraPlatformManager();

Console.WriteLine("1. Initializing AgoraPlatformManager...");
bool success = platform.Initialize(config);

if (!success)
{
    Console.WriteLine($"   ❌ Failed: {platform.Agora?.Message}");
    Console.WriteLine("\n   Note: Replace 'your-app-id' and 'your-app-cert' with real Agora credentials.");
    return;
}

Console.WriteLine("   ✅ Initialized successfully!");

// Testar geração de token RTC
Console.WriteLine("\n2. Generating RTC Token...");
var rtcToken = platform.Agora!.RtcTokenGenerate("test-channel", uid: 0, AgoraRtcRole.Publisher);

if (rtcToken != null)
{
    Console.WriteLine($"   ✅ RTC Token generated!");
    Console.WriteLine($"      Channel: {rtcToken.ChannelName}");
    Console.WriteLine($"      UID: {rtcToken.Uid}");
    Console.WriteLine($"      Role: {rtcToken.Role}");
    Console.WriteLine($"      Expires: {rtcToken.ExpiresAt:yyyy-MM-dd HH:mm:ss}");
    Console.WriteLine($"      Token: {rtcToken.Token[..50]}...");
}
else
{
    Console.WriteLine($"   ❌ Failed: {platform.Agora.Message}");
}

// Testar geração de token RTM
Console.WriteLine("\n3. Generating RTM Token...");
var rtmToken = platform.Agora.RtmTokenGenerate("user-123");

if (rtmToken != null)
{
    Console.WriteLine($"   ✅ RTM Token generated!");
    Console.WriteLine($"      Account: {rtmToken.Account}");
    Console.WriteLine($"      Expires: {rtmToken.ExpiresAt:yyyy-MM-dd HH:mm:ss}");
    Console.WriteLine($"      Token: {rtmToken.Token[..50]}...");
}
else
{
    Console.WriteLine($"   ❌ Failed: {platform.Agora.Message}");
}

// Testar gestão de sessões
Console.WriteLine("\n4. Testing Session Management...");

var session = platform.Agora.SessionCreate("my-channel");
Console.WriteLine($"   ✅ Session created: {session?.SessionId}");

platform.Agora.SessionUserJoin("my-channel", "user-1");
platform.Agora.SessionUserJoin("my-channel", "user-2");
platform.Agora.SessionUserJoin("my-channel", "user-3");

var sessionInfo = platform.Agora.SessionGet("my-channel");
Console.WriteLine($"   Users in session: {sessionInfo?.Users.Count}");
Console.WriteLine($"   Peak users: {sessionInfo?.PeakUserCount}");
Console.WriteLine($"   Status: {sessionInfo?.Status}");

platform.Agora.SessionUserLeave("my-channel", "user-2");
Console.WriteLine($"   User-2 left. Users remaining: {platform.Agora.SessionGet("my-channel")?.Users.Count}");

// Listar todas as sessões
Console.WriteLine("\n5. Listing all sessions...");
var allSessions = platform.Agora.SessionGetList();
foreach (var s in allSessions)
{
    Console.WriteLine($"   - {s.ChannelName}: {s.Status} ({s.Users.Count} users)");
}

Console.WriteLine("\n=== Test Complete ===");
