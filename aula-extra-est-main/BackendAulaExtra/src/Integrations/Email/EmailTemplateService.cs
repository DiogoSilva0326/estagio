using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace ConfidantPostgreSQL.Integrations.Email
{
    public interface IEmailTemplateService
    {
        Task<bool> SendPasswordResetEmailAsync(string toEmail, string resetToken, string? culture = "pt-PT", CancellationToken cancellationToken = default);
        Task<bool> SendEmailVerificationAsync(string toEmail, string verificationToken, string? culture = "pt-PT", CancellationToken cancellationToken = default);
        Task<bool> SendContactFormEmailAsync(string fromEmail, string subject, string message, string? culture = "pt-PT", CancellationToken cancellationToken = default);
        Task<bool> SendInvoiceLinkEmailAsync(string toEmail, string orderNumber, string invoicePdfUrl, string? culture = "pt-PT", CancellationToken cancellationToken = default);
        Task<bool> SendOrderConfirmationEmailAsync(OrderConfirmationEmailDto order, CancellationToken cancellationToken = default);
    }

    public class OrderConfirmationEmailDto
    {
        public string ToEmail { get; set; } = string.Empty;
        public string CustomerName { get; set; } = string.Empty;
        public string OrderNumber { get; set; } = string.Empty;
        public decimal GrandTotal { get; set; }
        public string Currency { get; set; } = "EUR";
        public string? InvoicePdfUrl { get; set; }
        public string? TrackingUrl { get; set; }
        public string? TrackingNumber { get; set; }
        public string? Carrier { get; set; }
        public List<OrderItemEmailDto> Items { get; set; } = new();
        public string? ShippingAddress { get; set; }
        public string? Culture { get; set; } = "pt-PT";
    }

    public class OrderItemEmailDto
    {
        public string ProductName { get; set; } = string.Empty;
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal TotalPrice { get; set; }
    }

    public class EmailTemplateService : IEmailTemplateService
    {
        private readonly IPostmarkService _postmarkService;
        private readonly string _siteUrl;

        public EmailTemplateService(IPostmarkService postmarkService)
        {
            _postmarkService = postmarkService;
            _siteUrl = Environment.GetEnvironmentVariable("SITE_URL") ?? "https://jacurvas.com";
        }

        public async Task<bool> SendPasswordResetEmailAsync(string toEmail, string resetToken, string? culture = "pt-PT", CancellationToken cancellationToken = default)
        {
            var resetLink = $"{_siteUrl}/redefinir-password?token={Uri.EscapeDataString(resetToken)}";
            
            string subject = culture == "en-US" 
                ? "Password Reset Request" 
                : "Pedido de Recuperação de Palavra-passe";

            string plainBody = culture == "en-US"
                ? $"You have requested to reset your password.\n\nClick here to reset: {resetLink}\n\nThis link expires in 24 hours.\n\nIf you did not request this, please ignore this email."
                : $"Recebemos um pedido para recuperar a sua palavra-passe.\n\nClique aqui para recuperar: {resetLink}\n\nEste link expira em 24 horas.\n\nSe não solicitou esta recuperação, ignore este email.";

            var htmlBody = EmailTemplates.Jacurvas(subject, plainBody);

            var dto = new EmailSenderDto
            {
                To = toEmail,
                Subject = subject,
                TextBody = plainBody,
                HtmlBody = htmlBody,
                Tag = "password-reset",
                MessageStream = "outbound"
            };

            return await _postmarkService.SendEmailAsync(dto, cancellationToken);
        }

        public async Task<bool> SendEmailVerificationAsync(string toEmail, string verificationToken, string? culture = "pt-PT", CancellationToken cancellationToken = default)
        {
            var verificationLink = $"{_siteUrl}/verificar-email?token={Uri.EscapeDataString(verificationToken)}";
            
            string subject = culture == "en-US" 
                ? "Verify Your Email Address" 
                : "Confirma o teu email";

            string plainBody = culture == "en-US"
                ? $"Welcome to Jacurvas!\n\nThank you for registering. Please verify your email by clicking the link below:\n\n{verificationLink}\n\nThis link expires in 7 days.\n\nIf you did not create this account, please ignore this email."
                : $"Bem-vindo à Jacurvas!\n\nObrigado por te registares. Por favor, confirma o teu email clicando no link abaixo:\n\n{verificationLink}\n\nEste link expira em 7 dias.\n\nSe não criaste esta conta, ignora este email.";

            var htmlBody = EmailTemplates.Jacurvas(subject, plainBody);

            var dto = new EmailSenderDto
            {
                To = toEmail,
                Subject = subject,
                TextBody = plainBody,
                HtmlBody = htmlBody,
                Tag = "email-verification",
                MessageStream = "outbound"
            };

            return await _postmarkService.SendEmailAsync(dto, cancellationToken);
        }

        public async Task<bool> SendContactFormEmailAsync(string fromEmail, string subject, string message, string? culture = "pt-PT", CancellationToken cancellationToken = default)
        {
            var adminEmail = Environment.GetEnvironmentVariable("ADMIN_EMAIL") ?? "admin@jacurvas.com";
            
            string plainBody = $"Nova mensagem de contacto\n\nDe: {fromEmail}\nAssunto: {subject}\n\n{message}\n\n---\nEsta mensagem foi enviada através do formulário de contacto do site Jacurvas.";

            var htmlBody = EmailTemplates.Jacurvas($"Contacto: {subject}", plainBody);

            var dto = new EmailSenderDto
            {
                To = adminEmail,
                Subject = $"Contacto: {subject}",
                TextBody = plainBody,
                HtmlBody = htmlBody,
                Tag = "contact-form",
                MessageStream = "outbound"
            };

            return await _postmarkService.SendEmailAsync(dto, cancellationToken);
        }

        public async Task<bool> SendInvoiceLinkEmailAsync(string toEmail, string orderNumber, string invoicePdfUrl, string? culture = "pt-PT", CancellationToken cancellationToken = default)
        {
            string subject = culture == "en-US"
                ? $"Invoice PDF for order {orderNumber}"
                : $"Fatura PDF da encomenda {orderNumber}";

            string plainBody = culture == "en-US"
                ? $"Your invoice is ready.\n\nOrder: {orderNumber}\nPDF: {invoicePdfUrl}\n"
                : $"A sua fatura está disponível.\n\nEncomenda: {orderNumber}\nPDF: {invoicePdfUrl}\n";

            var htmlBody = EmailTemplates.Jacurvas(subject, plainBody);

            var dto = new EmailSenderDto
            {
                To = toEmail,
                Subject = subject,
                TextBody = plainBody,
                HtmlBody = htmlBody,
                Tag = "invoice-pdf",
                MessageStream = "outbound"
            };

            return await _postmarkService.SendEmailAsync(dto, cancellationToken);
        }

        public async Task<bool> SendOrderConfirmationEmailAsync(OrderConfirmationEmailDto order, CancellationToken cancellationToken = default)
        {
            var culture = order.Culture ?? "pt-PT";
            var isPT = !string.Equals(culture, "en-US", StringComparison.OrdinalIgnoreCase);
            
            string subject = isPT 
                ? $"Confirmação da Encomenda #{order.OrderNumber}" 
                : $"Order Confirmation #{order.OrderNumber}";

            // Build items list
            var itemsHtml = "";
            var itemsText = "";
            foreach (var item in order.Items)
            {
                itemsHtml += $"<tr><td style='padding:8px;border-bottom:1px solid #eee;'>{item.ProductName}</td><td style='padding:8px;border-bottom:1px solid #eee;text-align:center;'>{item.Quantity}</td><td style='padding:8px;border-bottom:1px solid #eee;text-align:right;'>{item.TotalPrice:F2} {order.Currency}</td></tr>";
                itemsText += $"  • {item.ProductName} x{item.Quantity} - {item.TotalPrice:F2} {order.Currency}\n";
            }

            // Invoice section
            var invoiceSection = "";
            var invoiceText = "";
            if (!string.IsNullOrWhiteSpace(order.InvoicePdfUrl))
            {
                invoiceSection = isPT
                    ? $"<p style='margin:16px 0;'><a href='{order.InvoicePdfUrl}' style='background:#1a1a1a;color:#fff;padding:12px 24px;text-decoration:none;border-radius:6px;display:inline-block;'>📄 Ver Fatura PDF</a></p>"
                    : $"<p style='margin:16px 0;'><a href='{order.InvoicePdfUrl}' style='background:#1a1a1a;color:#fff;padding:12px 24px;text-decoration:none;border-radius:6px;display:inline-block;'>📄 View Invoice PDF</a></p>";
                invoiceText = isPT
                    ? $"\nFatura PDF: {order.InvoicePdfUrl}\n"
                    : $"\nInvoice PDF: {order.InvoicePdfUrl}\n";
            }

            // Tracking section
            var trackingSection = "";
            var trackingText = "";
            if (!string.IsNullOrWhiteSpace(order.TrackingNumber))
            {
                var carrier = order.Carrier ?? "Transportadora";
                var trackingLink = !string.IsNullOrWhiteSpace(order.TrackingUrl)
                    ? $"<a href='{order.TrackingUrl}' style='color:#0066cc;'>{order.TrackingNumber}</a>"
                    : order.TrackingNumber;
                trackingSection = isPT
                    ? $"<p><strong>Envio:</strong> {carrier} - {trackingLink}</p>"
                    : $"<p><strong>Shipping:</strong> {carrier} - {trackingLink}</p>";
                trackingText = isPT
                    ? $"Envio: {carrier} - {order.TrackingNumber}\n"
                    : $"Shipping: {carrier} - {order.TrackingNumber}\n";
                if (!string.IsNullOrWhiteSpace(order.TrackingUrl))
                    trackingText += $"Seguir envio: {order.TrackingUrl}\n";
            }

            // Shipping address
            var addressSection = "";
            var addressText = "";
            if (!string.IsNullOrWhiteSpace(order.ShippingAddress))
            {
                addressSection = isPT
                    ? $"<p><strong>Morada de entrega:</strong><br/>{order.ShippingAddress.Replace("\n", "<br/>")}</p>"
                    : $"<p><strong>Shipping address:</strong><br/>{order.ShippingAddress.Replace("\n", "<br/>")}</p>";
                addressText = isPT
                    ? $"\nMorada de entrega:\n{order.ShippingAddress}\n"
                    : $"\nShipping address:\n{order.ShippingAddress}\n";
            }

            var greeting = isPT
                ? $"Olá {order.CustomerName},"
                : $"Hello {order.CustomerName},";
            
            var intro = isPT
                ? "Obrigado pela sua encomenda! O seu pagamento foi confirmado."
                : "Thank you for your order! Your payment has been confirmed.";

            var orderDetailsLabel = isPT ? "Detalhes da Encomenda" : "Order Details";
            var itemsLabel = isPT ? "Artigos" : "Items";
            var totalLabel = isPT ? "Total" : "Total";

            string htmlBody = $@"
<!DOCTYPE html>
<html>
<head><meta charset='utf-8'></head>
<body style='font-family:Arial,sans-serif;max-width:600px;margin:0 auto;padding:20px;'>
    <div style='background:#f8f8f8;padding:24px;border-radius:8px;'>
        <h1 style='color:#1a1a1a;margin:0 0 16px 0;'>{(isPT ? "Encomenda Confirmada" : "Order Confirmed")} ✓</h1>
        <p>{greeting}</p>
        <p>{intro}</p>
        
        <div style='background:#fff;padding:20px;border-radius:8px;margin:20px 0;border:1px solid #eee;'>
            <h2 style='margin:0 0 16px 0;color:#1a1a1a;'>{orderDetailsLabel}</h2>
            <p><strong>{(isPT ? "Encomenda" : "Order")}:</strong> #{order.OrderNumber}</p>
            
            <h3 style='margin:16px 0 8px 0;'>{itemsLabel}</h3>
            <table style='width:100%;border-collapse:collapse;'>
                <thead>
                    <tr style='background:#f5f5f5;'>
                        <th style='padding:8px;text-align:left;'>{(isPT ? "Produto" : "Product")}</th>
                        <th style='padding:8px;text-align:center;'>{(isPT ? "Qtd" : "Qty")}</th>
                        <th style='padding:8px;text-align:right;'>{(isPT ? "Preço" : "Price")}</th>
                    </tr>
                </thead>
                <tbody>
                    {itemsHtml}
                </tbody>
            </table>
            
            <p style='font-size:18px;font-weight:bold;margin:16px 0;text-align:right;'>
                {totalLabel}: {order.GrandTotal:F2} {order.Currency}
            </p>
            
            {addressSection}
            {trackingSection}
        </div>
        
        {invoiceSection}
        
        <p style='color:#666;font-size:14px;margin-top:24px;'>
            {(isPT ? "Se tiver alguma questão, responda a este email ou contacte-nos." : "If you have any questions, reply to this email or contact us.")}
        </p>
        
        <p style='margin-top:24px;'>
            {(isPT ? "Obrigado," : "Thank you,")}<br/>
            <strong>Equipa Jacurvas</strong>
        </p>
    </div>
</body>
</html>";

            string plainBody = $@"{greeting}

{intro}

{orderDetailsLabel}
---
{(isPT ? "Encomenda" : "Order")}: #{order.OrderNumber}

{itemsLabel}:
{itemsText}
{totalLabel}: {order.GrandTotal:F2} {order.Currency}
{addressText}{trackingText}{invoiceText}
---
{(isPT ? "Se tiver alguma questão, responda a este email ou contacte-nos." : "If you have any questions, reply to this email or contact us.")}

{(isPT ? "Obrigado," : "Thank you,")}
Equipa Jacurvas
";

            var dto = new EmailSenderDto
            {
                To = order.ToEmail,
                Subject = subject,
                TextBody = plainBody,
                HtmlBody = htmlBody,
                Tag = "order-confirmation",
                MessageStream = "outbound"
            };

            return await _postmarkService.SendEmailAsync(dto, cancellationToken);
        }
    }
}
