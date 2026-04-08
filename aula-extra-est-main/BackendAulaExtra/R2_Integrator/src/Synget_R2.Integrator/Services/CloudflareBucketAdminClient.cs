using System.Net.Http.Headers;
using System.Text.Json;
using Synget_R2.Integrator.Models;
using Synget_R2.Integrator.Options;
using Microsoft.Extensions.Options;

namespace Synget_R2.Integrator.Services;

public sealed class CloudflareBucketAdminClient(
    HttpClient httpClient,
    IOptions<CloudflareR2Options> options) : ICloudflareBucketAdminClient
{
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task<BucketApiTokenResult> CheckBucketAsync(CancellationToken cancellationToken = default)
    {
        var settings = options.Value;

        if (string.IsNullOrWhiteSpace(settings.ApiToken))
        {
            return new BucketApiTokenResult(false, false, false, "API Token não configurado.");
        }

        var verifyResult = await VerifyTokenAsync(settings.ApiToken, cancellationToken);

        if (!verifyResult.Success)
        {
            return new BucketApiTokenResult(
                true,
                false,
                false,
                verifyResult.Message);
        }

        using var request = new HttpRequestMessage(
            HttpMethod.Get,
            $"https://api.cloudflare.com/client/v4/accounts/{settings.AccountId}/r2/buckets");

        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", settings.ApiToken);

        using var response = await httpClient.SendAsync(request, cancellationToken);
        var payload = await response.Content.ReadAsStringAsync(cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            if (response.StatusCode == System.Net.HttpStatusCode.Forbidden)
            {
                return new BucketApiTokenResult(
                    true,
                    true,
                    false,
                    "API Token válido, mas sem permissão para listar buckets pela API administrativa. Isto é esperado para tokens R2 limitados a um bucket ou a operações de objeto.");
            }

            return new BucketApiTokenResult(
                true,
                false,
                false,
                $"Falha ao validar API Token: {(int)response.StatusCode} {response.ReasonPhrase}. {payload}");
        }

        var result = JsonSerializer.Deserialize<CloudflareListBucketsResponse>(payload, JsonOptions);
        var bucketFound = result?.Result?.Buckets?.Any(bucket =>
            string.Equals(bucket.Name, settings.BucketName, StringComparison.Ordinal)) == true;

        return new BucketApiTokenResult(
            true,
            true,
            bucketFound,
            bucketFound
                ? "API Token válido e bucket encontrado na conta Cloudflare."
                : "API Token válido, mas o bucket configurado não foi encontrado.");
    }

    private async Task<(bool Success, string Message)> VerifyTokenAsync(string apiToken, CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(
            HttpMethod.Get,
            "https://api.cloudflare.com/client/v4/user/tokens/verify");

        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiToken);

        using var response = await httpClient.SendAsync(request, cancellationToken);
        var payload = await response.Content.ReadAsStringAsync(cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            return (false, $"ApiToken inválido ou não verificável: {(int)response.StatusCode} {response.ReasonPhrase}. {payload}");
        }

        return (true, "API Token verificado com sucesso.");
    }

    private sealed record CloudflareListBucketsResponse(CloudflareBucketsResult? Result);

    private sealed record CloudflareBucketsResult(IReadOnlyCollection<CloudflareBucket>? Buckets);

    private sealed record CloudflareBucket(string Name);
}
