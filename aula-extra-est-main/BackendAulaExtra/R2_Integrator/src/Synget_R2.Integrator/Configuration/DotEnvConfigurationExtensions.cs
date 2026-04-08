using Microsoft.Extensions.Configuration;

namespace Synget_R2.Integrator.Configuration;

public static class DotEnvConfigurationExtensions
{
    public static ConfigurationManager AddDotEnvIfPresent(this ConfigurationManager configuration, string filePath)
    {
        if (!File.Exists(filePath))
        {
            return configuration;
        }

        var values = new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase);

        foreach (var line in File.ReadAllLines(filePath))
        {
            var trimmedLine = line.Trim();

            if (string.IsNullOrWhiteSpace(trimmedLine) || trimmedLine.StartsWith('#'))
            {
                continue;
            }

            if (trimmedLine.StartsWith("export ", StringComparison.OrdinalIgnoreCase))
            {
                trimmedLine = trimmedLine[7..].Trim();
            }

            var separatorIndex = trimmedLine.IndexOf('=');

            if (separatorIndex <= 0)
            {
                continue;
            }

            var key = trimmedLine[..separatorIndex].Trim().Replace("__", ":");
            var value = trimmedLine[(separatorIndex + 1)..].Trim();

            if (value.Length >= 2 &&
                ((value.StartsWith('"') && value.EndsWith('"')) ||
                 (value.StartsWith('\'') && value.EndsWith('\''))))
            {
                value = value[1..^1];
            }

            values[key] = value
                .Replace("\\n", "\n")
                .Replace("\\r", "\r");
        }

        configuration.AddInMemoryCollection(values);
        return configuration;
    }
}