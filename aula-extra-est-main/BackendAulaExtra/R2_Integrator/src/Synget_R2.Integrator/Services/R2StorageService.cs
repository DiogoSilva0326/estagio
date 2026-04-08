using System.Text;
using System.Text.RegularExpressions;
using System.Net;
using Amazon.Runtime;
using Amazon.S3;
using Amazon.S3.Model;
using Synget_R2.Integrator.Models;
using Synget_R2.Integrator.Options;
using Microsoft.Extensions.Options;
using Microsoft.Net.Http.Headers;

namespace Synget_R2.Integrator.Services;

public sealed class R2StorageService(
    IOptions<CloudflareR2Options> options,
    IR2CredentialResolver credentialResolver) : IR2StorageService
{
    private readonly CloudflareR2Options _settings = options.Value;

    public async Task<StoredUploadResult> UploadAsync(
        Stream content,
        string? key,
        string originalFileName,
        string? contentType,
        CancellationToken cancellationToken = default)
    {
        var objectKey = BuildObjectKey(key, originalFileName);
        var size = content.CanSeek ? content.Length : 0;
        using var s3Client = await CreateClientAsync(cancellationToken);

        var request = new PutObjectRequest
        {
            BucketName = _settings.BucketName,
            Key = objectKey,
            InputStream = content,
            AutoCloseStream = false,
            DisablePayloadSigning = true,
            DisableDefaultChecksumValidation = true,
            ContentType = string.IsNullOrWhiteSpace(contentType)
                ? "application/octet-stream"
                : contentType
        };

        var response = await s3Client.PutObjectAsync(request, cancellationToken);

        return new StoredUploadResult(
            objectKey,
            _settings.BucketName,
            request.ContentType,
            size,
            response.ETag);
    }

    public async Task<StoredFileDownload?> DownloadAsync(string key, CancellationToken cancellationToken = default)
    {
        try
        {
            var s3Client = await CreateClientAsync(cancellationToken);
            var response = await s3Client.GetObjectAsync(_settings.BucketName, key, cancellationToken);
            var fileName = Path.GetFileName(key);

            return new StoredFileDownload(
                new AmazonS3ResponseStream(response),
                string.IsNullOrWhiteSpace(fileName) ? key : fileName,
                string.IsNullOrWhiteSpace(response.Headers.ContentType)
                    ? "application/octet-stream"
                    : response.Headers.ContentType,
                response.LastModified,
                ParseETag(response.ETag));
        }
        catch (AmazonS3Exception exception) when (
            exception.StatusCode == HttpStatusCode.NotFound ||
            exception.ErrorCode == "NoSuchKey" ||
            exception.ErrorCode == "NotFound")
        {
            return null;
        }
    }

    public async Task<IReadOnlyCollection<StoredFileSummary>> ListFilesAsync(CancellationToken cancellationToken = default)
    {
        using var s3Client = await CreateClientAsync(cancellationToken);
        var response = await s3Client.ListObjectsV2Async(new ListObjectsV2Request
        {
            BucketName = _settings.BucketName
        }, cancellationToken);

        return response.S3Objects
            .Select(item => new StoredFileSummary(item.Key, item.Size, item.ETag, item.LastModified))
            .ToArray();
    }

    public async Task DeleteAsync(string key, CancellationToken cancellationToken = default)
    {
        using var s3Client = await CreateClientAsync(cancellationToken);
        await s3Client.DeleteObjectAsync(new DeleteObjectRequest
        {
            BucketName = _settings.BucketName,
            Key = key
        }, cancellationToken);
    }

    public async Task<BucketAccessResult> CanAccessBucketAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            using var s3Client = await CreateClientAsync(cancellationToken);
            await s3Client.ListObjectsV2Async(new ListObjectsV2Request
            {
                BucketName = _settings.BucketName,
                MaxKeys = 1
            }, cancellationToken);

            return new BucketAccessResult(true, "Ligação ao bucket R2 efetuada com sucesso.");
        }
        catch (AmazonS3Exception exception) when (
            exception.StatusCode == HttpStatusCode.Forbidden ||
            string.Equals(exception.ErrorCode, "AccessDenied", StringComparison.OrdinalIgnoreCase))
        {
            return new BucketAccessResult(
                false,
                "As credenciais autenticam no R2, mas não têm permissão para listar objetos neste bucket. Se o token for apenas de escrita, o upload pode funcionar mesmo com este aviso.");
        }
        catch (Exception exception)
        {
            return new BucketAccessResult(false, $"Falha ao aceder ao bucket R2: {exception.Message}");
        }
    }

    private async Task<IAmazonS3> CreateClientAsync(CancellationToken cancellationToken)
    {
        var resolvedCredentials = await credentialResolver.GetCredentialsAsync(cancellationToken);
        var credentials = new BasicAWSCredentials(resolvedCredentials.AccessKeyId, resolvedCredentials.SecretAccessKey);
        var config = new AmazonS3Config
        {
            ServiceURL = _settings.ServiceUrl,
            ForcePathStyle = true,
            AuthenticationRegion = "auto"
        };

        return new AmazonS3Client(credentials, config);
    }

    private static string BuildObjectKey(string? key, string originalFileName)
    {
        if (!string.IsNullOrWhiteSpace(key))
        {
            return key.TrimStart('/');
        }

        var safeFileName = SlugifyFileName(originalFileName);
        return $"uploads/{DateTime.UtcNow:yyyyMMddHHmmss}-{Guid.NewGuid():N}-{safeFileName}";
    }

    private static string SlugifyFileName(string fileName)
    {
        var extension = Path.GetExtension(fileName).ToLowerInvariant();
        var nameWithoutExtension = Path.GetFileNameWithoutExtension(fileName);
        var normalized = nameWithoutExtension.Normalize(System.Text.NormalizationForm.FormD);

        var builder = new StringBuilder(normalized.Length);
        foreach (var character in normalized)
        {
            var category = System.Globalization.CharUnicodeInfo.GetUnicodeCategory(character);
            if (category == System.Globalization.UnicodeCategory.NonSpacingMark)
            {
                continue;
            }

            if (char.IsLetterOrDigit(character))
            {
                builder.Append(char.ToLowerInvariant(character));
                continue;
            }

            builder.Append('-');
        }

        var slug = Regex.Replace(builder.ToString(), "-+", "-").Trim('-');
        if (string.IsNullOrWhiteSpace(slug))
        {
            slug = "ficheiro";
        }

        return string.IsNullOrWhiteSpace(extension) ? slug : $"{slug}{extension}";
    }

    private static EntityTagHeaderValue? ParseETag(string? eTag)
    {
        if (string.IsNullOrWhiteSpace(eTag))
        {
            return null;
        }

        if (EntityTagHeaderValue.TryParse(eTag, out var entityTag))
        {
            return entityTag;
        }

        var normalized = eTag.Trim('"');
        return new EntityTagHeaderValue($"\"{normalized}\"");
    }

    private sealed class AmazonS3ResponseStream(GetObjectResponse response) : Stream
    {
        private readonly Stream _innerStream = response.ResponseStream;

        public override bool CanRead => _innerStream.CanRead;

        public override bool CanSeek => _innerStream.CanSeek;

        public override bool CanWrite => _innerStream.CanWrite;

        public override long Length => _innerStream.Length;

        public override long Position
        {
            get => _innerStream.Position;
            set => _innerStream.Position = value;
        }

        public override void Flush() => _innerStream.Flush();

        public override int Read(byte[] buffer, int offset, int count) => _innerStream.Read(buffer, offset, count);

        public override long Seek(long offset, SeekOrigin origin) => _innerStream.Seek(offset, origin);

        public override void SetLength(long value) => _innerStream.SetLength(value);

        public override void Write(byte[] buffer, int offset, int count) => _innerStream.Write(buffer, offset, count);

        public override Task<int> ReadAsync(byte[] buffer, int offset, int count, CancellationToken cancellationToken) =>
            _innerStream.ReadAsync(buffer, offset, count, cancellationToken);

        public override ValueTask<int> ReadAsync(Memory<byte> buffer, CancellationToken cancellationToken = default) =>
            _innerStream.ReadAsync(buffer, cancellationToken);

        public override Task WriteAsync(byte[] buffer, int offset, int count, CancellationToken cancellationToken) =>
            _innerStream.WriteAsync(buffer, offset, count, cancellationToken);

        public override ValueTask WriteAsync(ReadOnlyMemory<byte> buffer, CancellationToken cancellationToken = default) =>
            _innerStream.WriteAsync(buffer, cancellationToken);

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                response.Dispose();
            }

            base.Dispose(disposing);
        }

        public override ValueTask DisposeAsync()
        {
            response.Dispose();
            return base.DisposeAsync();
        }
    }
}
