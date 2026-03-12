using Synget.AgoraIntegrator.Models;

namespace Synget.AgoraIntegrator
{
    /// <summary>
    /// Main entry point for Agora integration.
    /// Manages the lifecycle and provides access to the active Agora provider.
    /// Similar to ERPPlatform in the ERP integrator pattern.
    /// </summary>
    public class AgoraPlatformManager
    {
        /// <summary>
        /// The active Agora provider instance.
        /// </summary>
        public IAgora? Agora { get; private set; }

        /// <summary>
        /// Initialize the Agora platform with the provided configuration.
        /// </summary>
        /// <param name="config">Configuration for the Agora provider.</param>
        /// <returns>True on successful initialization.</returns>
        /// <exception cref="ArgumentNullException">When config is null.</exception>
        /// <exception cref="NotImplementedException">When platform type is not supported.</exception>
        public bool Initialize(AgoraConfig config)
        {
            if (config is null)
                throw new ArgumentNullException(nameof(config));

            // Currently only one implementation, but structure supports multiple
            Agora = config.Platform switch
            {
                AgoraPlatform.RTC => new AgoraRTC(),
                AgoraPlatform.RTM => new AgoraRTC(), // Same implementation supports both
                _ => throw new NotImplementedException($"Platform {config.Platform} is not implemented.")
            };

            return Agora.Initialize(config);
        }

        /// <summary>
        /// Dispose and cleanup the current Agora provider.
        /// </summary>
        public void Dispose()
        {
            Agora = null;
        }
    }
}
