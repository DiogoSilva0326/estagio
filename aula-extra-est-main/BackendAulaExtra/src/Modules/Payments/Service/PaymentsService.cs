using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Payments.Models;
using ConfidantPostgreSQL.Modules.Payments.Repository;

namespace ConfidantPostgreSQL.Modules.Payments.Service
{
    public class PaymentsService : IPaymentsService
    {
        private readonly IPaymentsRepository _repo;

        public PaymentsService(IPaymentsRepository repo)
        {
            _repo = repo;
        }

        public Task<IEnumerable<Wallet>> GetWalletsAllAsync() => _repo.GetWalletsAllAsync();
        public Task<Wallet?> GetWalletByIdAsync(Guid idWallet) => _repo.GetWalletByIdAsync(idWallet);
        public Task<Wallet?> GetWalletByOwnerUserIdAsync(Guid ownerUserId) => _repo.GetWalletByOwnerUserIdAsync(ownerUserId);
        public Task<Guid> InsertWalletAsync(Wallet wallet) => _repo.InsertWalletAsync(wallet);
        public Task<int> UpdateWalletAsync(Wallet wallet) => _repo.UpdateWalletAsync(wallet);
        public Task<int> DeleteWalletAsync(Guid idWallet) => _repo.DeleteWalletAsync(idWallet);

        public Task<IEnumerable<Transaction>> GetTransactionsAllAsync() => _repo.GetTransactionsAllAsync();
        public Task<Transaction?> GetTransactionByIdAsync(Guid idTransaction) => _repo.GetTransactionByIdAsync(idTransaction);
        public Task<IEnumerable<Transaction>> GetTransactionsByWalletIdAsync(Guid walletId) => _repo.GetTransactionsByWalletIdAsync(walletId);
        public Task<Guid> InsertTransactionAsync(Transaction tx) => _repo.InsertTransactionAsync(tx);
        public Task<int> UpdateTransactionAsync(Transaction tx) => _repo.UpdateTransactionAsync(tx);
        public Task<int> DeleteTransactionAsync(Guid idTransaction) => _repo.DeleteTransactionAsync(idTransaction);

        public Task<IEnumerable<Invoice>> GetInvoicesAllAsync() => _repo.GetInvoicesAllAsync();
        public Task<Invoice?> GetInvoiceByIdAsync(Guid idInvoice) => _repo.GetInvoiceByIdAsync(idInvoice);
        public Task<IEnumerable<Invoice>> GetInvoicesByUserIdAsync(Guid idUser) => _repo.GetInvoicesByUserIdAsync(idUser);
        public Task<IEnumerable<StudentPaymentHistoryItemDto>> GetStudentPaymentHistoryAsync(Guid idUser) => _repo.GetStudentPaymentHistoryAsync(idUser);
        public Task<IEnumerable<ProfessorPaymentHistoryItemDto>> GetProfessorPaymentHistoryAsync(Guid idUser) => _repo.GetProfessorPaymentHistoryAsync(idUser);

        public async Task<StudentPaymentSummaryDto> GetStudentPaymentSummaryAsync(Guid idUser)
        {
            var wallet = await _repo.GetWalletByOwnerUserIdAsync(idUser);
            var history = (await _repo.GetStudentPaymentHistoryAsync(idUser)).ToList();

            var totalSpent = history
                .Where(item => IsPaidStatus(item.Status))
                .Sum(item => item.Amount);

            var pendingAmount = history
                .Where(item => IsPendingStatus(item.Status))
                .Sum(item => item.Amount);

            return new StudentPaymentSummaryDto
            {
                AvailableCredits = wallet?.Balance ?? 0m,
                TotalSpent = totalSpent,
                PendingAmount = pendingAmount,
                TransactionsCount = history.Count,
                Currency = string.IsNullOrWhiteSpace(wallet?.Currency) ? "EUR" : wallet!.Currency!,
                History = history
            };
        }

        public async Task<ProfessorPaymentSummaryDto> GetProfessorPaymentSummaryAsync(Guid idUser)
        {
            var history = (await _repo.GetProfessorPaymentHistoryAsync(idUser)).ToList();
            var currency = history.FirstOrDefault()?.Currency;
            var now = DateTime.UtcNow;

            var totalReceived = history
                .Where(item => IsPaidStatus(item.Status))
                .Sum(item => item.NetAmount);

            var pendingAmount = history
                .Where(item => IsPendingStatus(item.Status))
                .Sum(item => item.NetAmount);

            var totalThisMonth = history
                .Where(item => item.PaymentDate.HasValue
                    && item.PaymentDate.Value.Year == now.Year
                    && item.PaymentDate.Value.Month == now.Month)
                .Sum(item => item.NetAmount);

            return new ProfessorPaymentSummaryDto
            {
                TotalReceived = totalReceived,
                PendingAmount = pendingAmount,
                TotalThisMonth = totalThisMonth,
                TransactionsCount = history.Count,
                Currency = string.IsNullOrWhiteSpace(currency) ? "EUR" : currency!,
                History = history
            };
        }

        public Task<ProfessorPaymentDetailsDto?> GetProfessorPaymentDetailsAsync(Guid idUser, Guid idReservationPayment) =>
            _repo.GetProfessorPaymentDetailsAsync(idUser, idReservationPayment);

        public Task<Guid> InsertInvoiceAsync(Invoice invoice) => _repo.InsertInvoiceAsync(invoice);
        public Task<int> UpdateInvoiceAsync(Invoice invoice) => _repo.UpdateInvoiceAsync(invoice);
        public Task<int> DeleteInvoiceAsync(Guid idInvoice) => _repo.DeleteInvoiceAsync(idInvoice);

        public Task<IEnumerable<PaymentMethod>> GetPaymentMethodsAllAsync() => _repo.GetPaymentMethodsAllAsync();
        public Task<PaymentMethod?> GetPaymentMethodByIdAsync(Guid idPaymentMethod) => _repo.GetPaymentMethodByIdAsync(idPaymentMethod);
        public Task<Guid> InsertPaymentMethodAsync(PaymentMethod method) => _repo.InsertPaymentMethodAsync(method);
        public Task<int> UpdatePaymentMethodAsync(PaymentMethod method) => _repo.UpdatePaymentMethodAsync(method);
        public Task<int> DeletePaymentMethodAsync(Guid idPaymentMethod) => _repo.DeletePaymentMethodAsync(idPaymentMethod);

        public Task<IEnumerable<PaymentProvider>> GetPaymentProvidersAllAsync() => _repo.GetPaymentProvidersAllAsync();
        public Task<PaymentProvider?> GetPaymentProviderByIdAsync(Guid idPaymentProvider) => _repo.GetPaymentProviderByIdAsync(idPaymentProvider);
        public Task<Guid> InsertPaymentProviderAsync(PaymentProvider provider) => _repo.InsertPaymentProviderAsync(provider);
        public Task<int> UpdatePaymentProviderAsync(PaymentProvider provider) => _repo.UpdatePaymentProviderAsync(provider);
        public Task<int> DeletePaymentProviderAsync(Guid idPaymentProvider) => _repo.DeletePaymentProviderAsync(idPaymentProvider);

        public Task<IEnumerable<WithdrawalPolicy>> GetWithdrawalPoliciesAllAsync() => _repo.GetWithdrawalPoliciesAllAsync();
        public Task<WithdrawalPolicy?> GetWithdrawalPolicyByIdAsync(Guid idWithdrawalPolicy) => _repo.GetWithdrawalPolicyByIdAsync(idWithdrawalPolicy);
        public Task<Guid> InsertWithdrawalPolicyAsync(WithdrawalPolicy policy) => _repo.InsertWithdrawalPolicyAsync(policy);
        public Task<int> UpdateWithdrawalPolicyAsync(WithdrawalPolicy policy) => _repo.UpdateWithdrawalPolicyAsync(policy);
        public Task<int> DeleteWithdrawalPolicyAsync(Guid idWithdrawalPolicy) => _repo.DeleteWithdrawalPolicyAsync(idWithdrawalPolicy);

        public Task<IEnumerable<Topup>> GetTopupsAllAsync() => _repo.GetTopupsAllAsync();
        public Task<Topup?> GetTopupByIdAsync(Guid idTopup) => _repo.GetTopupByIdAsync(idTopup);
        public Task<Guid> InsertTopupAsync(Topup topup) => _repo.InsertTopupAsync(topup);
        public async Task<StudentPaymentSummaryDto> SimulateStudentTopupAsync(Guid idUser, StudentTopupSimulationRequest request)
        {
            await _repo.SimulateStudentTopupAsync(idUser, request);
            return await GetStudentPaymentSummaryAsync(idUser);
        }
        public Task<ReservationPaymentReviewDto?> GetReservationPaymentReviewAsync(Guid idUser, Guid idReservation) =>
            _repo.GetReservationPaymentReviewAsync(idUser, idReservation);
        public Task<ReservationPaymentProcessResultDto> ProcessReservationPaymentAsync(Guid idUser, Guid idReservation) =>
            _repo.ProcessReservationPaymentAsync(idUser, idReservation);
        public Task<ReservationPaymentRefundResultDto> RefundReservationPaymentAsync(Guid idReservation) =>
            _repo.RefundReservationPaymentAsync(idReservation);
        public Task<int> UpdateTopupAsync(Topup topup) => _repo.UpdateTopupAsync(topup);
        public Task<int> DeleteTopupAsync(Guid idTopup) => _repo.DeleteTopupAsync(idTopup);

        public Task<IEnumerable<Refund>> GetRefundsAllAsync() => _repo.GetRefundsAllAsync();
        public Task<Refund?> GetRefundByIdAsync(Guid idRefund) => _repo.GetRefundByIdAsync(idRefund);
        public Task<Guid> InsertRefundAsync(Refund refund) => _repo.InsertRefundAsync(refund);
        public Task<int> UpdateRefundAsync(Refund refund) => _repo.UpdateRefundAsync(refund);
        public Task<int> DeleteRefundAsync(Guid idRefund) => _repo.DeleteRefundAsync(idRefund);

        public Task<IEnumerable<Dispute>> GetDisputesAllAsync() => _repo.GetDisputesAllAsync();
        public Task<Dispute?> GetDisputeByIdAsync(Guid idDispute) => _repo.GetDisputeByIdAsync(idDispute);
        public async Task<Dispute?> CreatePaymentDisputeAsync(Guid idUser, CreatePaymentDisputeRequest request)
        {
            var context = await _repo.ResolvePaymentDisputeContextAsync(idUser, request.PaymentSource, request.PaymentRecordId);
            if (context == null)
            {
                return null;
            }

            var utcNow = DateTime.UtcNow;
            var dispute = new Dispute
            {
                TransactionId = context.TransactionId,
                IdReservation = context.ReservationId,
                ReservationPaymentId = context.ReservationPaymentId,
                TopupId = context.TopupId,
                RaisedByUserId = idUser,
                ReporterName = request.Name.Trim(),
                ReporterEmail = request.Email.Trim(),
                ReporterRole = context.ReporterRole,
                Subject = request.Subject.Trim(),
                Reason = request.Message.Trim(),
                PaymentReference = context.PaymentReference,
                PaymentSource = context.PaymentSource,
                Status = "submetida",
                CreatedAt = utcNow,
                UpdatedAt = utcNow
            };

            var id = await _repo.InsertDisputeAsync(dispute);
            if (id == Guid.Empty)
            {
                return null;
            }

            return await _repo.GetDisputeByIdAsync(id);
        }
        public Task<Guid> InsertDisputeAsync(Dispute dispute) => _repo.InsertDisputeAsync(dispute);
        public Task<int> UpdateDisputeAsync(Dispute dispute) => _repo.UpdateDisputeAsync(dispute);
        public Task<int> DeleteDisputeAsync(Guid idDispute) => _repo.DeleteDisputeAsync(idDispute);

        public Task<IEnumerable<CommissionRule>> GetCommissionRulesAllAsync() => _repo.GetCommissionRulesAllAsync();
        public Task<CommissionRule?> GetCommissionRuleByIdAsync(Guid idCommissionRule) => _repo.GetCommissionRuleByIdAsync(idCommissionRule);
        public Task<Guid> InsertCommissionRuleAsync(CommissionRule rule) => _repo.InsertCommissionRuleAsync(rule);
        public Task<int> UpdateCommissionRuleAsync(CommissionRule rule) => _repo.UpdateCommissionRuleAsync(rule);
        public Task<int> DeleteCommissionRuleAsync(Guid idCommissionRule) => _repo.DeleteCommissionRuleAsync(idCommissionRule);

        public Task<IEnumerable<ReservationPayment>> GetReservationPaymentsAllAsync() => _repo.GetReservationPaymentsAllAsync();
        public Task<ReservationPayment?> GetReservationPaymentByIdAsync(Guid idReservationPayment) => _repo.GetReservationPaymentByIdAsync(idReservationPayment);
        public Task<Guid> InsertReservationPaymentAsync(ReservationPayment rp) => _repo.InsertReservationPaymentAsync(rp);
        public Task<int> UpdateReservationPaymentAsync(ReservationPayment rp) => _repo.UpdateReservationPaymentAsync(rp);
        public Task<int> DeleteReservationPaymentAsync(Guid idReservationPayment) => _repo.DeleteReservationPaymentAsync(idReservationPayment);

        public Task<IEnumerable<WithdrawalRequest>> GetWithdrawalRequestsAllAsync() => _repo.GetWithdrawalRequestsAllAsync();
        public Task<WithdrawalRequest?> GetWithdrawalRequestByIdAsync(Guid idWithdrawalRequest) => _repo.GetWithdrawalRequestByIdAsync(idWithdrawalRequest);
        public Task<Guid> InsertWithdrawalRequestAsync(WithdrawalRequest req) => _repo.InsertWithdrawalRequestAsync(req);
        public Task<int> UpdateWithdrawalRequestAsync(WithdrawalRequest req) => _repo.UpdateWithdrawalRequestAsync(req);
        public Task<int> DeleteWithdrawalRequestAsync(Guid idWithdrawalRequest) => _repo.DeleteWithdrawalRequestAsync(idWithdrawalRequest);

        public Task<IEnumerable<Payout>> GetPayoutsAllAsync() => _repo.GetPayoutsAllAsync();
        public Task<Payout?> GetPayoutByIdAsync(Guid idPayout) => _repo.GetPayoutByIdAsync(idPayout);
        public Task<Guid> InsertPayoutAsync(Payout payout) => _repo.InsertPayoutAsync(payout);
        public Task<int> UpdatePayoutAsync(Payout payout) => _repo.UpdatePayoutAsync(payout);
        public Task<int> DeletePayoutAsync(Guid idPayout) => _repo.DeletePayoutAsync(idPayout);

        private static bool IsPaidStatus(string? status)
        {
            var normalized = status?.Trim().ToLowerInvariant() ?? string.Empty;
            return normalized.Contains("paid")
                || normalized.Contains("pago")
                || normalized.Contains("success")
                || normalized.Contains("succeeded")
                || normalized.Contains("completed")
                || normalized.Contains("conclu");
        }

        private static bool IsPendingStatus(string? status)
        {
            var normalized = status?.Trim().ToLowerInvariant() ?? string.Empty;
            return normalized.Contains("pending")
                || normalized.Contains("pendente")
                || normalized.Contains("processing")
                || normalized.Contains("hold")
                || normalized.Contains("await");
        }
    }
}
