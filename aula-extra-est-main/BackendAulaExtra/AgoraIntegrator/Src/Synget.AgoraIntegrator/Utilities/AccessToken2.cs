namespace Synget.AgoraIntegrator.Utilities
{
    using System;
    using System.Collections.Generic;
    using System.Security.Cryptography;
    using System.Text;

    /// <summary>
    /// AccessToken2 generator for Agora RTM.
    /// Ported from Agora's reference implementations.
    /// Supports RTM (Real-Time Messaging) token generation.
    /// </summary>
    public class AccessToken2
    {
        private const int Version = 3;

        private readonly string _appId;
        private readonly string _appCertificate;
        private readonly uint _expireTs;
        private readonly Dictionary<int, byte[]> _services = new();

        public AccessToken2(string appId, string appCertificate, uint expireTs)
        {
            _appId = appId;
            _appCertificate = appCertificate;
            _expireTs = expireTs;
        }

        public void AddService(ServiceRtm service)
        {
            _services[1] = service.Build();
        }

        public string Build()
        {
            var appIdBytes = Encoding.UTF8.GetBytes(_appId);
            var tokenBuffer = new List<byte>();

            // Version
            tokenBuffer.Add(Version);

            // App ID length (4 bytes, big-endian)
            tokenBuffer.AddRange(BitConverter.GetBytes(appIdBytes.Length));
            if (BitConverter.IsLittleEndian) tokenBuffer.Reverse(tokenBuffer.Count - 4, 4);

            // App ID
            tokenBuffer.AddRange(appIdBytes);

            // Expire timestamp (4 bytes, big-endian)
            var expireBytes = BitConverter.GetBytes(_expireTs);
            if (BitConverter.IsLittleEndian) Array.Reverse(expireBytes);
            tokenBuffer.AddRange(expireBytes);

            // Service count (1 byte)
            tokenBuffer.Add((byte)_services.Count);

            // Services
            foreach (var kvp in _services)
            {
                tokenBuffer.Add((byte)kvp.Key); // Service ID
                var serviceData = kvp.Value;
                var lengthBytes = BitConverter.GetBytes((ushort)serviceData.Length);
                if (BitConverter.IsLittleEndian) Array.Reverse(lengthBytes);
                tokenBuffer.AddRange(lengthBytes);
                tokenBuffer.AddRange(serviceData);
            }

            // Sign with HMAC
            var signature = SignToken(tokenBuffer.ToArray());
            tokenBuffer.AddRange(signature);

            return "agora_" + Convert.ToBase64String(tokenBuffer.ToArray()).Replace("+", "-").Replace("/", "_").TrimEnd('=');
        }

        private byte[] SignToken(byte[] message)
        {
            var certBytes = Encoding.UTF8.GetBytes(_appCertificate);
            using var hmac = new HMACSHA256(certBytes);
            return hmac.ComputeHash(message);
        }
    }

    /// <summary>
    /// RTM service for token generation.
    /// </summary>
    public class ServiceRtm
    {
        private const int ServiceId = 1;
        private readonly string _account;
        private readonly Dictionary<int, uint> _privileges = new();

        public ServiceRtm(string account)
        {
            _account = account;
        }

        public void AddPrivilege(int privilege, uint expireTs)
        {
            _privileges[privilege] = expireTs;
        }

        public byte[] Build()
        {
            var buffer = new List<byte>();

            // Service ID
            buffer.Add(ServiceId);

            // Account length (2 bytes, big-endian)
            var accountBytes = Encoding.UTF8.GetBytes(_account);
            var accountLenBytes = BitConverter.GetBytes((ushort)accountBytes.Length);
            if (BitConverter.IsLittleEndian) Array.Reverse(accountLenBytes);
            buffer.AddRange(accountLenBytes);

            // Account
            buffer.AddRange(accountBytes);

            // Privilege count (1 byte)
            buffer.Add((byte)_privileges.Count);

            // Privileges
            foreach (var kvp in _privileges)
            {
                buffer.Add((byte)kvp.Key); // Privilege ID
                var expireBytes = BitConverter.GetBytes(kvp.Value);
                if (BitConverter.IsLittleEndian) Array.Reverse(expireBytes);
                buffer.AddRange(expireBytes);
            }

            return buffer.ToArray();
        }
    }

    /// <summary>
    /// RTM privilege constants.
    /// </summary>
    public static class PrivilegesRtm
    {
        public const int Login = 1;
    }
}
