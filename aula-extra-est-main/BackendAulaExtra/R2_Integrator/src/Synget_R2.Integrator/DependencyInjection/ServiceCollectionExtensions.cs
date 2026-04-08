using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Synget_R2.Integrator.Options;
using Synget_R2.Integrator.Services;

namespace Synget_R2.Integrator.DependencyInjection;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddSyngetR2Integrator(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services
            .AddOptions<CloudflareR2Options>()
            .Bind(configuration.GetSection(CloudflareR2Options.SectionName))
            .ValidateDataAnnotations()
            .Validate(
                static options =>
                    !string.IsNullOrWhiteSpace(options.AccountId) &&
                    !string.IsNullOrWhiteSpace(options.BucketName) &&
                    (options.HasStaticS3Credentials || !string.IsNullOrWhiteSpace(options.ApiToken)),
                "CloudflareR2:AccountId, BucketName e (`AccessKeyId`+`SecretAccessKey` ou `ApiToken`) são obrigatórios.")
            .ValidateOnStart();

        services.AddHttpClient<ICloudflareBucketAdminClient, CloudflareBucketAdminClient>();
        services.AddHttpClient<IR2CredentialResolver, R2CredentialResolver>();
        services.AddSingleton<IR2StorageService, R2StorageService>();

        return services;
    }
}