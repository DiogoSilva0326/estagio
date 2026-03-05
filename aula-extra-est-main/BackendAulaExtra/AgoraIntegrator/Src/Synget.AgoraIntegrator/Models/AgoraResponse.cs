namespace Synget.AgoraIntegrator.Models
{
    /// <summary>
    /// Generic response wrapper for Agora API operations.
    /// </summary>
    /// <typeparam name="T">Type of the response data.</typeparam>
    public class AgoraResponse<T> where T : class
    {
        /// <summary>
        /// Whether the operation was successful.
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// Human-readable message about the operation result.
        /// </summary>
        public string Message { get; set; } = "";

        /// <summary>
        /// Error code (if applicable).
        /// </summary>
        public string? ErrorCode { get; set; }

        /// <summary>
        /// Response data.
        /// </summary>
        public T? Data { get; set; }

        /// <summary>
        /// Create a successful response.
        /// </summary>
        public static AgoraResponse<T> Ok(T data, string message = "")
        {
            return new AgoraResponse<T>
            {
                Success = true,
                Message = message,
                Data = data
            };
        }

        /// <summary>
        /// Create a failed response.
        /// </summary>
        public static AgoraResponse<T> Fail(string message, string? errorCode = null)
        {
            return new AgoraResponse<T>
            {
                Success = false,
                Message = message,
                ErrorCode = errorCode
            };
        }
    }

    /// <summary>
    /// Non-generic response for simple operations.
    /// </summary>
    public class AgoraResponse
    {
        /// <summary>
        /// Whether the operation was successful.
        /// </summary>
        public bool Success { get; set; }

        /// <summary>
        /// Human-readable message about the operation result.
        /// </summary>
        public string Message { get; set; } = "";

        /// <summary>
        /// Error code (if applicable).
        /// </summary>
        public string? ErrorCode { get; set; }

        /// <summary>
        /// Create a successful response.
        /// </summary>
        public static AgoraResponse Ok(string message = "")
        {
            return new AgoraResponse
            {
                Success = true,
                Message = message
            };
        }

        /// <summary>
        /// Create a failed response.
        /// </summary>
        public static AgoraResponse Fail(string message, string? errorCode = null)
        {
            return new AgoraResponse
            {
                Success = false,
                Message = message,
                ErrorCode = errorCode
            };
        }
    }
}
