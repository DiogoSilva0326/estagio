using System;
using System.IO;
using System.Security.Cryptography;
using System.Text;

namespace ConfidantPostgreSQL.Modules.Users.Auth
{
    public static class PasswordHasher
    {
        private const int SaltSize = 16;
        private const int KeySize = 32;
        private const int Iterations = 100_000;

        // Chave AES do sistema antigo (ConfidantWebApi)
        private const string LegacyEncryptionKey = "E546C8DF278CD5931069B522E695D4F2";

        public static string Hash(string password)
        {
            using var rng = RandomNumberGenerator.Create();
            var salt = new byte[SaltSize];
            rng.GetBytes(salt);

            using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations, HashAlgorithmName.SHA256);
            var key = pbkdf2.GetBytes(KeySize);

            return Convert.ToBase64String(salt) + "." + Convert.ToBase64String(key);
        }

        public static bool Verify(string password, string storedPassword)
        {
            if (string.IsNullOrEmpty(storedPassword)) return false;

            // BCrypt format (e.g. $2a$12$...)
            if (storedPassword.StartsWith("$2", StringComparison.Ordinal))
            {
                try
                {
                    return BCrypt.Net.BCrypt.Verify(password, storedPassword);
                }
                catch
                {
                    return false;
                }
            }

            // Novo formato: salt.hash (com ponto)
            if (storedPassword.Contains('.'))
            {
                try
                {
                    var parts = storedPassword.Split('.');
                    if (parts.Length != 2) return false;
                    var salt = Convert.FromBase64String(parts[0]);
                    var key = Convert.FromBase64String(parts[1]);

                    using var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations, HashAlgorithmName.SHA256);
                    var keyToCheck = pbkdf2.GetBytes(KeySize);

                    return CryptographicOperations.FixedTimeEquals(keyToCheck, key);
                }
                catch
                {
                    // If parsing fails, treat as invalid (do not crash).
                    return false;
                }
            }

            // Formato legacy: AES encriptado (base64 sem ponto)
            return VerifyLegacyAes(password, storedPassword);
        }

        /// <summary>
        /// Verifica password usando desencriptação AES (formato legacy do ConfidantWebApi)
        /// </summary>
        private static bool VerifyLegacyAes(string password, string encryptedPassword)
        {
            try
            {
                var decrypted = DecryptLegacy(encryptedPassword);
                return string.Equals(password, decrypted, StringComparison.Ordinal);
            }
            catch
            {
                return false;
            }
        }

        private static string DecryptLegacy(string cipherText)
        {
            byte[] iv = new byte[16];
            byte[] buffer = Convert.FromBase64String(cipherText);

            using var aes = Aes.Create();
            aes.Key = Encoding.UTF8.GetBytes(LegacyEncryptionKey);
            aes.IV = iv;

            using var decryptor = aes.CreateDecryptor(aes.Key, aes.IV);
            using var ms = new MemoryStream(buffer);
            using var cryptoStream = new CryptoStream(ms, decryptor, CryptoStreamMode.Read);
            using var reader = new StreamReader(cryptoStream);

            return reader.ReadToEnd();
        }
    }
}
