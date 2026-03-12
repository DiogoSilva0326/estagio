using System;
using System.Collections.Generic;
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
        public Task<Guid> InsertWalletAsync(Wallet wallet) => _repo.InsertWalletAsync(wallet);
        public Task<int> UpdateWalletAsync(Wallet wallet) => _repo.UpdateWalletAsync(wallet);
        public Task<int> DeleteWalletAsync(Guid idWallet) => _repo.DeleteWalletAsync(idWallet);

        public Task<IEnumerable<Transaction>> GetTransactionsAllAsync() => _repo.GetTransactionsAllAsync();
        public Task<Transaction?> GetTransactionByIdAsync(Guid idTransaction) => _repo.GetTransactionByIdAsync(idTransaction);
        public Task<Guid> InsertTransactionAsync(Transaction tx) => _repo.InsertTransactionAsync(tx);
        public Task<int> UpdateTransactionAsync(Transaction tx) => _repo.UpdateTransactionAsync(tx);
        public Task<int> DeleteTransactionAsync(Guid idTransaction) => _repo.DeleteTransactionAsync(idTransaction);

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
        public Task<int> UpdateTopupAsync(Topup topup) => _repo.UpdateTopupAsync(topup);
        public Task<int> DeleteTopupAsync(Guid idTopup) => _repo.DeleteTopupAsync(idTopup);

        public Task<IEnumerable<Refund>> GetRefundsAllAsync() => _repo.GetRefundsAllAsync();
        public Task<Refund?> GetRefundByIdAsync(Guid idRefund) => _repo.GetRefundByIdAsync(idRefund);
        public Task<Guid> InsertRefundAsync(Refund refund) => _repo.InsertRefundAsync(refund);
        public Task<int> UpdateRefundAsync(Refund refund) => _repo.UpdateRefundAsync(refund);
        public Task<int> DeleteRefundAsync(Guid idRefund) => _repo.DeleteRefundAsync(idRefund);

        public Task<IEnumerable<Dispute>> GetDisputesAllAsync() => _repo.GetDisputesAllAsync();
        public Task<Dispute?> GetDisputeByIdAsync(Guid idDispute) => _repo.GetDisputeByIdAsync(idDispute);
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
    }
}
