using System.Linq;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace ConfidantPostgreSQL.Auth
{
    public class JwtFilter : IAuthorizationFilter
    {
        public void OnAuthorization(AuthorizationFilterContext context)
        {
            // Sempre aplica cultura (se houver header)
            RequestContext.ApplyCultureFromHeader(context.HttpContext.Request);

            // Permite endpoints marcados com [AllowAnonymous]
            if (context.ActionDescriptor.EndpointMetadata?.OfType<AllowAnonymousAttribute>().Any() == true)
            {
                return;
            }

            // Usa o seu JwtActor para validar
            if (!JwtActor.TryGetActorUserId(context.HttpContext.Request, out var userId))
            {
                // Se falhar, retorna 401 Unauthorized imediatamente
                context.Result = new UnauthorizedObjectResult(new { error = "token_invalid" });
                return;
            }

            // Guarda o ID para ser usado no Controller se for preciso
            context.HttpContext.Items["UserId"] = userId;
        }
    }
}
