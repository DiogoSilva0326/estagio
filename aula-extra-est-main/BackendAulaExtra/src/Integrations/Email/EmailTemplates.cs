using System;
using System.Text;

namespace ConfidantPostgreSQL.Integrations.Email
{
    /// <summary>
    /// Predefined HTML templates for branded transactional emails.
    /// </summary>
    public static class EmailTemplates
    {
        // Default Jacurvas logo (white mark) hosted on Cloudflare Images
        private const string DefaultJacurvasLogoUrl = "https://imagedelivery.net/C-VroDg79TCDHOj10tTTTQ/cbed5fe5-b562-4fcb-306c-c1ae0016b800/public";

        /// <summary>
        /// Jacurvas branded HTML email wrapper.
        /// </summary>
        public static string Jacurvas(string subject, string plainBody, string? logoUrl = null, string? footerNote = null)
        {
            string Escape(string? s) => (s ?? string.Empty)
                .Replace("&", "&amp;")
                .Replace("<", "&lt;")
                .Replace(">", "&gt;")
                .Replace("\"", "&quot;")
                .Replace("'", "&#39;");

            var safeSubject = Escape(subject);
            var safeBody = Escape(plainBody)
                .Replace("\r\n", "\n")
                .Replace("\n", "<br/>");
            var safeFooter = Escape(footerNote);

            var sb = new StringBuilder();

            sb.Append("<!DOCTYPE html>");
            sb.Append("<html lang=\"pt\"><head><meta charset=\"utf-8\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            sb.Append("<title>" + safeSubject + "</title>");
            sb.Append(@"<style>
                body { margin:0; padding:0; background:#000000; color:#f6f6f6; }
                img { border:0; line-height:100%; outline:none; text-decoration:none; }
                table { border-collapse:collapse !important; }
                .wrapper { width:100%; background:#000000; padding:24px 0; }
                .container { width:100%; max-width:640px; margin:0 auto; background:#0a0a0a; border-radius:12px; overflow:hidden; box-shadow:0 6px 24px rgba(0,0,0,.45); border:1px solid #111; }
                .header { background:linear-gradient(135deg,#000000 0%, #0a0a0a 100%); padding:28px 24px; text-align:center; }
                .brand { font-family:Inter, Roboto, Arial, sans-serif; font-weight:700; font-size:18px; letter-spacing:.4px; color:#f6f6f6; }
                .logo { width:120px; height:auto; opacity:1; display:block; margin:0 auto 10px; filter:drop-shadow(0 2px 8px rgba(0,0,0,.6)); }
                .content { padding:24px 28px; font-family:Inter, Roboto, Arial, sans-serif; line-height:1.6; color:#e6e6e6; }
                h1 { margin:0 0 12px; font-size:20px; color:#ffffff; letter-spacing:.2px; }
                p { margin:0 0 12px; font-size:15px; }
                .panel { background:#0f0f0f; border:1px solid #1e1e1e; padding:16px 18px; border-radius:10px; }
                .divider { height:1px; background:#1a1a1a; margin:20px 0; border:0; }
                .footer { padding:18px 24px; font-size:12px; color:#a9a9a9; text-align:center; border-top:1px solid #141414; }
                a { color:#e7b10a; text-decoration:none; }
                @media (max-width: 480px) { .content { padding:18px 16px; } }
            </style></head>");
            sb.Append("<body>");
            sb.Append("<div class=\"wrapper\"><div class=\"container\">");

            // Header with optional logo
            sb.Append("<div class=\"header\">");
            string? effectiveLogo = string.IsNullOrWhiteSpace(logoUrl) ? DefaultJacurvasLogoUrl : logoUrl;
            if (!string.IsNullOrWhiteSpace(effectiveLogo))
            {
                sb.Append("<img class=\"logo\" alt=\"Jacurvas\" src=\"" + effectiveLogo!.Trim() + "\"/>");
            }
            sb.Append("<div class=\"brand\">JACURVAS • Motorcycles</div>");
            sb.Append("</div>");

            // Body
            sb.Append("<div class=\"content\">");
            sb.Append("<h1>" + safeSubject + "</h1>");
            sb.Append("<div class=\"panel\">");
            sb.Append("<p>" + safeBody + "</p>");
            sb.Append("</div>");
            sb.Append("<hr class=\"divider\"/>");
            sb.Append("<p style=\"font-size:13px;color:#b9b9b9;\">Se tiveres alguma questão adicional, responde a este email — estamos aqui para ajudar.</p>");
            sb.Append("</div>");

            // Footer
            sb.Append("<div class=\"footer\">");
            if (!string.IsNullOrWhiteSpace(safeFooter))
                sb.Append("<div>" + safeFooter + "</div>");
            sb.Append("<div>© " + DateTime.UtcNow.Year + " Jacurvas • Todos os direitos reservados.</div>");
            sb.Append("</div>");

            sb.Append("</div></div>");
            sb.Append("</body></html>");

            return sb.ToString();
        }
    }
}
