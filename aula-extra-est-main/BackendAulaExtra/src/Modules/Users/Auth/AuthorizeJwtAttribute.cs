using System;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Auth
{
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Method)]
    public class AuthorizeJwtAttribute : TypeFilterAttribute
    {
        public AuthorizeJwtAttribute() : base(typeof(JwtFilter)) { }
    }
}
