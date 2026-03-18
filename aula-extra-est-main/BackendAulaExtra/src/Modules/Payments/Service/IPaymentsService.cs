using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Payments.Models;

namespace ConfidantPostgreSQL.Modules.Payments.Service
{
    public interface IPaymentsService
    {
        Task<IEnumerable<Wallet>> GetWalletsAllAsync();
        Task<Wallet?> GetWalletByIdAsync(Guid idWallet);
        Task<Guid> InsertWalletAsync(Wallet wallet);
        Task<int> UpdateWalletAsync(Wallet wallet);
        Task<int> DeleteWalletAsync(Guid idWallet);

        Task<IEnumerable<Transaction>> GetTransactionsAllAsync();
        Task<Transaction?> GetTransactionByIdAsync(Guid idTransaction);
        Task<Guid> InsertTransactionAsync(Transaction tx);
        Task<int> UpdateTransactionAsync(Transaction tx);
        Task<int> DeleteTransactionAsync(Guid idTransaction);

        Task<IEnumerable<Invoice>> GetInvoicesAllAsync();
        Task<Invoice?> GetInvoiceByIdAsync(Guid idInvoice);
        Task<IEnumerable<Invoice>> GetInvoicesByUserIdAsync(Guid idUser);
        Task<Guid> InsertInvoiceAsync(Invoice invoice);
        Task<int> UpdateInvoiceAsync(Invoice invoice);
        Task<int> DeleteInvoiceAsync(Guid idInvoice);

        Task<IEnumerable<PaymentMethod>> GetPaymentMethodsAllAsync();
        Task<PaymentMethod?> GetPaymentMethodByIdAsync(Guid idPaymentMethod);
        Task<Guid> InsertPaymentMethodAsync(PaymentMethod method);
        Task<int> UpdatePaymentMethodAsync(PaymentMethod method);
        Task<int> DeletePaymentMethodAsync(Guid idPaymentMethod);

        Task<IEnumerable<PaymentProvider>> GetPaymentProvidersAllAsync();
        Task<PaymentProvider?> GetPaymentProviderByIdAsync(Guid idPaymentProvider);
        Task<Guid> InsertPaymentProviderAsync(PaymentProvider provider);
        Task<int> UpdatePaymentProviderAsync(PaymentProvider provider);
        Task<int> DeletePaymentProviderAsync(Guid idPaymentProvider);

        Task<IEnumerable<WithdrawalPolicy>> GetWithdrawalPoliciesAllAsync();
        Task<WithdrawalPolicy?> GetWithdrawalPolicyByIdAsync(Guid idWithdrawalPolicy);
        Task<Guid> InsertWithdrawalPolicyAsync(WithdrawalPolicy policy);
        Task<int> UpdateWithdrawalPolicyAsync(WithdrawalPolicy policy);
        Task<int> DeleteWithdrawalPolicyAsync(Guid idWithdrawalPolicy);

        Task<IEnumerable<Topup>> GetTopupsAllAsync();
        Task<Topup?> GetTopupByIdAsync(Guid idTopup);
        Task<Guid> InsertTopupAsync(Topup topup);
        Task<int> UpdateTopupAsync(Topup topup);
        Task<int> DeleteTopupAsync(Guid idTopup);

        Task<IEnumerable<Refund>> GetRefundsAllAsync();
        Task<Refund?> GetRefundByIdAsync(Guid idRefund);
        Task<Guid> InsertRefundAsync(Refund refund);
        Task<int> UpdateRefundAsync(Refund refund);
        Task<int> DeleteRefundAsync(Guid idRefund);

        Task<IEnumerable<Dispute>> GetDisputesAllAsync();
        Task<Dispute?> GetDisputeByIdAsync(Guid idDispute);
        Task<Guid> InsertDisputeAsync(Dispute dispute);
        Task<int> UpdateDisputeAsync(Dispute dispute);
        Task<int> DeleteDisputeAsync(Guid idDispute);

        Task<IEnumerable<CommissionRule>> GetCommissionRulesAllAsync();
        Task<CommissionRule?> GetCommissionRuleByIdAsync(Guid idCommissionRule);
        Task<Guid> InsertCommissionRuleAsync(CommissionRule rule);
        Task<int> UpdateCommissionRuleAsync(CommissionRule rule);
        Task<int> DeleteCommissionRuleAsync(Guid idCommissionRule);

        Task<IEnumerable<ReservationPayment>> GetReservationPaymentsAllAsync();
        Task<ReservationPayment?> GetReservationPaymentByIdAsync(Guid idReservationPayment);
        Task<Guid> InsertReservationPaymentAsync(ReservationPayment rp);
        Task<int> UpdateReservationPaymentAsync(ReservationPayment rp);
        Task<int> DeleteReservationPaymentAsync(Guid idReservationPayment);

        Task<IEnumerable<WithdrawalRequest>> GetWithdrawalRequestsAllAsync();
        Task<WithdrawalRequest?> GetWithdrawalRequestByIdAsync(Guid idWithdrawalRequest);
        Task<Guid> InsertWithdrawalRequestAsync(WithdrawalRequest req);
        Task<int> UpdateWithdrawalRequestAsync(WithdrawalRequest req);
        Task<int> DeleteWithdrawalRequestAsync(Guid idWithdrawalRequest);

        Task<IEnumerable<Payout>> GetPayoutsAllAsync();
        Task<Payout?> GetPayoutByIdAsync(Guid idPayout);
        Task<Guid> InsertPayoutAsync(Payout payout);
        Task<int> UpdatePayoutAsync(Payout payout);
        Task<int> DeletePayoutAsync(Guid idPayout);
    }
}
