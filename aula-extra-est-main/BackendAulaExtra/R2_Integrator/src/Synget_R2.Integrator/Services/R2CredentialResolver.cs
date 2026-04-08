using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Synget_R2.Integrator.Models;
using Synget_R2.Integrator.Options;
using Microsoft.Extensions.Options;

namespace Synget_R2.Integrator.Services;

public sealed class R2CredentialResolver(
    HttpClient httpClient,
    IOptions<CloudflareR2Options> options) : IR2CredentialResolver
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);
    private readonly CloudflareR2Options _settings = options.Value;
    private ResolvedR2Credentials? _cachedCredentials;

    public async Task<ResolvedR2Credentials> GetCredentialsAsync(CancellationToken cancellationToken = default)
    {
        if (_cachedCredentials is not null)
        {
            return _cachedCredentials;
        }

        if (_settings.HasStaticS3Credentials)
        {
            _cachedCredentials = new ResolvedR2Credentials(
                _settings.AccessKeyId!,
                _settings.SecretAccessKey!,
                "static-s3-credentials");

            return _cachedCredentials;
        }

        if (string.IsNullOrWhiteSpace(_settings.ApiToken))
        {
            throw new InvalidOperationException("Não existem credenciais S3 nem ApiToken para derivar autenticação ao R2.");
        }

        using var request = new HttpRequestMessage(HttpMethod.Get, "https://api.cloudflare.com/client/v4/user/tokens/verify");
        request.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", _settings.ApiToken);

        using var response = await httpClient.SendAsync(request, cancellationToken);
        var payload = await response.Content.ReadAsStringAsync(cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException(
                $"Falha ao verificar o ApiToken na Cloudflare: {(int)response.StatusCode} {response.ReasonPhrase}. {payload}");
        }

        var verifyResponse = JsonSerializer.Deserialize<VerifyTokenResponse>(payload, JsonOptions);
        var accessKeyId = verifyResponse?.Result?.Id;

        if (string.IsNullOrWhiteSpace(accessKeyId))
        {
            throw new InvalidOperationException("A Cloudflare não devolveu o identificador do token necessário para derivar as credenciais S3.");
        }

        var secretAccessKey = ComputeSha256Hex(_settings.ApiToken);
        _cachedCredentials = new ResolvedR2Credentials(accessKeyId, secretAccessKey, "derived-from-api-token");
        return _cachedCredentials;
    }

    private static string ComputeSha256Hex(string value)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(value));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }

    private sealed record VerifyTokenResponse(VerifyTokenResult? Result);

    private sealed record VerifyTokenResult(string? Id);
}