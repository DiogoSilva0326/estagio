using System;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Auth;
using ConfidantPostgreSQL.Modules.Payments.Models;
using ConfidantPostgreSQL.Modules.Payments.Service;
using Microsoft.AspNetCore.Mvc;

namespace ConfidantPostgreSQL.Modules.Payments.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [AuthorizeJwt]
    public class PaymentsController : ControllerBase
    {
        private readonly IPaymentsService _service;

        public PaymentsController(IPaymentsService service)
        {
            _service = service;
        }

        private bool TryGetAuthenticatedUserId(out Guid userId)
        {
            userId = Guid.Empty;
            if (HttpContext?.Items == null) return false;
            if (!HttpContext.Items.TryGetValue("UserId", out var raw) || raw == null) return false;
            if (raw is Guid g)
            {
                userId = g;
                return userId != Guid.Empty;
            }

            return Guid.TryParse(raw.ToString(), out userId) && userId != Guid.Empty;
        }

        // WALLETS
        [HttpGet("wallets")]
        public async Task<IActionResult> GetWallets()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetWalletsAllAsync());
        }

        [HttpGet("wallets/{idWallet:guid}")]
        public async Task<IActionResult> GetWallet(Guid idWallet)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetWalletByIdAsync(idWallet);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("wallets")]
        public async Task<IActionResult> CreateWallet([FromBody] Wallet wallet)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertWalletAsync(wallet);
            wallet.IdWallet = id;
            return CreatedAtAction(nameof(GetWallet), new { idWallet = id }, wallet);
        }

        [HttpPut("wallets/{idWallet:guid}")]
        public async Task<IActionResult> UpdateWallet(Guid idWallet, [FromBody] Wallet wallet)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idWallet != wallet.IdWallet) return BadRequest();
            var rows = await _service.UpdateWalletAsync(wallet);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("wallets/{idWallet:guid}")]
        public async Task<IActionResult> DeleteWallet(Guid idWallet)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteWalletAsync(idWallet);
            return rows == 0 ? NotFound() : NoContent();
        }

        // TRANSACTIONS
        [HttpGet("transactions")]
        public async Task<IActionResult> GetTransactions()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetTransactionsAllAsync());
        }

        [HttpGet("transactions/{idTransaction:guid}")]
        public async Task<IActionResult> GetTransaction(Guid idTransaction)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetTransactionByIdAsync(idTransaction);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("transactions")]
        public async Task<IActionResult> CreateTransaction([FromBody] Transaction tx)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertTransactionAsync(tx);
            tx.IdTransaction = id;
            return CreatedAtAction(nameof(GetTransaction), new { idTransaction = id }, tx);
        }

        [HttpPut("transactions/{idTransaction:guid}")]
        public async Task<IActionResult> UpdateTransaction(Guid idTransaction, [FromBody] Transaction tx)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idTransaction != tx.IdTransaction) return BadRequest();
            var rows = await _service.UpdateTransactionAsync(tx);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("transactions/{idTransaction:guid}")]
        public async Task<IActionResult> DeleteTransaction(Guid idTransaction)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteTransactionAsync(idTransaction);
            return rows == 0 ? NotFound() : NoContent();
        }

        // INVOICES
        [HttpGet("invoices")]
        public async Task<IActionResult> GetInvoices()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetInvoicesAllAsync());
        }

        [HttpGet("invoices/{idInvoice:guid}")]
        public async Task<IActionResult> GetInvoice(Guid idInvoice)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetInvoiceByIdAsync(idInvoice);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpGet("invoices/by-user/{idUser:guid}")]
        public async Task<IActionResult> GetInvoicesByUser(Guid idUser)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetInvoicesByUserIdAsync(idUser));
        }

        [HttpGet("me/summary")]
        public async Task<IActionResult> GetMySummary()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            return Ok(await _service.GetStudentPaymentSummaryAsync(userId));
        }

        [HttpGet("me/teacher-summary")]
        public async Task<IActionResult> GetMyTeacherSummary()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            return Ok(await _service.GetProfessorPaymentSummaryAsync(userId));
        }

        [HttpGet("me/teacher-payments/{idReservationPayment:guid}")]
        public async Task<IActionResult> GetMyTeacherPaymentDetails(Guid idReservationPayment)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            var item = await _service.GetProfessorPaymentDetailsAsync(userId, idReservationPayment);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("invoices")]
        public async Task<IActionResult> CreateInvoice([FromBody] Invoice invoice)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertInvoiceAsync(invoice);
            invoice.IdInvoice = id;
            return CreatedAtAction(nameof(GetInvoice), new { idInvoice = id }, invoice);
        }

        [HttpPut("invoices/{idInvoice:guid}")]
        public async Task<IActionResult> UpdateInvoice(Guid idInvoice, [FromBody] Invoice invoice)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idInvoice != invoice.IdInvoice) return BadRequest();
            var rows = await _service.UpdateInvoiceAsync(invoice);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("invoices/{idInvoice:guid}")]
        public async Task<IActionResult> DeleteInvoice(Guid idInvoice)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteInvoiceAsync(idInvoice);
            return rows == 0 ? NotFound() : NoContent();
        }

        // PAYMENT METHODS
        [HttpGet("payment-methods")]
        public async Task<IActionResult> GetPaymentMethods()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetPaymentMethodsAllAsync());
        }

        [HttpGet("payment-methods/{idPaymentMethod:guid}")]
        public async Task<IActionResult> GetPaymentMethod(Guid idPaymentMethod)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetPaymentMethodByIdAsync(idPaymentMethod);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("payment-methods")]
        public async Task<IActionResult> CreatePaymentMethod([FromBody] PaymentMethod method)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertPaymentMethodAsync(method);
            method.IdPaymentMethod = id;
            return CreatedAtAction(nameof(GetPaymentMethod), new { idPaymentMethod = id }, method);
        }

        [HttpPut("payment-methods/{idPaymentMethod:guid}")]
        public async Task<IActionResult> UpdatePaymentMethod(Guid idPaymentMethod, [FromBody] PaymentMethod method)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idPaymentMethod != method.IdPaymentMethod) return BadRequest();
            var rows = await _service.UpdatePaymentMethodAsync(method);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("payment-methods/{idPaymentMethod:guid}")]
        public async Task<IActionResult> DeletePaymentMethod(Guid idPaymentMethod)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeletePaymentMethodAsync(idPaymentMethod);
            return rows == 0 ? NotFound() : NoContent();
        }

        // PAYMENT PROVIDERS
        [HttpGet("payment-providers")]
        public async Task<IActionResult> GetPaymentProviders()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetPaymentProvidersAllAsync());
        }

        [HttpGet("payment-providers/{idPaymentProvider:guid}")]
        public async Task<IActionResult> GetPaymentProvider(Guid idPaymentProvider)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetPaymentProviderByIdAsync(idPaymentProvider);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("payment-providers")]
        public async Task<IActionResult> CreatePaymentProvider([FromBody] PaymentProvider provider)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertPaymentProviderAsync(provider);
            provider.IdPaymentProvider = id;
            return CreatedAtAction(nameof(GetPaymentProvider), new { idPaymentProvider = id }, provider);
        }

        [HttpPut("payment-providers/{idPaymentProvider:guid}")]
        public async Task<IActionResult> UpdatePaymentProvider(Guid idPaymentProvider, [FromBody] PaymentProvider provider)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idPaymentProvider != provider.IdPaymentProvider) return BadRequest();
            var rows = await _service.UpdatePaymentProviderAsync(provider);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("payment-providers/{idPaymentProvider:guid}")]
        public async Task<IActionResult> DeletePaymentProvider(Guid idPaymentProvider)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeletePaymentProviderAsync(idPaymentProvider);
            return rows == 0 ? NotFound() : NoContent();
        }

        // WITHDRAWAL POLICIES
        [HttpGet("withdrawal-policies")]
        public async Task<IActionResult> GetWithdrawalPolicies()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetWithdrawalPoliciesAllAsync());
        }

        [HttpGet("withdrawal-policies/{idWithdrawalPolicy:guid}")]
        public async Task<IActionResult> GetWithdrawalPolicy(Guid idWithdrawalPolicy)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetWithdrawalPolicyByIdAsync(idWithdrawalPolicy);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("withdrawal-policies")]
        public async Task<IActionResult> CreateWithdrawalPolicy([FromBody] WithdrawalPolicy policy)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertWithdrawalPolicyAsync(policy);
            policy.IdWithdrawalPolicy = id;
            return CreatedAtAction(nameof(GetWithdrawalPolicy), new { idWithdrawalPolicy = id }, policy);
        }

        [HttpPut("withdrawal-policies/{idWithdrawalPolicy:guid}")]
        public async Task<IActionResult> UpdateWithdrawalPolicy(Guid idWithdrawalPolicy, [FromBody] WithdrawalPolicy policy)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idWithdrawalPolicy != policy.IdWithdrawalPolicy) return BadRequest();
            var rows = await _service.UpdateWithdrawalPolicyAsync(policy);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("withdrawal-policies/{idWithdrawalPolicy:guid}")]
        public async Task<IActionResult> DeleteWithdrawalPolicy(Guid idWithdrawalPolicy)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteWithdrawalPolicyAsync(idWithdrawalPolicy);
            return rows == 0 ? NotFound() : NoContent();
        }

        // TOPUPS
        [HttpGet("topups")]
        public async Task<IActionResult> GetTopups()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetTopupsAllAsync());
        }

        [HttpGet("topups/{idTopup:guid}")]
        public async Task<IActionResult> GetTopup(Guid idTopup)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetTopupByIdAsync(idTopup);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("topups")]
        public async Task<IActionResult> CreateTopup([FromBody] Topup topup)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertTopupAsync(topup);
            topup.IdTopup = id;
            return CreatedAtAction(nameof(GetTopup), new { idTopup = id }, topup);
        }

        [HttpPost("me/topups/simulate")]
        public async Task<IActionResult> SimulateMyTopup([FromBody] StudentTopupSimulationRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();
            if (request == null) return BadRequest("Pedido inválido.");
            if (request.CreditsAmount <= 0) return BadRequest("A quantidade de créditos tem de ser superior a zero.");
            if (request.GetNormalizedPaymentAmount() <= 0) return BadRequest("O valor do top-up tem de ser superior a zero.");

            var summary = await _service.SimulateStudentTopupAsync(userId, request);
            return Ok(summary);
        }

        [HttpPut("topups/{idTopup:guid}")]
        public async Task<IActionResult> UpdateTopup(Guid idTopup, [FromBody] Topup topup)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idTopup != topup.IdTopup) return BadRequest();
            var rows = await _service.UpdateTopupAsync(topup);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("topups/{idTopup:guid}")]
        public async Task<IActionResult> DeleteTopup(Guid idTopup)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteTopupAsync(idTopup);
            return rows == 0 ? NotFound() : NoContent();
        }

        // REFUNDS
        [HttpGet("refunds")]
        public async Task<IActionResult> GetRefunds()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetRefundsAllAsync());
        }

        [HttpGet("refunds/{idRefund:guid}")]
        public async Task<IActionResult> GetRefund(Guid idRefund)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetRefundByIdAsync(idRefund);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("refunds")]
        public async Task<IActionResult> CreateRefund([FromBody] Refund refund)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertRefundAsync(refund);
            refund.IdRefund = id;
            return CreatedAtAction(nameof(GetRefund), new { idRefund = id }, refund);
        }

        [HttpPut("refunds/{idRefund:guid}")]
        public async Task<IActionResult> UpdateRefund(Guid idRefund, [FromBody] Refund refund)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idRefund != refund.IdRefund) return BadRequest();
            var rows = await _service.UpdateRefundAsync(refund);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("refunds/{idRefund:guid}")]
        public async Task<IActionResult> DeleteRefund(Guid idRefund)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteRefundAsync(idRefund);
            return rows == 0 ? NotFound() : NoContent();
        }

        // DISPUTES
        [HttpGet("disputes")]
        public async Task<IActionResult> GetDisputes()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetDisputesAllAsync());
        }

        [HttpGet("disputes/{idDispute:guid}")]
        public async Task<IActionResult> GetDispute(Guid idDispute)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetDisputeByIdAsync(idDispute);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("disputes")]
        public async Task<IActionResult> CreateDispute([FromBody] Dispute dispute)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertDisputeAsync(dispute);
            dispute.IdDispute = id;
            return CreatedAtAction(nameof(GetDispute), new { idDispute = id }, dispute);
        }

        [HttpPost("me/disputes")]
        public async Task<IActionResult> CreateMyDispute([FromBody] CreatePaymentDisputeRequest request)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (!TryGetAuthenticatedUserId(out var userId)) return Unauthorized();

            if (request == null)
            {
                return BadRequest(new { message = "Pedido inválido." });
            }

            if (request.PaymentRecordId == Guid.Empty)
            {
                return BadRequest(new { message = "Seleciona um pagamento válido." });
            }

            if (!TryNormalizePaymentSource(request.PaymentSource, out var normalizedSource))
            {
                return BadRequest(new { message = "O pagamento selecionado é inválido." });
            }

            if (string.IsNullOrWhiteSpace(request.Name))
            {
                return BadRequest(new { message = "O nome é obrigatório." });
            }

            if (!IsValidEmail(request.Email))
            {
                return BadRequest(new { message = "O email é inválido." });
            }

            if (string.IsNullOrWhiteSpace(request.Subject))
            {
                return BadRequest(new { message = "O assunto é obrigatório." });
            }

            if (string.IsNullOrWhiteSpace(request.Message))
            {
                return BadRequest(new { message = "A mensagem é obrigatória." });
            }

            request.PaymentSource = normalizedSource;
            var created = await _service.CreatePaymentDisputeAsync(userId, request);
            if (created == null)
            {
                return BadRequest(new { message = "Não foi possível associar a reclamação ao pagamento selecionado." });
            }

            return Ok(created);
        }

        [HttpPut("disputes/{idDispute:guid}")]
        public async Task<IActionResult> UpdateDispute(Guid idDispute, [FromBody] Dispute dispute)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idDispute != dispute.IdDispute) return BadRequest();
            var rows = await _service.UpdateDisputeAsync(dispute);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("disputes/{idDispute:guid}")]
        public async Task<IActionResult> DeleteDispute(Guid idDispute)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteDisputeAsync(idDispute);
            return rows == 0 ? NotFound() : NoContent();
        }

        // COMMISSION RULES
        [HttpGet("commission-rules")]
        public async Task<IActionResult> GetCommissionRules()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetCommissionRulesAllAsync());
        }

        [HttpGet("commission-rules/{idCommissionRule:guid}")]
        public async Task<IActionResult> GetCommissionRule(Guid idCommissionRule)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetCommissionRuleByIdAsync(idCommissionRule);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("commission-rules")]
        public async Task<IActionResult> CreateCommissionRule([FromBody] CommissionRule rule)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertCommissionRuleAsync(rule);
            rule.IdCommissionRule = id;
            return CreatedAtAction(nameof(GetCommissionRule), new { idCommissionRule = id }, rule);
        }

        [HttpPut("commission-rules/{idCommissionRule:guid}")]
        public async Task<IActionResult> UpdateCommissionRule(Guid idCommissionRule, [FromBody] CommissionRule rule)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idCommissionRule != rule.IdCommissionRule) return BadRequest();
            var rows = await _service.UpdateCommissionRuleAsync(rule);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("commission-rules/{idCommissionRule:guid}")]
        public async Task<IActionResult> DeleteCommissionRule(Guid idCommissionRule)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteCommissionRuleAsync(idCommissionRule);
            return rows == 0 ? NotFound() : NoContent();
        }

        // RESERVATION PAYMENTS
        [HttpGet("reservation-payments")]
        public async Task<IActionResult> GetReservationPayments()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetReservationPaymentsAllAsync());
        }

        [HttpGet("reservation-payments/{idReservationPayment:guid}")]
        public async Task<IActionResult> GetReservationPayment(Guid idReservationPayment)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetReservationPaymentByIdAsync(idReservationPayment);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("reservation-payments")]
        public async Task<IActionResult> CreateReservationPayment([FromBody] ReservationPayment rp)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertReservationPaymentAsync(rp);
            rp.IdReservationPayment = id;
            return CreatedAtAction(nameof(GetReservationPayment), new { idReservationPayment = id }, rp);
        }

        [HttpPut("reservation-payments/{idReservationPayment:guid}")]
        public async Task<IActionResult> UpdateReservationPayment(Guid idReservationPayment, [FromBody] ReservationPayment rp)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idReservationPayment != rp.IdReservationPayment) return BadRequest();
            var rows = await _service.UpdateReservationPaymentAsync(rp);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("reservation-payments/{idReservationPayment:guid}")]
        public async Task<IActionResult> DeleteReservationPayment(Guid idReservationPayment)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteReservationPaymentAsync(idReservationPayment);
            return rows == 0 ? NotFound() : NoContent();
        }

        // WITHDRAWAL REQUESTS
        [HttpGet("withdrawal-requests")]
        public async Task<IActionResult> GetWithdrawalRequests()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetWithdrawalRequestsAllAsync());
        }

        [HttpGet("withdrawal-requests/{idWithdrawalRequest:guid}")]
        public async Task<IActionResult> GetWithdrawalRequest(Guid idWithdrawalRequest)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetWithdrawalRequestByIdAsync(idWithdrawalRequest);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("withdrawal-requests")]
        public async Task<IActionResult> CreateWithdrawalRequest([FromBody] WithdrawalRequest req)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertWithdrawalRequestAsync(req);
            req.IdWithdrawalRequest = id;
            return CreatedAtAction(nameof(GetWithdrawalRequest), new { idWithdrawalRequest = id }, req);
        }

        [HttpPut("withdrawal-requests/{idWithdrawalRequest:guid}")]
        public async Task<IActionResult> UpdateWithdrawalRequest(Guid idWithdrawalRequest, [FromBody] WithdrawalRequest req)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idWithdrawalRequest != req.IdWithdrawalRequest) return BadRequest();
            var rows = await _service.UpdateWithdrawalRequestAsync(req);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("withdrawal-requests/{idWithdrawalRequest:guid}")]
        public async Task<IActionResult> DeleteWithdrawalRequest(Guid idWithdrawalRequest)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeleteWithdrawalRequestAsync(idWithdrawalRequest);
            return rows == 0 ? NotFound() : NoContent();
        }

        // PAYOUTS
        [HttpGet("payouts")]
        public async Task<IActionResult> GetPayouts()
        {
            RequestContext.ApplyCultureFromHeader(Request);
            return Ok(await _service.GetPayoutsAllAsync());
        }

        [HttpGet("payouts/{idPayout:guid}")]
        public async Task<IActionResult> GetPayout(Guid idPayout)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var item = await _service.GetPayoutByIdAsync(idPayout);
            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost("payouts")]
        public async Task<IActionResult> CreatePayout([FromBody] Payout payout)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var id = await _service.InsertPayoutAsync(payout);
            payout.IdPayout = id;
            return CreatedAtAction(nameof(GetPayout), new { idPayout = id }, payout);
        }

        [HttpPut("payouts/{idPayout:guid}")]
        public async Task<IActionResult> UpdatePayout(Guid idPayout, [FromBody] Payout payout)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            if (idPayout != payout.IdPayout) return BadRequest();
            var rows = await _service.UpdatePayoutAsync(payout);
            return rows == 0 ? NotFound() : NoContent();
        }

        [HttpDelete("payouts/{idPayout:guid}")]
        public async Task<IActionResult> DeletePayout(Guid idPayout)
        {
            RequestContext.ApplyCultureFromHeader(Request);
            var rows = await _service.DeletePayoutAsync(idPayout);
            return rows == 0 ? NotFound() : NoContent();
        }

        private static bool TryNormalizePaymentSource(string? value, out string normalized)
        {
            normalized = string.Empty;
            var candidate = value?.Trim().ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(candidate))
            {
                return false;
            }

            if (candidate is "reservation_payment" or "reservationpayment" or "reservation-payment")
            {
                normalized = "reservation_payment";
                return true;
            }

            if (candidate is "topup" or "top_up" or "top-up")
            {
                normalized = "topup";
                return true;
            }

            return false;
        }

        private static bool IsValidEmail(string? value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            return Regex.IsMatch(value.Trim(), @"^[^@\s]+@[^@\s]+\.[^@\s]+$");
        }
    }
}
