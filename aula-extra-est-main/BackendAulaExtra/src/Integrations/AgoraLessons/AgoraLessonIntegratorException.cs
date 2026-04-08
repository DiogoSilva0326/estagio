using System;
using System.Net;

namespace ConfidantPostgreSQL.Integrations.AgoraLessons
{
    public sealed class AgoraLessonIntegratorException : Exception
    {
        public AgoraLessonIntegratorException(string message, HttpStatusCode? statusCode = null)
            : base(message)
        {
            StatusCode = statusCode;
        }

        public HttpStatusCode? StatusCode { get; }
    }
}