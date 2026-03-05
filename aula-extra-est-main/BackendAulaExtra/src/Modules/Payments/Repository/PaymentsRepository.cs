using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Payments.Models;
using Npgsql;

namespace ConfidantPostgreSQL.Modules.Payments.Repository
{
    public class PaymentsRepository : IPaymentsRepository
    {
        private readonly string _connectionString;

        public PaymentsRepository(string connectionString)
        {
            _connectionString = connectionString;
        }

        // WALLETS
        public async Task<IEnumerable<Wallet>> GetWalletsAllAsync()
        {
            var list = new List<Wallet>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_wallets_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapWallet(reader));
            return list;
        }

        public async Task<Wallet?> GetWalletByIdAsync(Guid idWallet)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_wallets_select_details01(@id_wallet);";
            cmd.Parameters.AddWithValue("id_wallet", idWallet);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapWallet(reader);
        }

        public async Task<Guid> InsertWalletAsync(Wallet wallet)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_wallets_insert(@owner_type, @owner_user_id, @balance, @hold_amount, @currency, @created_at, @updated_at);";
            cmd.Parameters.AddWithValue("owner_type", (object?)wallet.OwnerType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("owner_user_id", wallet.OwnerUserId);
            cmd.Parameters.AddWithValue("balance", (object?)wallet.Balance ?? DBNull.Value);
            cmd.Parameters.AddWithValue("hold_amount", (object?)wallet.HoldAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("currency", (object?)wallet.Currency ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)wallet.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)wallet.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateWalletAsync(Wallet wallet)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_wallets_update(@id_wallet, @owner_type, @owner_user_id, @balance, @hold_amount, @currency);";
            cmd.Parameters.AddWithValue("id_wallet", wallet.IdWallet);
            cmd.Parameters.AddWithValue("owner_type", (object?)wallet.OwnerType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("owner_user_id", wallet.OwnerUserId);
            cmd.Parameters.AddWithValue("balance", (object?)wallet.Balance ?? DBNull.Value);
            cmd.Parameters.AddWithValue("hold_amount", (object?)wallet.HoldAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("currency", (object?)wallet.Currency ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteWalletAsync(Guid idWallet)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_wallets_delete(@id_wallet);";
            cmd.Parameters.AddWithValue("id_wallet", idWallet);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // TRANSACTIONS
        public async Task<IEnumerable<Transaction>> GetTransactionsAllAsync()
        {
            var list = new List<Transaction>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_transactions_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapTransaction(reader));
            return list;
        }

        public async Task<Transaction?> GetTransactionByIdAsync(Guid idTransaction)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_transactions_select_details01(@id_transaction);";
            cmd.Parameters.AddWithValue("id_transaction", idTransaction);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapTransaction(reader);
        }

        public async Task<Guid> InsertTransactionAsync(Transaction tx)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_transactions_insert(@wallet_id, @transaction_type, @amount, @balance_before, @balance_after, @related_id, @status, @created_at);";
            cmd.Parameters.AddWithValue("wallet_id", tx.WalletId);
            cmd.Parameters.AddWithValue("transaction_type", (object?)tx.TransactionType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", tx.Amount);
            cmd.Parameters.AddWithValue("balance_before", (object?)tx.BalanceBefore ?? DBNull.Value);
            cmd.Parameters.AddWithValue("balance_after", (object?)tx.BalanceAfter ?? DBNull.Value);
            cmd.Parameters.AddWithValue("related_id", (object?)tx.RelatedId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)tx.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)tx.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateTransactionAsync(Transaction tx)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_transactions_update(@id_transaction, @wallet_id, @transaction_type, @amount, @balance_before, @balance_after, @related_id, @status, @created_at);";
            cmd.Parameters.AddWithValue("id_transaction", tx.IdTransaction);
            cmd.Parameters.AddWithValue("wallet_id", tx.WalletId);
            cmd.Parameters.AddWithValue("transaction_type", (object?)tx.TransactionType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", tx.Amount);
            cmd.Parameters.AddWithValue("balance_before", (object?)tx.BalanceBefore ?? DBNull.Value);
            cmd.Parameters.AddWithValue("balance_after", (object?)tx.BalanceAfter ?? DBNull.Value);
            cmd.Parameters.AddWithValue("related_id", (object?)tx.RelatedId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)tx.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)tx.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteTransactionAsync(Guid idTransaction)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_transactions_delete(@id_transaction);";
            cmd.Parameters.AddWithValue("id_transaction", idTransaction);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // PAYMENT METHODS
        public async Task<IEnumerable<PaymentMethod>> GetPaymentMethodsAllAsync()
        {
            var list = new List<PaymentMethod>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_payment_methods_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapPaymentMethod(reader));
            return list;
        }

        public async Task<PaymentMethod?> GetPaymentMethodByIdAsync(Guid idPaymentMethod)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_payment_methods_select_details01(@id_payment_method);";
            cmd.Parameters.AddWithValue("id_payment_method", idPaymentMethod);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapPaymentMethod(reader);
        }

        public async Task<Guid> InsertPaymentMethodAsync(PaymentMethod method)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_payment_methods_insert(@owner_type, @owner_user_id, @method_type, @masked_details, @provider_token, @created_at);";
            cmd.Parameters.AddWithValue("owner_type", (object?)method.OwnerType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("owner_user_id", method.OwnerUserId);
            cmd.Parameters.AddWithValue("method_type", (object?)method.MethodType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("masked_details", (object?)method.MaskedDetails ?? DBNull.Value);
            cmd.Parameters.AddWithValue("provider_token", (object?)method.ProviderToken ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)method.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdatePaymentMethodAsync(PaymentMethod method)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_payment_methods_update(@id_payment_method, @owner_type, @owner_user_id, @method_type, @masked_details, @provider_token, @created_at);";
            cmd.Parameters.AddWithValue("id_payment_method", method.IdPaymentMethod);
            cmd.Parameters.AddWithValue("owner_type", (object?)method.OwnerType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("owner_user_id", method.OwnerUserId);
            cmd.Parameters.AddWithValue("method_type", (object?)method.MethodType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("masked_details", (object?)method.MaskedDetails ?? DBNull.Value);
            cmd.Parameters.AddWithValue("provider_token", (object?)method.ProviderToken ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)method.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeletePaymentMethodAsync(Guid idPaymentMethod)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_payment_methods_delete(@id_payment_method);";
            cmd.Parameters.AddWithValue("id_payment_method", idPaymentMethod);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // PAYMENT PROVIDERS
        public async Task<IEnumerable<PaymentProvider>> GetPaymentProvidersAllAsync()
        {
            var list = new List<PaymentProvider>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_payment_providers_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapPaymentProvider(reader));
            return list;
        }

        public async Task<PaymentProvider?> GetPaymentProviderByIdAsync(Guid idPaymentProvider)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_payment_providers_select_details01(@id_payment_provider);";
            cmd.Parameters.AddWithValue("id_payment_provider", idPaymentProvider);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapPaymentProvider(reader);
        }

        public async Task<Guid> InsertPaymentProviderAsync(PaymentProvider provider)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_payment_providers_insert(@name, @config_info);";
            cmd.Parameters.AddWithValue("name", (object?)provider.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("config_info", (object?)provider.ConfigInfo ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdatePaymentProviderAsync(PaymentProvider provider)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_payment_providers_update(@id_payment_provider, @name, @config_info);";
            cmd.Parameters.AddWithValue("id_payment_provider", provider.IdPaymentProvider);
            cmd.Parameters.AddWithValue("name", (object?)provider.Name ?? DBNull.Value);
            cmd.Parameters.AddWithValue("config_info", (object?)provider.ConfigInfo ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeletePaymentProviderAsync(Guid idPaymentProvider)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_payment_providers_delete(@id_payment_provider);";
            cmd.Parameters.AddWithValue("id_payment_provider", idPaymentProvider);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // WITHDRAWAL POLICIES
        public async Task<IEnumerable<WithdrawalPolicy>> GetWithdrawalPoliciesAllAsync()
        {
            var list = new List<WithdrawalPolicy>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_withdrawal_policies_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapWithdrawalPolicy(reader));
            return list;
        }

        public async Task<WithdrawalPolicy?> GetWithdrawalPolicyByIdAsync(Guid idWithdrawalPolicy)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_withdrawal_policies_select_details01(@id_withdrawal_policy);";
            cmd.Parameters.AddWithValue("id_withdrawal_policy", idWithdrawalPolicy);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapWithdrawalPolicy(reader);
        }

        public async Task<Guid> InsertWithdrawalPolicyAsync(WithdrawalPolicy policy)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_withdrawal_policies_insert(@payment_provider_id, @min_amount, @min_balance_after, @fixed_fee, @percent_fee, @active, @effective_from, @effective_to, @note);";
            cmd.Parameters.AddWithValue("payment_provider_id", (object?)policy.PaymentProviderId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("min_amount", (object?)policy.MinAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("min_balance_after", (object?)policy.MinBalanceAfter ?? DBNull.Value);
            cmd.Parameters.AddWithValue("fixed_fee", (object?)policy.FixedFee ?? DBNull.Value);
            cmd.Parameters.AddWithValue("percent_fee", (object?)policy.PercentFee ?? DBNull.Value);
            cmd.Parameters.AddWithValue("active", (object?)policy.Active ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_from", (object?)policy.EffectiveFrom ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_to", (object?)policy.EffectiveTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("note", (object?)policy.Note ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateWithdrawalPolicyAsync(WithdrawalPolicy policy)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_withdrawal_policies_update(@id_withdrawal_policy, @payment_provider_id, @min_amount, @min_balance_after, @fixed_fee, @percent_fee, @active, @effective_from, @effective_to, @note);";
            cmd.Parameters.AddWithValue("id_withdrawal_policy", policy.IdWithdrawalPolicy);
            cmd.Parameters.AddWithValue("payment_provider_id", (object?)policy.PaymentProviderId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("min_amount", (object?)policy.MinAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("min_balance_after", (object?)policy.MinBalanceAfter ?? DBNull.Value);
            cmd.Parameters.AddWithValue("fixed_fee", (object?)policy.FixedFee ?? DBNull.Value);
            cmd.Parameters.AddWithValue("percent_fee", (object?)policy.PercentFee ?? DBNull.Value);
            cmd.Parameters.AddWithValue("active", (object?)policy.Active ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_from", (object?)policy.EffectiveFrom ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_to", (object?)policy.EffectiveTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("note", (object?)policy.Note ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteWithdrawalPolicyAsync(Guid idWithdrawalPolicy)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_withdrawal_policies_delete(@id_withdrawal_policy);";
            cmd.Parameters.AddWithValue("id_withdrawal_policy", idWithdrawalPolicy);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // TOPUPS
        public async Task<IEnumerable<Topup>> GetTopupsAllAsync()
        {
            var list = new List<Topup>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_topups_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapTopup(reader));
            return list;
        }

        public async Task<Topup?> GetTopupByIdAsync(Guid idTopup)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_topups_select_details01(@id_topup);";
            cmd.Parameters.AddWithValue("id_topup", idTopup);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapTopup(reader);
        }

        public async Task<Guid> InsertTopupAsync(Topup topup)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_topups_insert(@wallet_id, @payment_method_id, @amount, @provider_reference, @topup_type, @status, @created_at);";
            cmd.Parameters.AddWithValue("wallet_id", topup.WalletId);
            cmd.Parameters.AddWithValue("payment_method_id", (object?)topup.PaymentMethodId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", topup.Amount);
            cmd.Parameters.AddWithValue("provider_reference", (object?)topup.ProviderReference ?? DBNull.Value);
            cmd.Parameters.AddWithValue("topup_type", (object?)topup.TopupType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)topup.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)topup.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateTopupAsync(Topup topup)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_topups_update(@id_topup, @wallet_id, @payment_method_id, @amount, @provider_reference, @topup_type, @status, @created_at);";
            cmd.Parameters.AddWithValue("id_topup", topup.IdTopup);
            cmd.Parameters.AddWithValue("wallet_id", topup.WalletId);
            cmd.Parameters.AddWithValue("payment_method_id", (object?)topup.PaymentMethodId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", topup.Amount);
            cmd.Parameters.AddWithValue("provider_reference", (object?)topup.ProviderReference ?? DBNull.Value);
            cmd.Parameters.AddWithValue("topup_type", (object?)topup.TopupType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)topup.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)topup.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteTopupAsync(Guid idTopup)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_topups_delete(@id_topup);";
            cmd.Parameters.AddWithValue("id_topup", idTopup);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // REFUNDS
        public async Task<IEnumerable<Refund>> GetRefundsAllAsync()
        {
            var list = new List<Refund>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_refunds_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapRefund(reader));
            return list;
        }

        public async Task<Refund?> GetRefundByIdAsync(Guid idRefund)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_refunds_select_details01(@id_refund);";
            cmd.Parameters.AddWithValue("id_refund", idRefund);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapRefund(reader);
        }

        public async Task<Guid> InsertRefundAsync(Refund refund)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_refunds_insert(@transaction_id, @to_wallet_id, @amount, @status, @created_at);";
            cmd.Parameters.AddWithValue("transaction_id", refund.TransactionId);
            cmd.Parameters.AddWithValue("to_wallet_id", refund.ToWalletId);
            cmd.Parameters.AddWithValue("amount", (object?)refund.Amount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)refund.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)refund.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateRefundAsync(Refund refund)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_refunds_update(@id_refund, @transaction_id, @to_wallet_id, @amount, @status, @created_at);";
            cmd.Parameters.AddWithValue("id_refund", refund.IdRefund);
            cmd.Parameters.AddWithValue("transaction_id", refund.TransactionId);
            cmd.Parameters.AddWithValue("to_wallet_id", refund.ToWalletId);
            cmd.Parameters.AddWithValue("amount", (object?)refund.Amount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)refund.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)refund.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteRefundAsync(Guid idRefund)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_refunds_delete(@id_refund);";
            cmd.Parameters.AddWithValue("id_refund", idRefund);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // DISPUTES
        public async Task<IEnumerable<Dispute>> GetDisputesAllAsync()
        {
            var list = new List<Dispute>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_disputes_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapDispute(reader));
            return list;
        }

        public async Task<Dispute?> GetDisputeByIdAsync(Guid idDispute)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_disputes_select_details01(@id_dispute);";
            cmd.Parameters.AddWithValue("id_dispute", idDispute);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapDispute(reader);
        }

        public async Task<Guid> InsertDisputeAsync(Dispute dispute)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_disputes_insert(@transaction_id, @raised_by_user_id, @reason, @status, @resolution_note, @created_at);";
            cmd.Parameters.AddWithValue("transaction_id", dispute.TransactionId);
            cmd.Parameters.AddWithValue("raised_by_user_id", (object?)dispute.RaisedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reason", (object?)dispute.Reason ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)dispute.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("resolution_note", (object?)dispute.ResolutionNote ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)dispute.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateDisputeAsync(Dispute dispute)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_disputes_update(@id_dispute, @transaction_id, @raised_by_user_id, @reason, @status, @resolution_note, @created_at);";
            cmd.Parameters.AddWithValue("id_dispute", dispute.IdDispute);
            cmd.Parameters.AddWithValue("transaction_id", dispute.TransactionId);
            cmd.Parameters.AddWithValue("raised_by_user_id", (object?)dispute.RaisedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reason", (object?)dispute.Reason ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)dispute.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("resolution_note", (object?)dispute.ResolutionNote ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)dispute.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteDisputeAsync(Guid idDispute)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_disputes_delete(@id_dispute);";
            cmd.Parameters.AddWithValue("id_dispute", idDispute);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // COMMISSION RULES
        public async Task<IEnumerable<CommissionRule>> GetCommissionRulesAllAsync()
        {
            var list = new List<CommissionRule>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_commission_rules_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapCommissionRule(reader));
            return list;
        }

        public async Task<CommissionRule?> GetCommissionRuleByIdAsync(Guid idCommissionRule)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_commission_rules_select_details01(@id_commission_rule);";
            cmd.Parameters.AddWithValue("id_commission_rule", idCommissionRule);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapCommissionRule(reader);
        }

        public async Task<Guid> InsertCommissionRuleAsync(CommissionRule rule)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_commission_rules_insert(@id_professor, @percent, @fixed_fee, @applies_to, @effective_from, @effective_to);";
            cmd.Parameters.AddWithValue("id_professor", (object?)rule.IdProfessor ?? DBNull.Value);
            cmd.Parameters.AddWithValue("percent", (object?)rule.Percent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("fixed_fee", (object?)rule.FixedFee ?? DBNull.Value);
            cmd.Parameters.AddWithValue("applies_to", (object?)rule.AppliesTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_from", (object?)rule.EffectiveFrom ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_to", (object?)rule.EffectiveTo ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateCommissionRuleAsync(CommissionRule rule)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_commission_rules_update(@id_commission_rule, @id_professor, @percent, @fixed_fee, @applies_to, @effective_from, @effective_to);";
            cmd.Parameters.AddWithValue("id_commission_rule", rule.IdCommissionRule);
            cmd.Parameters.AddWithValue("id_professor", (object?)rule.IdProfessor ?? DBNull.Value);
            cmd.Parameters.AddWithValue("percent", (object?)rule.Percent ?? DBNull.Value);
            cmd.Parameters.AddWithValue("fixed_fee", (object?)rule.FixedFee ?? DBNull.Value);
            cmd.Parameters.AddWithValue("applies_to", (object?)rule.AppliesTo ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_from", (object?)rule.EffectiveFrom ?? DBNull.Value);
            cmd.Parameters.AddWithValue("effective_to", (object?)rule.EffectiveTo ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteCommissionRuleAsync(Guid idCommissionRule)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_commission_rules_delete(@id_commission_rule);";
            cmd.Parameters.AddWithValue("id_commission_rule", idCommissionRule);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // RESERVATION PAYMENTS
        public async Task<IEnumerable<ReservationPayment>> GetReservationPaymentsAllAsync()
        {
            var list = new List<ReservationPayment>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_reservation_payments_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapReservationPayment(reader));
            return list;
        }

        public async Task<ReservationPayment?> GetReservationPaymentByIdAsync(Guid idReservationPayment)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_reservation_payments_select_details01(@id_reservation_payment);";
            cmd.Parameters.AddWithValue("id_reservation_payment", idReservationPayment);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapReservationPayment(reader);
        }

        public async Task<Guid> InsertReservationPaymentAsync(ReservationPayment rp)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_reservation_payments_insert(@reservation_id, @payer_wallet_id, @transaction_id, @commission_rule_id, @amount, @status, @created_at);";
            cmd.Parameters.AddWithValue("reservation_id", rp.ReservationId);
            cmd.Parameters.AddWithValue("payer_wallet_id", rp.PayerWalletId);
            cmd.Parameters.AddWithValue("transaction_id", (object?)rp.TransactionId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("commission_rule_id", (object?)rp.CommissionRuleId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", (object?)rp.Amount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)rp.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)rp.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateReservationPaymentAsync(ReservationPayment rp)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_reservation_payments_update(@id_reservation_payment, @reservation_id, @payer_wallet_id, @transaction_id, @commission_rule_id, @amount, @status, @created_at);";
            cmd.Parameters.AddWithValue("id_reservation_payment", rp.IdReservationPayment);
            cmd.Parameters.AddWithValue("reservation_id", rp.ReservationId);
            cmd.Parameters.AddWithValue("payer_wallet_id", rp.PayerWalletId);
            cmd.Parameters.AddWithValue("transaction_id", (object?)rp.TransactionId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("commission_rule_id", (object?)rp.CommissionRuleId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", (object?)rp.Amount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)rp.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)rp.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteReservationPaymentAsync(Guid idReservationPayment)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_reservation_payments_delete(@id_reservation_payment);";
            cmd.Parameters.AddWithValue("id_reservation_payment", idReservationPayment);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // WITHDRAWAL REQUESTS
        public async Task<IEnumerable<WithdrawalRequest>> GetWithdrawalRequestsAllAsync()
        {
            var list = new List<WithdrawalRequest>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_withdrawal_requests_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapWithdrawalRequest(reader));
            return list;
        }

        public async Task<WithdrawalRequest?> GetWithdrawalRequestByIdAsync(Guid idWithdrawalRequest)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_withdrawal_requests_select_details01(@id_withdrawal_request);";
            cmd.Parameters.AddWithValue("id_withdrawal_request", idWithdrawalRequest);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapWithdrawalRequest(reader);
        }

        public async Task<Guid> InsertWithdrawalRequestAsync(WithdrawalRequest req)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_withdrawal_requests_insert(@wallet_id, @requested_amount, @fee_amount, @net_amount, @payment_method_id, @payment_provider_id, @withdrawal_policy_id, @status, @requested_at, @processed_at, @processed_by_user_id);";
            cmd.Parameters.AddWithValue("wallet_id", req.WalletId);
            cmd.Parameters.AddWithValue("requested_amount", (object?)req.RequestedAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("fee_amount", (object?)req.FeeAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("net_amount", (object?)req.NetAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("payment_method_id", (object?)req.PaymentMethodId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("payment_provider_id", (object?)req.PaymentProviderId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("withdrawal_policy_id", (object?)req.WithdrawalPolicyId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)req.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("requested_at", (object?)req.RequestedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("processed_at", (object?)req.ProcessedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("processed_by_user_id", (object?)req.ProcessedByUserId ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateWithdrawalRequestAsync(WithdrawalRequest req)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_withdrawal_requests_update(@id_withdrawal_request, @wallet_id, @requested_amount, @fee_amount, @net_amount, @payment_method_id, @payment_provider_id, @withdrawal_policy_id, @status, @requested_at, @processed_at, @processed_by_user_id);";
            cmd.Parameters.AddWithValue("id_withdrawal_request", req.IdWithdrawalRequest);
            cmd.Parameters.AddWithValue("wallet_id", req.WalletId);
            cmd.Parameters.AddWithValue("requested_amount", (object?)req.RequestedAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("fee_amount", (object?)req.FeeAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("net_amount", (object?)req.NetAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("payment_method_id", (object?)req.PaymentMethodId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("payment_provider_id", (object?)req.PaymentProviderId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("withdrawal_policy_id", (object?)req.WithdrawalPolicyId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)req.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("requested_at", (object?)req.RequestedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("processed_at", (object?)req.ProcessedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("processed_by_user_id", (object?)req.ProcessedByUserId ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteWithdrawalRequestAsync(Guid idWithdrawalRequest)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_withdrawal_requests_delete(@id_withdrawal_request);";
            cmd.Parameters.AddWithValue("id_withdrawal_request", idWithdrawalRequest);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // PAYOUTS
        public async Task<IEnumerable<Payout>> GetPayoutsAllAsync()
        {
            var list = new List<Payout>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_payouts_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapPayout(reader));
            return list;
        }

        public async Task<Payout?> GetPayoutByIdAsync(Guid idPayout)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_payouts_select_details01(@id_payout);";
            cmd.Parameters.AddWithValue("id_payout", idPayout);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapPayout(reader);
        }

        public async Task<Guid> InsertPayoutAsync(Payout payout)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_payouts_insert(@withdrawal_request_id, @transaction_id, @gross_amount, @provider_fee_amount, @platform_fee_amount, @net_amount, @status, @processed_at);";
            cmd.Parameters.AddWithValue("withdrawal_request_id", (object?)payout.WithdrawalRequestId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("transaction_id", (object?)payout.TransactionId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("gross_amount", (object?)payout.GrossAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("provider_fee_amount", (object?)payout.ProviderFeeAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("platform_fee_amount", (object?)payout.PlatformFeeAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("net_amount", (object?)payout.NetAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)payout.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("processed_at", (object?)payout.ProcessedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdatePayoutAsync(Payout payout)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_payouts_update(@id_payout, @withdrawal_request_id, @transaction_id, @gross_amount, @provider_fee_amount, @platform_fee_amount, @net_amount, @status, @processed_at);";
            cmd.Parameters.AddWithValue("id_payout", payout.IdPayout);
            cmd.Parameters.AddWithValue("withdrawal_request_id", (object?)payout.WithdrawalRequestId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("transaction_id", (object?)payout.TransactionId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("gross_amount", (object?)payout.GrossAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("provider_fee_amount", (object?)payout.ProviderFeeAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("platform_fee_amount", (object?)payout.PlatformFeeAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("net_amount", (object?)payout.NetAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)payout.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("processed_at", (object?)payout.ProcessedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeletePayoutAsync(Guid idPayout)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_payouts_delete(@id_payout);";
            cmd.Parameters.AddWithValue("id_payout", idPayout);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        // MAPPERS
        private static Wallet MapWallet(NpgsqlDataReader reader)
        {
            return new Wallet
            {
                IdWallet = reader.GetGuid(reader.GetOrdinal("id_wallet")),
                OwnerType = GetNullableString(reader, "owner_type"),
                OwnerUserId = reader.GetGuid(reader.GetOrdinal("owner_user_id")),
                Balance = GetNullableDecimal(reader, "balance"),
                HoldAmount = GetNullableDecimal(reader, "hold_amount"),
                Currency = GetNullableString(reader, "currency"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
            };
        }

        private static Transaction MapTransaction(NpgsqlDataReader reader)
        {
            return new Transaction
            {
                IdTransaction = reader.GetGuid(reader.GetOrdinal("id_transaction")),
                WalletId = reader.GetGuid(reader.GetOrdinal("wallet_id")),
                TransactionType = GetNullableString(reader, "transaction_type"),
                Amount = reader.GetFieldValue<decimal>(reader.GetOrdinal("amount")),
                BalanceBefore = GetNullableDecimal(reader, "balance_before"),
                BalanceAfter = GetNullableDecimal(reader, "balance_after"),
                RelatedId = GetNullableInt(reader, "related_id"),
                Status = GetNullableString(reader, "status"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static PaymentMethod MapPaymentMethod(NpgsqlDataReader reader)
        {
            return new PaymentMethod
            {
                IdPaymentMethod = reader.GetGuid(reader.GetOrdinal("id_payment_method")),
                OwnerType = GetNullableString(reader, "owner_type"),
                OwnerUserId = reader.GetGuid(reader.GetOrdinal("owner_user_id")),
                MethodType = GetNullableString(reader, "method_type"),
                MaskedDetails = GetNullableString(reader, "masked_details"),
                ProviderToken = GetNullableString(reader, "provider_token"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static PaymentProvider MapPaymentProvider(NpgsqlDataReader reader)
        {
            return new PaymentProvider
            {
                IdPaymentProvider = reader.GetGuid(reader.GetOrdinal("id_payment_provider")),
                Name = GetNullableString(reader, "name"),
                ConfigInfo = GetNullableString(reader, "config_info")
            };
        }

        private static WithdrawalPolicy MapWithdrawalPolicy(NpgsqlDataReader reader)
        {
            return new WithdrawalPolicy
            {
                IdWithdrawalPolicy = reader.GetGuid(reader.GetOrdinal("id_withdrawal_policy")),
                PaymentProviderId = GetNullableGuid(reader, "payment_provider_id"),
                MinAmount = GetNullableDecimal(reader, "min_amount"),
                MinBalanceAfter = GetNullableDecimal(reader, "min_balance_after"),
                FixedFee = GetNullableDecimal(reader, "fixed_fee"),
                PercentFee = GetNullableDecimal(reader, "percent_fee"),
                Active = GetNullableBool(reader, "active"),
                EffectiveFrom = GetNullableDateTime(reader, "effective_from"),
                EffectiveTo = GetNullableDateTime(reader, "effective_to"),
                Note = GetNullableString(reader, "note")
            };
        }

        private static Topup MapTopup(NpgsqlDataReader reader)
        {
            return new Topup
            {
                IdTopup = reader.GetGuid(reader.GetOrdinal("id_topup")),
                WalletId = reader.GetGuid(reader.GetOrdinal("wallet_id")),
                PaymentMethodId = GetNullableGuid(reader, "payment_method_id"),
                Amount = reader.GetFieldValue<decimal>(reader.GetOrdinal("amount")),
                ProviderReference = GetNullableString(reader, "provider_reference"),
                TopupType = GetNullableString(reader, "topup_type"),
                Status = GetNullableString(reader, "status"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static Refund MapRefund(NpgsqlDataReader reader)
        {
            return new Refund
            {
                IdRefund = reader.GetGuid(reader.GetOrdinal("id_refund")),
                TransactionId = reader.GetGuid(reader.GetOrdinal("transaction_id")),
                ToWalletId = reader.GetGuid(reader.GetOrdinal("to_wallet_id")),
                Amount = GetNullableDecimal(reader, "amount"),
                Status = GetNullableString(reader, "status"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static Dispute MapDispute(NpgsqlDataReader reader)
        {
            return new Dispute
            {
                IdDispute = reader.GetGuid(reader.GetOrdinal("id_dispute")),
                TransactionId = reader.GetGuid(reader.GetOrdinal("transaction_id")),
                RaisedByUserId = GetNullableGuid(reader, "raised_by_user_id"),
                Reason = GetNullableString(reader, "reason"),
                Status = GetNullableString(reader, "status"),
                ResolutionNote = GetNullableString(reader, "resolution_note"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static CommissionRule MapCommissionRule(NpgsqlDataReader reader)
        {
            return new CommissionRule
            {
                IdCommissionRule = reader.GetGuid(reader.GetOrdinal("id_commission_rule")),
                IdProfessor = GetNullableGuid(reader, "id_professor"),
                Percent = GetNullableDecimal(reader, "percent"),
                FixedFee = GetNullableDecimal(reader, "fixed_fee"),
                AppliesTo = GetNullableString(reader, "applies_to"),
                EffectiveFrom = GetNullableDateTime(reader, "effective_from"),
                EffectiveTo = GetNullableDateTime(reader, "effective_to")
            };
        }

        private static ReservationPayment MapReservationPayment(NpgsqlDataReader reader)
        {
            return new ReservationPayment
            {
                IdReservationPayment = reader.GetGuid(reader.GetOrdinal("id_reservation_payment")),
                ReservationId = reader.GetGuid(reader.GetOrdinal("reservation_id")),
                PayerWalletId = reader.GetGuid(reader.GetOrdinal("payer_wallet_id")),
                TransactionId = GetNullableGuid(reader, "transaction_id"),
                CommissionRuleId = GetNullableGuid(reader, "commission_rule_id"),
                Amount = GetNullableDecimal(reader, "amount"),
                Status = GetNullableString(reader, "status"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static WithdrawalRequest MapWithdrawalRequest(NpgsqlDataReader reader)
        {
            return new WithdrawalRequest
            {
                IdWithdrawalRequest = reader.GetGuid(reader.GetOrdinal("id_withdrawal_request")),
                WalletId = reader.GetGuid(reader.GetOrdinal("wallet_id")),
                RequestedAmount = GetNullableDecimal(reader, "requested_amount"),
                FeeAmount = GetNullableDecimal(reader, "fee_amount"),
                NetAmount = GetNullableDecimal(reader, "net_amount"),
                PaymentMethodId = GetNullableGuid(reader, "payment_method_id"),
                PaymentProviderId = GetNullableGuid(reader, "payment_provider_id"),
                WithdrawalPolicyId = GetNullableGuid(reader, "withdrawal_policy_id"),
                Status = GetNullableString(reader, "status"),
                RequestedAt = GetNullableDateTime(reader, "requested_at"),
                ProcessedAt = GetNullableDateTime(reader, "processed_at"),
                ProcessedByUserId = GetNullableGuid(reader, "processed_by_user_id")
            };
        }

        private static Payout MapPayout(NpgsqlDataReader reader)
        {
            return new Payout
            {
                IdPayout = reader.GetGuid(reader.GetOrdinal("id_payout")),
                WithdrawalRequestId = GetNullableGuid(reader, "withdrawal_request_id"),
                TransactionId = GetNullableGuid(reader, "transaction_id"),
                GrossAmount = GetNullableDecimal(reader, "gross_amount"),
                ProviderFeeAmount = GetNullableDecimal(reader, "provider_fee_amount"),
                PlatformFeeAmount = GetNullableDecimal(reader, "platform_fee_amount"),
                NetAmount = GetNullableDecimal(reader, "net_amount"),
                Status = GetNullableString(reader, "status"),
                ProcessedAt = GetNullableDateTime(reader, "processed_at")
            };
        }

        private static string? GetNullableString(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetString(idx);
        }

        private static Guid? GetNullableGuid(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetGuid(idx);
        }

        private static int? GetNullableInt(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetInt32(idx);
        }

        private static decimal? GetNullableDecimal(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetFieldValue<decimal>(idx);
        }

        private static bool? GetNullableBool(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            return reader.IsDBNull(idx) ? null : reader.GetBoolean(idx);
        }

        private static DateTime? GetNullableDateTime(NpgsqlDataReader reader, string column)
        {
            var idx = reader.GetOrdinal(column);
            if (reader.IsDBNull(idx)) return null;
            try { return reader.GetFieldValue<DateTime>(idx); } catch { return null; }
        }
    }
}
