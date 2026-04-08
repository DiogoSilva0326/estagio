using System.Net.Http.Headers;
using System.Text.Json;
using Microsoft.Extensions.Options;

namespace ConfidantPostgreSQL.Integrations.CloudflareImages;

public sealed class CloudflareImagesClient : ICloudflareImagesClient
{
    private readonly HttpClient _http;
    private readonly CloudflareImagesOptions _opt;
    private static readonly JsonSerializerOptions _json = new(JsonSerializerDefaults.Web);

    public CloudflareImagesClient(HttpClient http, IOptions<CloudflareImagesOptions> opt)
    {
        _opt = opt.Value;
        if (!_opt.IsConfigured)
            throw new CloudflareImagesNotConfiguredException();

        _http = http;
        _http.BaseAddress = new Uri($"https://api.cloudflare.com/client/v4/accounts/{_opt.AccountId}/");
        _http.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", _opt.ApiToken);
    }

    public async Task<V2ListResponse> ListAsync(string? continuationToken, int perPage, CancellationToken ct)
    {
        var url = $"images/v2?per_page={perPage}";
        if (!string.IsNullOrEmpty(continuationToken))
            url += $"&continuation_token={Uri.EscapeDataString(continuationToken)}";

        using var res = await _http.GetAsync(url, ct);
        await EnsureSuccessAsync(res, ct);
        var env = await JsonSerializer.DeserializeAsync<Envelope<V2ListResponse>>(await res.Content.ReadAsStreamAsync(ct), _json, ct);
        return env?.Result ?? new V2ListResponse();
    }

    public async Task<ImageDetails> GetAsync(string imageId, CancellationToken ct)
    {
        using var res = await _http.GetAsync($"images/v1/{imageId}", ct);
        await EnsureSuccessAsync(res, ct);
        var env = await JsonSerializer.DeserializeAsync<Envelope<ImageDetails>>(await res.Content.ReadAsStreamAsync(ct), _json, ct);
        return env!.Result;
    }

    public async Task DeleteAsync(string imageId, CancellationToken ct)
    {
        using var res = await _http.DeleteAsync($"images/v1/{imageId}", ct);
        await EnsureSuccessAsync(res, ct);
    }

    public async Task<DirectUploadResponse> CreateDirectUploadAsync(TimeSpan? expiresIn, IDictionary<string, string>? metadata, CancellationToken ct)
    {
        var body = new Dictionary<string, object?>();
        if (expiresIn.HasValue) body["expiry"] = DateTime.UtcNow.Add(expiresIn.Value).ToString("o");
        if (metadata is not null) body["metadata"] = metadata;

        using var res = await _http.PostAsJsonAsync("images/v2/direct_upload", body, _json, ct);
        await EnsureSuccessAsync(res, ct);
        var env = await JsonSerializer.DeserializeAsync<Envelope<DirectUploadResponse>>(await res.Content.ReadAsStreamAsync(ct), _json, ct);
        return env!.Result;
    }

    public async Task<UploadResponse> UploadFileAsync(Stream fileStream, string fileName, string? id, IDictionary<string, string>? metadata, CancellationToken ct)
    {
        using var form = new MultipartFormDataContent();
        var fileContent = new StreamContent(fileStream);
        fileContent.Headers.ContentType = MediaTypeHeaderValue.Parse("application/octet-stream");
        form.Add(fileContent, "file", fileName);
        if (!string.IsNullOrWhiteSpace(id)) form.Add(new StringContent(id!), "id");
        if (metadata is not null)
        {
            var metaJson = JsonSerializer.Serialize(metadata, _json);
            form.Add(new StringContent(metaJson), "metadata");
        }

        using var res = await _http.PostAsync("images/v1", form, ct);
        await EnsureSuccessAsync(res, ct);
        var env = await JsonSerializer.DeserializeAsync<Envelope<UploadResponse>>(await res.Content.ReadAsStreamAsync(ct), _json, ct);
        return env!.Result;
    }

    public async Task<UploadResponse> UploadViaUrlAsync(string url, string? id, IDictionary<string, string>? metadata, CancellationToken ct)
    {
        using var form = new MultipartFormDataContent();
        form.Add(new StringContent(url), "url");
        if (!string.IsNullOrWhiteSpace(id)) form.Add(new StringContent(id!), "id");
        if (metadata is not null)
        {
            var metaJson = JsonSerializer.Serialize(metadata, _json);
            form.Add(new StringContent(metaJson), "metadata");
        }

        using var res = await _http.PostAsync("images/v1", form, ct);
        await EnsureSuccessAsync(res, ct);
        var env = await JsonSerializer.DeserializeAsync<Envelope<UploadResponse>>(await res.Content.ReadAsStreamAsync(ct), _json, ct);
        return env!.Result;
    }

    private static async Task EnsureSuccessAsync(HttpResponseMessage res, CancellationToken ct)
    {
        if (res.IsSuccessStatusCode)
        {
            return;
        }

        var body = res.Content is null
            ? null
            : await res.Content.ReadAsStringAsync(ct);

        throw new CloudflareImagesApiException(res.StatusCode, body);
    }

    private sealed record Envelope<T>(bool Success, T Result, object? Errors, object? Messages);

    public sealed record V2ListResponse(string? Continuation_Token, List<ImageItem> Images)
    {
        public V2ListResponse() : this(null, new()) { }
        public string? ContinuationToken => Continuation_Token;
    }

    public sealed record ImageItem(string Id, string? Filename, List<string>? Variants, Dictionary<string, string>? Meta);

    public sealed record ImageDetails(string Id, string? Filename, bool? Draft, List<string>? Variants, Dictionary<string, string>? Meta);

    public sealed record DirectUploadResponse(string Id, string UploadURL);

    public sealed record UploadResponse(string Id, string? Filename);
}
