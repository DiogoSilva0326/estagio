using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using ConfidantPostgreSQL.Modules.Payments.Models;
using Npgsql;
using NpgsqlTypes;

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

        public async Task<Wallet?> GetWalletByOwnerUserIdAsync(Guid ownerUserId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT *
                FROM public.wallets
                WHERE owner_user_id = @owner_user_id
                ORDER BY
                    CASE
                        WHEN LOWER(COALESCE(owner_type, '')) IN ('student', 'aluno') THEN 0
                        WHEN owner_type IS NULL THEN 1
                        ELSE 2
                    END,
                    updated_at DESC NULLS LAST,
                    created_at DESC NULLS LAST
                LIMIT 1;";
            cmd.Parameters.AddWithValue("owner_user_id", ownerUserId);
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

        public async Task<IEnumerable<Transaction>> GetTransactionsByWalletIdAsync(Guid walletId)
        {
            var list = new List<Transaction>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT *
                FROM public.transactions
                WHERE wallet_id = @wallet_id
                ORDER BY created_at DESC NULLS LAST, id_transaction DESC;";
            cmd.Parameters.AddWithValue("wallet_id", walletId);
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapTransaction(reader));
            return list;
        }

        public async Task<Guid> InsertTransactionAsync(Transaction tx)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
                        cmd.CommandText = "SELECT public.usp_transactions_insert(@wallet_id, @transaction_type, @amount, @balance_before, @balance_after, @related_id, @related_entity_id, @status, @created_at);";
            cmd.Parameters.AddWithValue("wallet_id", tx.WalletId);
            cmd.Parameters.AddWithValue("transaction_type", (object?)tx.TransactionType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", tx.Amount);
            cmd.Parameters.AddWithValue("balance_before", (object?)tx.BalanceBefore ?? DBNull.Value);
            cmd.Parameters.AddWithValue("balance_after", (object?)tx.BalanceAfter ?? DBNull.Value);
            cmd.Parameters.AddWithValue("related_id", (object?)tx.RelatedId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("related_entity_id", (object?)tx.RelatedEntityId ?? DBNull.Value);
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
            cmd.CommandText = "SELECT public.usp_transactions_update(@id_transaction, @wallet_id, @transaction_type, @amount, @balance_before, @balance_after, @related_id, @related_entity_id, @status, @created_at);";
            cmd.Parameters.AddWithValue("id_transaction", tx.IdTransaction);
            cmd.Parameters.AddWithValue("wallet_id", tx.WalletId);
            cmd.Parameters.AddWithValue("transaction_type", (object?)tx.TransactionType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", tx.Amount);
            cmd.Parameters.AddWithValue("balance_before", (object?)tx.BalanceBefore ?? DBNull.Value);
            cmd.Parameters.AddWithValue("balance_after", (object?)tx.BalanceAfter ?? DBNull.Value);
            cmd.Parameters.AddWithValue("related_id", (object?)tx.RelatedId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("related_entity_id", (object?)tx.RelatedEntityId ?? DBNull.Value);
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

        // INVOICES
        public async Task<IEnumerable<Invoice>> GetInvoicesAllAsync()
        {
            var list = new List<Invoice>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_invoices_select_all01();";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapInvoice(reader));
            return list;
        }

        public async Task<Invoice?> GetInvoiceByIdAsync(Guid idInvoice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_invoices_select_details01(@id_invoice);";
            cmd.Parameters.AddWithValue("id_invoice", idInvoice);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;
            return MapInvoice(reader);
        }

        public async Task<IEnumerable<Invoice>> GetInvoicesByUserIdAsync(Guid idUser)
        {
            var list = new List<Invoice>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT * FROM public.usp_invoices_select_by_user01(@id_user);";
            cmd.Parameters.AddWithValue("id_user", idUser);
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync()) list.Add(MapInvoice(reader));
            return list;
        }

        public async Task<IEnumerable<StudentPaymentHistoryItemDto>> GetStudentPaymentHistoryAsync(Guid idUser)
        {
            var list = new List<StudentPaymentHistoryItemDto>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT *
                FROM (
                    SELECT
                        rp.id_reservation_payment AS id,
                        'reservation_payment'::text AS payment_source,
                        COALESCE(
                            NULLIF(pu.display_name, ''),
                            NULLIF(TRIM(COALESCE(pu.first_name, '') || ' ' || COALESCE(pu.last_name, '')), ''),
                            NULLIF(pu.username, ''),
                            'Professor'
                        ) AS tutor_name,
                        COALESCE(NULLIF(d.nome, ''), NULLIF(c.name, ''), NULLIF(l.title, ''), 'Aula') AS subject,
                        COALESCE(inv.issued_at, rp.created_at, r.created_at, l.scheduled_start) AS payment_date,
                        COALESCE(inv.total_amount, rp.amount, rp.gross_amount, 0) AS amount,
                        COALESCE(NULLIF(inv.at_status, ''), NULLIF(rp.status, ''), NULLIF(r.status, ''), 'pendente') AS status,
                        inv.pdf_url AS receipt_url,
                        COALESCE(inv.document_reference, rp.id_reservation_payment::text) AS reference
                    FROM public.reservation_payments rp
                    INNER JOIN public.reservations r ON r.id_reservation = rp.reservation_id
                    INNER JOIN public.lessons l ON l.id_lesson = r.id_lesson
                    LEFT JOIN public.courses c ON c.id_course = l.id_course
                    LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
                    LEFT JOIN public.professors p ON p.id_professor = COALESCE(l.id_professor, c.id_professor)
                    LEFT JOIN public.users pu ON pu.id_user = p.id_user
                    LEFT JOIN LATERAL (
                        SELECT i.document_reference, i.pdf_url, i.total_amount, i.issued_at, i.at_status
                        FROM public.invoices i
                        WHERE i.id_transaction = rp.transaction_id
                          AND i.id_user = r.id_user
                        ORDER BY i.issued_at DESC NULLS LAST
                        LIMIT 1
                    ) inv ON TRUE
                    WHERE r.id_user = @id_user

                    UNION ALL

                    SELECT
                        t.id_topup AS id,
                        'topup'::text AS payment_source,
                        'Aula Extra' AS tutor_name,
                        COALESCE(NULLIF(t.topup_type, ''), 'Top-up de conta') AS subject,
                        t.created_at AS payment_date,
                        COALESCE(t.amount, 0) AS amount,
                        COALESCE(NULLIF(t.status, ''), 'paid') AS status,
                        NULL::text AS receipt_url,
                        COALESCE(NULLIF(t.provider_reference, ''), t.id_topup::text) AS reference
                    FROM public.topups t
                    INNER JOIN public.wallets w ON w.id_wallet = t.wallet_id
                    WHERE w.owner_user_id = @id_user
                ) history
                ORDER BY payment_date DESC NULLS LAST, id DESC;";
            cmd.Parameters.AddWithValue("id_user", idUser);
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new StudentPaymentHistoryItemDto
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    PaymentSource = GetNullableString(reader, "payment_source") ?? "reservation_payment",
                    TutorName = GetNullableString(reader, "tutor_name") ?? string.Empty,
                    Subject = GetNullableString(reader, "subject") ?? string.Empty,
                    Date = GetNullableDateTime(reader, "payment_date"),
                    Amount = GetNullableDecimal(reader, "amount") ?? 0m,
                    Status = GetNullableString(reader, "status") ?? string.Empty,
                    ReceiptUrl = GetNullableString(reader, "receipt_url"),
                    Reference = GetNullableString(reader, "reference")
                });
            }

            return list;
        }

        public async Task<IEnumerable<AdminPaymentOverviewItemDto>> GetAdminPaymentOverviewAsync()
        {
            var list = new List<AdminPaymentOverviewItemDto>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT
                    rp.id_reservation_payment AS id,
                    COALESCE(
                        NULLIF(su.display_name, ''),
                        NULLIF(TRIM(COALESCE(su.first_name, '') || ' ' || COALESCE(su.last_name, '')), ''),
                        NULLIF(su.username, ''),
                        'Aluno'
                    ) AS student_name,
                    COALESCE(
                        NULLIF(tu.display_name, ''),
                        NULLIF(TRIM(COALESCE(tu.first_name, '') || ' ' || COALESCE(tu.last_name, '')), ''),
                        NULLIF(tu.username, ''),
                        'Professor'
                    ) AS tutor_name,
                    COALESCE(NULLIF(d.nome, ''), NULLIF(c.name, ''), NULLIF(l.title, ''), 'Aula') AS subject,
                    COALESCE(inv.issued_at, tx.created_at, rp.created_at, r.created_at, l.scheduled_start) AS payment_date,
                    COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) AS gross_amount,
                    COALESCE(
                        rp.platform_fee_amount,
                        ROUND((COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) * COALESCE(cr.percent, 0) / 100.0) + COALESCE(cr.fixed_fee, 0), 2)
                    ) AS platform_fee_amount,
                    COALESCE(
                        rp.teacher_net_amount,
                        COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) - COALESCE(
                            rp.platform_fee_amount,
                            ROUND((COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) * COALESCE(cr.percent, 0) / 100.0) + COALESCE(cr.fixed_fee, 0), 2)
                        )
                    ) AS net_amount,
                    COALESCE(NULLIF(inv.at_status, ''), NULLIF(rp.status, ''), NULLIF(tx.status, ''), NULLIF(r.status, ''), 'pendente') AS status,
                    COALESCE(NULLIF(inv.document_reference, ''), rp.id_reservation_payment::text) AS reference,
                    COALESCE(NULLIF(sw.currency, ''), NULLIF(tw.currency, ''), 'EUR') AS currency
                FROM public.reservation_payments rp
                INNER JOIN public.reservations r ON r.id_reservation = rp.reservation_id
                INNER JOIN public.lessons l ON l.id_lesson = r.id_lesson
                LEFT JOIN public.courses c ON c.id_course = l.id_course
                LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
                INNER JOIN public.users su ON su.id_user = r.id_user
                LEFT JOIN public.professors p ON p.id_professor = COALESCE(l.id_professor, c.id_professor)
                LEFT JOIN public.users tu ON tu.id_user = p.id_user
                LEFT JOIN public.transactions tx ON tx.id_transaction = rp.transaction_id
                LEFT JOIN public.commission_rules cr ON cr.id_commission_rule = rp.commission_rule_id
                LEFT JOIN LATERAL (
                    SELECT i.document_reference, i.total_amount, i.issued_at, i.at_status
                    FROM public.invoices i
                    WHERE i.id_transaction = rp.transaction_id
                    ORDER BY i.issued_at DESC NULLS LAST
                    LIMIT 1
                ) inv ON TRUE
                LEFT JOIN LATERAL (
                    SELECT wallet.currency
                    FROM public.wallets wallet
                    WHERE wallet.owner_user_id = r.id_user
                    ORDER BY wallet.updated_at DESC NULLS LAST, wallet.created_at DESC NULLS LAST
                    LIMIT 1
                ) sw ON TRUE
                LEFT JOIN LATERAL (
                    SELECT wallet.currency
                    FROM public.wallets wallet
                    WHERE wallet.owner_user_id = p.id_user
                    ORDER BY wallet.updated_at DESC NULLS LAST, wallet.created_at DESC NULLS LAST
                    LIMIT 1
                ) tw ON TRUE
                ORDER BY COALESCE(inv.issued_at, tx.created_at, rp.created_at, r.created_at, l.scheduled_start) DESC NULLS LAST,
                         rp.id_reservation_payment DESC;";
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new AdminPaymentOverviewItemDto
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    StudentName = GetNullableString(reader, "student_name") ?? string.Empty,
                    TutorName = GetNullableString(reader, "tutor_name") ?? string.Empty,
                    Subject = GetNullableString(reader, "subject") ?? string.Empty,
                    PaymentDate = GetNullableDateTime(reader, "payment_date"),
                    GrossAmount = GetNullableDecimal(reader, "gross_amount") ?? 0m,
                    PlatformFeeAmount = GetNullableDecimal(reader, "platform_fee_amount") ?? 0m,
                    NetAmount = GetNullableDecimal(reader, "net_amount") ?? 0m,
                    Status = GetNullableString(reader, "status") ?? string.Empty,
                    Reference = GetNullableString(reader, "reference"),
                    Currency = GetNullableString(reader, "currency") ?? "EUR"
                });
            }

            return list;
        }

        public async Task<IEnumerable<ProfessorPaymentHistoryItemDto>> GetProfessorPaymentHistoryAsync(Guid idUser)
        {
            var list = new List<ProfessorPaymentHistoryItemDto>();
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT
                    rp.id_reservation_payment AS id,
                    rp.reservation_id,
                    rp.transaction_id,
                    COALESCE(
                        NULLIF(su.display_name, ''),
                        NULLIF(TRIM(COALESCE(su.first_name, '') || ' ' || COALESCE(su.last_name, '')), ''),
                        NULLIF(su.username, ''),
                        'Aluno'
                    ) AS student_name,
                    COALESCE(NULLIF(d.nome, ''), NULLIF(c.name, ''), NULLIF(l.title, ''), 'Aula') AS subject,
                    COALESCE(NULLIF(l.title, ''), NULLIF(c.name, ''), 'Aula') AS lesson_title,
                    COALESCE(r.start_time, l.scheduled_start) AS lesson_start,
                    COALESCE(r.end_time, l.scheduled_end) AS lesson_end,
                    COALESCE(inv.issued_at, tx.created_at, rp.created_at, r.created_at, l.scheduled_start) AS payment_date,
                    COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) AS gross_amount,
                    COALESCE(
                        rp.platform_fee_amount,
                        ROUND((COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) * COALESCE(cr.percent, 0) / 100.0) + COALESCE(cr.fixed_fee, 0), 2)
                    ) AS platform_fee_amount,
                    COALESCE(
                        rp.teacher_net_amount,
                        COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) - COALESCE(
                            rp.platform_fee_amount,
                            ROUND((COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) * COALESCE(cr.percent, 0) / 100.0) + COALESCE(cr.fixed_fee, 0), 2)
                        )
                    ) AS net_amount,
                    COALESCE(NULLIF(inv.at_status, ''), NULLIF(rp.status, ''), NULLIF(tx.status, ''), NULLIF(r.status, ''), 'pendente') AS status,
                    COALESCE(NULLIF(inv.document_reference, ''), rp.id_reservation_payment::text) AS reference,
                    COALESCE(NULLIF(w.currency, ''), 'EUR') AS currency
                FROM public.reservation_payments rp
                INNER JOIN public.reservations r ON r.id_reservation = rp.reservation_id
                INNER JOIN public.lessons l ON l.id_lesson = r.id_lesson
                LEFT JOIN public.courses c ON c.id_course = l.id_course
                LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
                INNER JOIN public.professors p ON p.id_professor = COALESCE(l.id_professor, c.id_professor)
                INNER JOIN public.users su ON su.id_user = r.id_user
                LEFT JOIN public.transactions tx ON tx.id_transaction = rp.transaction_id
                LEFT JOIN public.commission_rules cr ON cr.id_commission_rule = rp.commission_rule_id
                LEFT JOIN LATERAL (
                    SELECT i.document_reference, i.pdf_url, i.total_amount, i.issued_at, i.at_status
                    FROM public.invoices i
                    WHERE i.id_transaction = rp.transaction_id
                    ORDER BY i.issued_at DESC NULLS LAST
                    LIMIT 1
                ) inv ON TRUE
                LEFT JOIN LATERAL (
                    SELECT wallet.currency
                    FROM public.wallets wallet
                    WHERE wallet.owner_user_id = p.id_user
                    ORDER BY wallet.updated_at DESC NULLS LAST, wallet.created_at DESC NULLS LAST
                    LIMIT 1
                ) w ON TRUE
                WHERE p.id_user = @id_user
                ORDER BY COALESCE(inv.issued_at, tx.created_at, rp.created_at, r.created_at, l.scheduled_start) DESC NULLS LAST,
                         rp.id_reservation_payment DESC;";
            cmd.Parameters.AddWithValue("id_user", idUser);
            await using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                list.Add(new ProfessorPaymentHistoryItemDto
                {
                    Id = reader.GetGuid(reader.GetOrdinal("id")),
                    ReservationId = reader.GetGuid(reader.GetOrdinal("reservation_id")),
                    TransactionId = GetNullableGuid(reader, "transaction_id"),
                    StudentName = GetNullableString(reader, "student_name") ?? string.Empty,
                    Subject = GetNullableString(reader, "subject") ?? string.Empty,
                    LessonTitle = GetNullableString(reader, "lesson_title") ?? string.Empty,
                    LessonStart = GetNullableDateTime(reader, "lesson_start"),
                    LessonEnd = GetNullableDateTime(reader, "lesson_end"),
                    PaymentDate = GetNullableDateTime(reader, "payment_date"),
                    GrossAmount = GetNullableDecimal(reader, "gross_amount") ?? 0m,
                    PlatformFeeAmount = GetNullableDecimal(reader, "platform_fee_amount") ?? 0m,
                    NetAmount = GetNullableDecimal(reader, "net_amount") ?? 0m,
                    Status = GetNullableString(reader, "status") ?? string.Empty,
                    Reference = GetNullableString(reader, "reference"),
                    Currency = GetNullableString(reader, "currency") ?? "EUR"
                });
            }

            return list;
        }

        public async Task<ProfessorPaymentDetailsDto?> GetProfessorPaymentDetailsAsync(Guid idUser, Guid idReservationPayment)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"
                SELECT
                    rp.id_reservation_payment AS id,
                    rp.reservation_id,
                    rp.transaction_id,
                    COALESCE(
                        NULLIF(su.display_name, ''),
                        NULLIF(TRIM(COALESCE(su.first_name, '') || ' ' || COALESCE(su.last_name, '')), ''),
                        NULLIF(su.username, ''),
                        'Aluno'
                    ) AS student_name,
                    su.email AS student_email,
                    COALESCE(NULLIF(d.nome, ''), NULLIF(c.name, ''), NULLIF(l.title, ''), 'Aula') AS subject,
                    COALESCE(NULLIF(l.title, ''), NULLIF(c.name, ''), 'Aula') AS lesson_title,
                    COALESCE(r.start_time, l.scheduled_start) AS lesson_start,
                    COALESCE(r.end_time, l.scheduled_end) AS lesson_end,
                    COALESCE(inv.issued_at, tx.created_at, rp.created_at, r.created_at, l.scheduled_start) AS payment_date,
                    COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) AS gross_amount,
                    COALESCE(
                        rp.platform_fee_amount,
                        ROUND((COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) * COALESCE(cr.percent, 0) / 100.0) + COALESCE(cr.fixed_fee, 0), 2)
                    ) AS platform_fee_amount,
                    COALESCE(
                        rp.teacher_net_amount,
                        COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) - COALESCE(
                            rp.platform_fee_amount,
                            ROUND((COALESCE(rp.gross_amount, rp.amount, inv.total_amount, 0) * COALESCE(cr.percent, 0) / 100.0) + COALESCE(cr.fixed_fee, 0), 2)
                        )
                    ) AS net_amount,
                    cr.percent AS commission_percent,
                    cr.fixed_fee,
                    COALESCE(NULLIF(inv.at_status, ''), NULLIF(rp.status, ''), NULLIF(tx.status, ''), NULLIF(r.status, ''), 'pendente') AS status,
                    COALESCE(NULLIF(inv.document_reference, ''), rp.id_reservation_payment::text) AS reference,
                    inv.pdf_url AS receipt_url,
                    COALESCE(NULLIF(w.currency, ''), 'EUR') AS currency
                FROM public.reservation_payments rp
                INNER JOIN public.reservations r ON r.id_reservation = rp.reservation_id
                INNER JOIN public.lessons l ON l.id_lesson = r.id_lesson
                LEFT JOIN public.courses c ON c.id_course = l.id_course
                LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
                INNER JOIN public.professors p ON p.id_professor = COALESCE(l.id_professor, c.id_professor)
                INNER JOIN public.users su ON su.id_user = r.id_user
                LEFT JOIN public.transactions tx ON tx.id_transaction = rp.transaction_id
                LEFT JOIN public.commission_rules cr ON cr.id_commission_rule = rp.commission_rule_id
                LEFT JOIN LATERAL (
                    SELECT i.document_reference, i.pdf_url, i.total_amount, i.issued_at, i.at_status
                    FROM public.invoices i
                    WHERE i.id_transaction = rp.transaction_id
                    ORDER BY i.issued_at DESC NULLS LAST
                    LIMIT 1
                ) inv ON TRUE
                LEFT JOIN LATERAL (
                    SELECT wallet.currency
                    FROM public.wallets wallet
                    WHERE wallet.owner_user_id = p.id_user
                    ORDER BY wallet.updated_at DESC NULLS LAST, wallet.created_at DESC NULLS LAST
                    LIMIT 1
                ) w ON TRUE
                WHERE p.id_user = @id_user
                  AND rp.id_reservation_payment = @id_reservation_payment
                LIMIT 1;";
            cmd.Parameters.AddWithValue("id_user", idUser);
            cmd.Parameters.AddWithValue("id_reservation_payment", idReservationPayment);
            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new ProfessorPaymentDetailsDto
            {
                Id = reader.GetGuid(reader.GetOrdinal("id")),
                ReservationId = reader.GetGuid(reader.GetOrdinal("reservation_id")),
                TransactionId = GetNullableGuid(reader, "transaction_id"),
                StudentName = GetNullableString(reader, "student_name") ?? string.Empty,
                StudentEmail = GetNullableString(reader, "student_email"),
                Subject = GetNullableString(reader, "subject") ?? string.Empty,
                LessonTitle = GetNullableString(reader, "lesson_title") ?? string.Empty,
                LessonStart = GetNullableDateTime(reader, "lesson_start"),
                LessonEnd = GetNullableDateTime(reader, "lesson_end"),
                PaymentDate = GetNullableDateTime(reader, "payment_date"),
                GrossAmount = GetNullableDecimal(reader, "gross_amount") ?? 0m,
                PlatformFeeAmount = GetNullableDecimal(reader, "platform_fee_amount") ?? 0m,
                NetAmount = GetNullableDecimal(reader, "net_amount") ?? 0m,
                CommissionPercent = GetNullableDecimal(reader, "commission_percent"),
                FixedFee = GetNullableDecimal(reader, "fixed_fee"),
                Status = GetNullableString(reader, "status") ?? string.Empty,
                Reference = GetNullableString(reader, "reference"),
                ReceiptUrl = GetNullableString(reader, "receipt_url"),
                Currency = GetNullableString(reader, "currency") ?? "EUR"
            };
        }

        public async Task<Guid> InsertInvoiceAsync(Invoice invoice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_invoices_insert(@id_transaction, @id_user, @invoice_type, @document_reference, @pdf_url, @total_amount, @tax_amount, @issued_at, @related_invoice_id, @at_status);";
            cmd.Parameters.AddWithValue("id_transaction", invoice.IdTransaction);
            cmd.Parameters.AddWithValue("id_user", invoice.IdUser);
            cmd.Parameters.AddWithValue("invoice_type", (object?)invoice.InvoiceType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("document_reference", (object?)invoice.DocumentReference ?? DBNull.Value);
            cmd.Parameters.AddWithValue("pdf_url", (object?)invoice.PdfUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("total_amount", (object?)invoice.TotalAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("tax_amount", (object?)invoice.TaxAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("issued_at", (object?)invoice.IssuedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("related_invoice_id", (object?)invoice.RelatedInvoiceId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("at_status", (object?)invoice.AtStatus ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateInvoiceAsync(Invoice invoice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_invoices_update(@id_invoice, @invoice_type, @document_reference, @pdf_url, @total_amount, @tax_amount, @issued_at, @related_invoice_id, @at_status);";
            cmd.Parameters.AddWithValue("id_invoice", invoice.IdInvoice);
            cmd.Parameters.AddWithValue("invoice_type", (object?)invoice.InvoiceType ?? DBNull.Value);
            cmd.Parameters.AddWithValue("document_reference", (object?)invoice.DocumentReference ?? DBNull.Value);
            cmd.Parameters.AddWithValue("pdf_url", (object?)invoice.PdfUrl ?? DBNull.Value);
            cmd.Parameters.AddWithValue("total_amount", (object?)invoice.TotalAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("tax_amount", (object?)invoice.TaxAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("issued_at", (object?)invoice.IssuedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("related_invoice_id", (object?)invoice.RelatedInvoiceId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("at_status", (object?)invoice.AtStatus ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? 0 : Convert.ToInt32(res);
        }

        public async Task<int> DeleteInvoiceAsync(Guid idInvoice)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_invoices_delete(@id_invoice);";
            cmd.Parameters.AddWithValue("id_invoice", idInvoice);
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

        public async Task SimulateStudentTopupAsync(Guid idUser, StudentTopupSimulationRequest request)
        {
            var creditsAmount = request.CreditsAmount;
            var paymentAmount = request.GetNormalizedPaymentAmount();
            var topupType = request.GetNormalizedTopupType();
            var providerReference = $"SIM-TOPUP-{DateTime.UtcNow:yyyyMMddHHmmssfff}";

            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var tx = await conn.BeginTransactionAsync();

            try
            {
                Guid walletId;
                decimal balanceBefore;
                string currency;

                await using (var walletCmd = conn.CreateCommand())
                {
                    walletCmd.Transaction = tx;
                    walletCmd.CommandText = @"
                        SELECT id_wallet, COALESCE(balance, 0), COALESCE(NULLIF(currency, ''), 'EUR')
                        FROM public.wallets
                        WHERE owner_user_id = @owner_user_id
                        ORDER BY
                            CASE
                                WHEN LOWER(COALESCE(owner_type, '')) IN ('student', 'aluno') THEN 0
                                WHEN owner_type IS NULL THEN 1
                                ELSE 2
                            END,
                            updated_at DESC NULLS LAST,
                            created_at DESC NULLS LAST
                        LIMIT 1
                        FOR UPDATE;";
                    walletCmd.Parameters.AddWithValue("owner_user_id", idUser);

                    await using var walletReader = await walletCmd.ExecuteReaderAsync();
                    if (await walletReader.ReadAsync())
                    {
                        walletId = walletReader.GetGuid(0);
                        balanceBefore = walletReader.GetDecimal(1);
                        currency = walletReader.GetString(2);
                    }
                    else
                    {
                        walletId = Guid.Empty;
                        balanceBefore = 0m;
                        currency = "EUR";
                    }
                }

                if (walletId == Guid.Empty)
                {
                    await using var insertWalletCmd = conn.CreateCommand();
                    insertWalletCmd.Transaction = tx;
                    insertWalletCmd.CommandText = @"
                        INSERT INTO public.wallets (owner_type, owner_user_id, balance, hold_amount, currency, created_at, updated_at)
                        VALUES ('student', @owner_user_id, 0, 0, @currency, now(), now())
                        RETURNING id_wallet;";
                    insertWalletCmd.Parameters.AddWithValue("owner_user_id", idUser);
                    insertWalletCmd.Parameters.AddWithValue("currency", currency);

                    var walletResult = await insertWalletCmd.ExecuteScalarAsync();
                    walletId = walletResult == null || walletResult == DBNull.Value ? Guid.Empty : (Guid)walletResult;
                    balanceBefore = 0m;
                }

                var balanceAfter = balanceBefore + creditsAmount;

                await using (var updateWalletCmd = conn.CreateCommand())
                {
                    updateWalletCmd.Transaction = tx;
                    updateWalletCmd.CommandText = @"
                        UPDATE public.wallets
                        SET balance = @balance_after,
                            updated_at = now()
                        WHERE id_wallet = @id_wallet;";
                    updateWalletCmd.Parameters.AddWithValue("balance_after", balanceAfter);
                    updateWalletCmd.Parameters.AddWithValue("id_wallet", walletId);
                    await updateWalletCmd.ExecuteNonQueryAsync();
                }

                Guid topupId;
                await using (var insertTopupCmd = conn.CreateCommand())
                {
                    insertTopupCmd.Transaction = tx;
                    insertTopupCmd.CommandText = @"
                        INSERT INTO public.topups (wallet_id, payment_method_id, amount, provider_reference, topup_type, status, created_at)
                        VALUES (@wallet_id, NULL, @amount, @provider_reference, @topup_type, @status, now())
                        RETURNING id_topup;";
                    insertTopupCmd.Parameters.AddWithValue("wallet_id", walletId);
                    insertTopupCmd.Parameters.AddWithValue("amount", paymentAmount);
                    insertTopupCmd.Parameters.AddWithValue("provider_reference", providerReference);
                    insertTopupCmd.Parameters.AddWithValue("topup_type", topupType);
                    insertTopupCmd.Parameters.AddWithValue("status", "paid");

                    var topupResult = await insertTopupCmd.ExecuteScalarAsync();
                    topupId = topupResult == null || topupResult == DBNull.Value ? Guid.Empty : (Guid)topupResult;
                }

                await using (var insertTransactionCmd = conn.CreateCommand())
                {
                    insertTransactionCmd.Transaction = tx;
                    insertTransactionCmd.CommandText = @"
                        INSERT INTO public.transactions (
                            wallet_id,
                            transaction_type,
                            amount,
                            balance_before,
                            balance_after,
                            related_id,
                            related_entity_id,
                            status,
                            created_at
                        )
                        VALUES (
                            @wallet_id,
                            @transaction_type,
                            @amount,
                            @balance_before,
                            @balance_after,
                            NULL,
                            @related_entity_id,
                            @status,
                            now()
                        );";
                    insertTransactionCmd.Parameters.AddWithValue("wallet_id", walletId);
                    insertTransactionCmd.Parameters.AddWithValue("transaction_type", "credit_topup");
                    insertTransactionCmd.Parameters.AddWithValue("amount", creditsAmount);
                    insertTransactionCmd.Parameters.AddWithValue("balance_before", balanceBefore);
                    insertTransactionCmd.Parameters.AddWithValue("balance_after", balanceAfter);
                    insertTransactionCmd.Parameters.AddWithValue("related_entity_id", topupId);
                    insertTransactionCmd.Parameters.AddWithValue("status", "paid");
                    await insertTransactionCmd.ExecuteNonQueryAsync();
                }

                await tx.CommitAsync();
            }
            catch
            {
                await tx.RollbackAsync();
                throw;
            }
        }

        public async Task<ReservationPaymentReviewDto?> GetReservationPaymentReviewAsync(Guid idUser, Guid idReservation)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();

            var context = await LoadReservationPaymentContextAsync(conn, null, idUser, idReservation, false);
            return context == null
                ? null
                : new ReservationPaymentReviewDto
                {
                    ReservationId = context.ReservationId,
                    LessonId = context.LessonId,
                    ReservationStatus = context.ReservationStatus,
                    LessonTitle = context.LessonTitle,
                    Subject = context.Subject,
                    TutoringTypeName = context.TutoringTypeName,
                    TeacherName = context.TeacherName,
                    StartTime = context.StartTime,
                    EndTime = context.EndTime,
                    Amount = context.Amount,
                    AvailableCredits = context.AvailableCredits,
                    Currency = context.Currency,
                    CanAfford = context.Amount <= 0m || context.AvailableCredits >= context.Amount,
                    AlreadyPaid = IsSuccessfulPaymentStatus(context.PaymentStatus),
                    ReservationPaymentId = context.ReservationPaymentId,
                    PaymentStatus = context.PaymentStatus,
                    PlatformFeeAmount = context.PlatformFeeAmount,
                    TeacherNetAmount = context.TeacherNetAmount,
                };
        }

        public async Task<ReservationPaymentProcessResultDto> ProcessReservationPaymentAsync(Guid idUser, Guid idReservation)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var tx = await conn.BeginTransactionAsync();

            try
            {
                var context = await LoadReservationPaymentContextAsync(conn, tx, idUser, idReservation, true);
                if (context == null)
                {
                    throw new InvalidOperationException("A reserva não foi encontrada.");
                }

                if (context.ProfessorUserId == Guid.Empty)
                {
                    throw new InvalidOperationException("Não foi possível identificar o professor desta aula.");
                }

                var studentWallet = await EnsureWalletAsync(conn, tx, context.StudentUserId, "student", context.Currency);
                var professorWallet = await EnsureWalletAsync(conn, tx, context.ProfessorUserId, "professor", context.Currency);

                if (IsSuccessfulPaymentStatus(context.PaymentStatus))
                {
                    await tx.CommitAsync();
                    return new ReservationPaymentProcessResultDto
                    {
                        ReservationId = context.ReservationId,
                        LessonId = context.LessonId,
                        ReservationPaymentId = context.ReservationPaymentId,
                        Amount = context.Amount,
                        PlatformFeeAmount = context.PlatformFeeAmount,
                        TeacherNetAmount = context.TeacherNetAmount,
                        Currency = context.Currency,
                        StudentBalanceAfter = studentWallet.Balance,
                        ProfessorBalanceAfter = professorWallet.Balance,
                        AlreadyPaid = true,
                    };
                }

                if (context.Amount <= 0m)
                {
                    await tx.CommitAsync();
                    return new ReservationPaymentProcessResultDto
                    {
                        ReservationId = context.ReservationId,
                        LessonId = context.LessonId,
                        ReservationPaymentId = context.ReservationPaymentId,
                        Amount = 0m,
                        PlatformFeeAmount = 0m,
                        TeacherNetAmount = 0m,
                        Currency = context.Currency,
                        StudentBalanceAfter = studentWallet.Balance,
                        ProfessorBalanceAfter = professorWallet.Balance,
                        AlreadyPaid = false,
                    };
                }

                if (studentWallet.Balance < context.Amount)
                {
                    throw new InvalidOperationException("Saldo insuficiente para pagar esta aula.");
                }

                var commission = await GetActiveCommissionRuleAsync(conn, tx, context.IdProfessor);
                var platformFeeAmount = 0m;
                if (commission != null)
                {
                    platformFeeAmount = RoundMoney((context.Amount * commission.Percent / 100m) + commission.FixedFee);
                    if (platformFeeAmount < 0m) platformFeeAmount = 0m;
                    if (platformFeeAmount > context.Amount) platformFeeAmount = context.Amount;
                }

                var teacherNetAmount = RoundMoney(context.Amount - platformFeeAmount);
                var studentBalanceAfter = RoundMoney(studentWallet.Balance - context.Amount);
                var professorBalanceAfter = RoundMoney(professorWallet.Balance + teacherNetAmount);

                await UpdateWalletBalanceAsync(conn, tx, studentWallet.IdWallet, studentBalanceAfter);
                await UpdateWalletBalanceAsync(conn, tx, professorWallet.IdWallet, professorBalanceAfter);

                var studentTransactionId = await InsertWalletTransactionAsync(
                    conn,
                    tx,
                    studentWallet.IdWallet,
                    "lesson_payment_debit",
                    -context.Amount,
                    studentWallet.Balance,
                    studentBalanceAfter,
                    context.ReservationId,
                    "paid");

                await InsertWalletTransactionAsync(
                    conn,
                    tx,
                    professorWallet.IdWallet,
                    "lesson_payment_credit",
                    teacherNetAmount,
                    professorWallet.Balance,
                    professorBalanceAfter,
                    context.ReservationId,
                    "paid");

                var reservationPaymentId = await InsertReservationPaymentRecordAsync(
                    conn,
                    tx,
                    context.ReservationId,
                    studentWallet.IdWallet,
                    studentTransactionId,
                    commission?.IdCommissionRule,
                    context.Amount,
                    platformFeeAmount,
                    teacherNetAmount);

                await tx.CommitAsync();

                return new ReservationPaymentProcessResultDto
                {
                    ReservationId = context.ReservationId,
                    LessonId = context.LessonId,
                    ReservationPaymentId = reservationPaymentId,
                    Amount = context.Amount,
                    PlatformFeeAmount = platformFeeAmount,
                    TeacherNetAmount = teacherNetAmount,
                    Currency = context.Currency,
                    StudentBalanceAfter = studentBalanceAfter,
                    ProfessorBalanceAfter = professorBalanceAfter,
                    AlreadyPaid = false,
                };
            }
            catch
            {
                await tx.RollbackAsync();
                throw;
            }
        }

        public async Task<ReservationPaymentRefundResultDto> RefundReservationPaymentAsync(Guid idReservation)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var tx = await conn.BeginTransactionAsync();

            try
            {
                var context = await LoadReservationRefundContextAsync(conn, tx, idReservation);
                if (context == null)
                {
                    return new ReservationPaymentRefundResultDto
                    {
                        ReservationId = idReservation,
                        Currency = "EUR",
                        Refunded = false,
                    };
                }

                var studentWallet = await EnsureWalletAsync(conn, tx, context.StudentUserId, "student", context.Currency);
                var professorWallet = await EnsureWalletAsync(conn, tx, context.ProfessorUserId, "professor", context.Currency);

                if (!context.HasPaidPayment || context.ReservationPaymentId == null)
                {
                    await tx.CommitAsync();
                    return new ReservationPaymentRefundResultDto
                    {
                        ReservationId = context.ReservationId,
                        ReservationPaymentId = context.ReservationPaymentId,
                        StudentUserId = context.StudentUserId,
                        Currency = context.Currency,
                        StudentBalanceAfter = studentWallet.Balance,
                        ProfessorBalanceAfter = professorWallet.Balance,
                        RefundedAmount = 0m,
                        TeacherDebitAmount = 0m,
                        Refunded = false,
                    };
                }

                var refundAmount = context.Amount;
                var teacherDebitAmount = context.TeacherNetAmount;
                var studentBalanceAfter = RoundMoney(studentWallet.Balance + refundAmount);
                var professorBalanceAfter = RoundMoney(professorWallet.Balance - teacherDebitAmount);

                await UpdateWalletBalanceAsync(conn, tx, studentWallet.IdWallet, studentBalanceAfter);
                await UpdateWalletBalanceAsync(conn, tx, professorWallet.IdWallet, professorBalanceAfter);

                await InsertWalletTransactionAsync(
                    conn,
                    tx,
                    studentWallet.IdWallet,
                    "lesson_refund_credit",
                    refundAmount,
                    studentWallet.Balance,
                    studentBalanceAfter,
                    context.ReservationId,
                    "completed");

                if (teacherDebitAmount > 0m)
                {
                    await InsertWalletTransactionAsync(
                        conn,
                        tx,
                        professorWallet.IdWallet,
                        "lesson_refund_debit",
                        -teacherDebitAmount,
                        professorWallet.Balance,
                        professorBalanceAfter,
                        context.ReservationId,
                        "completed");
                }

                await InsertRefundRecordAsync(
                    conn,
                    tx,
                    context.TransactionId,
                    studentWallet.IdWallet,
                    refundAmount);

                await UpdateReservationPaymentStatusAsync(
                    conn,
                    tx,
                    context.ReservationPaymentId.Value,
                    "refunded");

                await tx.CommitAsync();

                return new ReservationPaymentRefundResultDto
                {
                    ReservationId = context.ReservationId,
                    ReservationPaymentId = context.ReservationPaymentId,
                    StudentUserId = context.StudentUserId,
                    RefundedAmount = refundAmount,
                    StudentBalanceAfter = studentBalanceAfter,
                    ProfessorBalanceAfter = professorBalanceAfter,
                    TeacherDebitAmount = teacherDebitAmount,
                    Currency = context.Currency,
                    Refunded = true,
                };
            }
            catch
            {
                await tx.RollbackAsync();
                throw;
            }
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

        public async Task<PaymentDisputeContextDto?> ResolvePaymentDisputeContextAsync(Guid idUser, string paymentSource, Guid paymentRecordId)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();

            if (string.Equals(paymentSource, "reservation_payment", StringComparison.OrdinalIgnoreCase))
            {
                cmd.CommandText = @"
                    SELECT
                        rp.transaction_id,
                        rp.reservation_id,
                        rp.id_reservation_payment AS reservation_payment_id,
                        NULL::uuid AS topup_id,
                        COALESCE(NULLIF(inv.document_reference, ''), rp.id_reservation_payment::text) AS payment_reference,
                        'reservation_payment'::text AS payment_source,
                        CASE WHEN r.id_user = @id_user THEN 'aluno' ELSE 'professor' END AS reporter_role
                    FROM public.reservation_payments rp
                    INNER JOIN public.reservations r ON r.id_reservation = rp.reservation_id
                    INNER JOIN public.lessons l ON l.id_lesson = r.id_lesson
                    LEFT JOIN public.courses c ON c.id_course = l.id_course
                    INNER JOIN public.professors p ON p.id_professor = COALESCE(l.id_professor, c.id_professor)
                    LEFT JOIN LATERAL (
                        SELECT i.document_reference
                        FROM public.invoices i
                        WHERE i.id_transaction = rp.transaction_id
                        ORDER BY i.issued_at DESC NULLS LAST
                        LIMIT 1
                    ) inv ON TRUE
                    WHERE rp.id_reservation_payment = @payment_record_id
                      AND (r.id_user = @id_user OR p.id_user = @id_user)
                    LIMIT 1;";
            }
            else if (string.Equals(paymentSource, "topup", StringComparison.OrdinalIgnoreCase))
            {
                cmd.CommandText = @"
                    SELECT
                        NULL::uuid AS transaction_id,
                        NULL::uuid AS reservation_id,
                        NULL::uuid AS reservation_payment_id,
                        t.id_topup AS topup_id,
                        COALESCE(NULLIF(t.provider_reference, ''), t.id_topup::text) AS payment_reference,
                        'topup'::text AS payment_source,
                        'aluno'::text AS reporter_role
                    FROM public.topups t
                    INNER JOIN public.wallets w ON w.id_wallet = t.wallet_id
                    WHERE t.id_topup = @payment_record_id
                      AND w.owner_user_id = @id_user
                    LIMIT 1;";
            }
            else
            {
                return null;
            }

            cmd.Parameters.AddWithValue("id_user", idUser);
            cmd.Parameters.AddWithValue("payment_record_id", paymentRecordId);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new PaymentDisputeContextDto
            {
                TransactionId = GetNullableGuid(reader, "transaction_id"),
                ReservationId = GetNullableGuid(reader, "reservation_id"),
                ReservationPaymentId = GetNullableGuid(reader, "reservation_payment_id"),
                TopupId = GetNullableGuid(reader, "topup_id"),
                PaymentReference = GetNullableString(reader, "payment_reference") ?? string.Empty,
                PaymentSource = GetNullableString(reader, "payment_source") ?? paymentSource,
                ReporterRole = GetNullableString(reader, "reporter_role") ?? string.Empty
            };
        }

        public async Task<Guid> InsertDisputeAsync(Dispute dispute)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_disputes_insert(
                CAST(@transaction_id AS uuid),
                CAST(@id_reservation AS uuid),
                CAST(@reservation_payment_id AS uuid),
                CAST(@topup_id AS uuid),
                CAST(@raised_by_user_id AS uuid),
                CAST(@reporter_name AS varchar),
                CAST(@reporter_email AS varchar),
                CAST(@reporter_role AS varchar),
                CAST(@subject AS varchar),
                CAST(@reason AS text),
                CAST(@payment_reference AS text),
                CAST(@payment_source AS varchar),
                CAST(@status AS varchar),
                CAST(@resolution_note AS text),
                CAST(@created_at AS timestamp),
                CAST(@updated_at AS timestamp));";
            cmd.Parameters.AddWithValue("transaction_id", (object?)dispute.TransactionId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_reservation", (object?)dispute.IdReservation ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reservation_payment_id", (object?)dispute.ReservationPaymentId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("topup_id", (object?)dispute.TopupId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("raised_by_user_id", (object?)dispute.RaisedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reporter_name", (object?)dispute.ReporterName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reporter_email", (object?)dispute.ReporterEmail ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reporter_role", (object?)dispute.ReporterRole ?? DBNull.Value);
            cmd.Parameters.AddWithValue("subject", (object?)dispute.Subject ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reason", (object?)dispute.Reason ?? DBNull.Value);
            cmd.Parameters.AddWithValue("payment_reference", (object?)dispute.PaymentReference ?? DBNull.Value);
            cmd.Parameters.AddWithValue("payment_source", (object?)dispute.PaymentSource ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)dispute.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("resolution_note", (object?)dispute.ResolutionNote ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)dispute.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)dispute.UpdatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateDisputeAsync(Dispute dispute)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = @"SELECT public.usp_disputes_update(
                CAST(@id_dispute AS uuid),
                CAST(@transaction_id AS uuid),
                CAST(@id_reservation AS uuid),
                CAST(@reservation_payment_id AS uuid),
                CAST(@topup_id AS uuid),
                CAST(@raised_by_user_id AS uuid),
                CAST(@reporter_name AS varchar),
                CAST(@reporter_email AS varchar),
                CAST(@reporter_role AS varchar),
                CAST(@subject AS varchar),
                CAST(@reason AS text),
                CAST(@payment_reference AS text),
                CAST(@payment_source AS varchar),
                CAST(@status AS varchar),
                CAST(@resolution_note AS text),
                CAST(@created_at AS timestamp),
                CAST(@updated_at AS timestamp));";
            cmd.Parameters.AddWithValue("id_dispute", dispute.IdDispute);
            cmd.Parameters.AddWithValue("transaction_id", (object?)dispute.TransactionId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("id_reservation", (object?)dispute.IdReservation ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reservation_payment_id", (object?)dispute.ReservationPaymentId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("topup_id", (object?)dispute.TopupId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("raised_by_user_id", (object?)dispute.RaisedByUserId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reporter_name", (object?)dispute.ReporterName ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reporter_email", (object?)dispute.ReporterEmail ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reporter_role", (object?)dispute.ReporterRole ?? DBNull.Value);
            cmd.Parameters.AddWithValue("subject", (object?)dispute.Subject ?? DBNull.Value);
            cmd.Parameters.AddWithValue("reason", (object?)dispute.Reason ?? DBNull.Value);
            cmd.Parameters.AddWithValue("payment_reference", (object?)dispute.PaymentReference ?? DBNull.Value);
            cmd.Parameters.AddWithValue("payment_source", (object?)dispute.PaymentSource ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)dispute.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("resolution_note", (object?)dispute.ResolutionNote ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)dispute.CreatedAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("updated_at", (object?)dispute.UpdatedAt ?? DBNull.Value);
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
                        cmd.CommandText = "SELECT public.usp_reservation_payments_insert(@reservation_id, @payer_wallet_id, @transaction_id, @commission_rule_id, @amount, @gross_amount, @platform_fee_amount, @teacher_net_amount, @status, @hold_release_at, @created_at);";
            cmd.Parameters.AddWithValue("reservation_id", rp.ReservationId);
            cmd.Parameters.AddWithValue("payer_wallet_id", rp.PayerWalletId);
            cmd.Parameters.AddWithValue("transaction_id", (object?)rp.TransactionId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("commission_rule_id", (object?)rp.CommissionRuleId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", (object?)rp.Amount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("gross_amount", (object?)rp.GrossAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("platform_fee_amount", (object?)rp.PlatformFeeAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("teacher_net_amount", (object?)rp.TeacherNetAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)rp.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("hold_release_at", (object?)rp.HoldReleaseAt ?? DBNull.Value);
            cmd.Parameters.AddWithValue("created_at", (object?)rp.CreatedAt ?? DBNull.Value);
            var res = await cmd.ExecuteScalarAsync();
            return res == null || res == DBNull.Value ? Guid.Empty : (Guid)res;
        }

        public async Task<int> UpdateReservationPaymentAsync(ReservationPayment rp)
        {
            await using var conn = new NpgsqlConnection(_connectionString);
            await conn.OpenAsync();
            await using var cmd = conn.CreateCommand();
            cmd.CommandText = "SELECT public.usp_reservation_payments_update(@id_reservation_payment, @reservation_id, @payer_wallet_id, @transaction_id, @commission_rule_id, @amount, @gross_amount, @platform_fee_amount, @teacher_net_amount, @status, @hold_release_at, @created_at);";
            cmd.Parameters.AddWithValue("id_reservation_payment", rp.IdReservationPayment);
            cmd.Parameters.AddWithValue("reservation_id", rp.ReservationId);
            cmd.Parameters.AddWithValue("payer_wallet_id", rp.PayerWalletId);
            cmd.Parameters.AddWithValue("transaction_id", (object?)rp.TransactionId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("commission_rule_id", (object?)rp.CommissionRuleId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("amount", (object?)rp.Amount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("gross_amount", (object?)rp.GrossAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("platform_fee_amount", (object?)rp.PlatformFeeAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("teacher_net_amount", (object?)rp.TeacherNetAmount ?? DBNull.Value);
            cmd.Parameters.AddWithValue("status", (object?)rp.Status ?? DBNull.Value);
            cmd.Parameters.AddWithValue("hold_release_at", (object?)rp.HoldReleaseAt ?? DBNull.Value);
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
        private async Task<ReservationPaymentContext?> LoadReservationPaymentContextAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction? tx,
            Guid idUser,
            Guid idReservation,
            bool lockReservation)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
SELECT
    r.id_reservation,
    r.id_user AS student_user_id,
    COALESCE(NULLIF(r.status, ''), 'pending') AS reservation_status,
    l.id_lesson,
    COALESCE(NULLIF(l.title, ''), COALESCE(d.nome, c.name, 'Explicação')) AS lesson_title,
    COALESCE(d.nome, c.name, l.title, 'Explicação') AS subject,
    tt.name AS tutoring_type_name,
    l.scheduled_start,
    l.scheduled_end,
    COALESCE(l.base_price, cp.session_price, 0) AS amount,
    COALESCE(sw.balance, 0) AS available_credits,
    COALESCE(NULLIF(sw.currency, ''), NULLIF(pw.currency, ''), 'EUR') AS currency,
    COALESCE(p.id_professor, '00000000-0000-0000-0000-000000000000'::uuid) AS id_professor,
    COALESCE(pu.id_user, '00000000-0000-0000-0000-000000000000'::uuid) AS professor_user_id,
    COALESCE(NULLIF(pu.display_name, ''), NULLIF(TRIM(CONCAT_WS(' ', pu.first_name, pu.last_name)), ''), pu.username, 'Professor') AS teacher_name,
    rp.id_reservation_payment,
    rp.status AS payment_status,
    COALESCE(rp.platform_fee_amount, 0) AS platform_fee_amount,
    COALESCE(rp.teacher_net_amount, 0) AS teacher_net_amount
FROM public.reservations r
JOIN public.lessons l ON l.id_lesson = r.id_lesson
LEFT JOIN public.courses c ON c.id_course = l.id_course
LEFT JOIN public.disciplinas d ON d.id_disciplina = c.id_disciplina
LEFT JOIN public.tutoring_types tt ON tt.id_tutoring_type = c.id_tutoring_type
LEFT JOIN public.professors p ON p.id_professor = l.id_professor
LEFT JOIN public.users pu ON pu.id_user = p.id_user
LEFT JOIN LATERAL (
    SELECT cp1.session_price
    FROM public.course_prices cp1
    WHERE cp1.id_course = c.id_course
      AND cp1.active = TRUE
    ORDER BY cp1.updated_at DESC NULLS LAST, cp1.created_at DESC NULLS LAST
    LIMIT 1
) cp ON TRUE
LEFT JOIN LATERAL (
    SELECT w.id_wallet, COALESCE(w.balance, 0) AS balance, COALESCE(NULLIF(w.currency, ''), 'EUR') AS currency
    FROM public.wallets w
    WHERE w.owner_user_id = r.id_user
    ORDER BY
        CASE
            WHEN LOWER(COALESCE(w.owner_type, '')) IN ('student', 'aluno') THEN 0
            WHEN w.owner_type IS NULL THEN 1
            ELSE 2
        END,
        w.updated_at DESC NULLS LAST,
        w.created_at DESC NULLS LAST
    LIMIT 1
) sw ON TRUE
LEFT JOIN LATERAL (
    SELECT w.id_wallet, COALESCE(w.balance, 0) AS balance, COALESCE(NULLIF(w.currency, ''), 'EUR') AS currency
    FROM public.wallets w
    WHERE w.owner_user_id = p.id_user
    ORDER BY
        CASE
            WHEN LOWER(COALESCE(w.owner_type, '')) IN ('professor', 'teacher') THEN 0
            WHEN w.owner_type IS NULL THEN 1
            ELSE 2
        END,
        w.updated_at DESC NULLS LAST,
        w.created_at DESC NULLS LAST
    LIMIT 1
) pw ON TRUE
LEFT JOIN LATERAL (
    SELECT
        rp1.id_reservation_payment,
        rp1.status,
        rp1.platform_fee_amount,
        rp1.teacher_net_amount
    FROM public.reservation_payments rp1
    WHERE rp1.reservation_id = r.id_reservation
      AND LOWER(COALESCE(rp1.status, '')) IN ('paid', 'completed', 'success', 'succeeded', 'pago', 'concluido')
    ORDER BY rp1.created_at DESC NULLS LAST, rp1.id_reservation_payment DESC
    LIMIT 1
) rp ON TRUE
WHERE r.id_reservation = @id_reservation
  AND r.id_user = @id_user" + (lockReservation ? " FOR UPDATE OF r;" : ";");
            cmd.Parameters.AddWithValue("id_reservation", idReservation);
            cmd.Parameters.AddWithValue("id_user", idUser);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new ReservationPaymentContext
            {
                ReservationId = reader.GetGuid(reader.GetOrdinal("id_reservation")),
                StudentUserId = reader.GetGuid(reader.GetOrdinal("student_user_id")),
                ReservationStatus = GetNullableString(reader, "reservation_status"),
                LessonId = reader.GetGuid(reader.GetOrdinal("id_lesson")),
                LessonTitle = GetNullableString(reader, "lesson_title"),
                Subject = GetNullableString(reader, "subject"),
                TutoringTypeName = GetNullableString(reader, "tutoring_type_name"),
                StartTime = GetNullableDateTime(reader, "scheduled_start"),
                EndTime = GetNullableDateTime(reader, "scheduled_end"),
                Amount = GetNullableDecimal(reader, "amount") ?? 0m,
                AvailableCredits = GetNullableDecimal(reader, "available_credits") ?? 0m,
                Currency = GetNullableString(reader, "currency") ?? "EUR",
                IdProfessor = reader.GetGuid(reader.GetOrdinal("id_professor")),
                ProfessorUserId = reader.GetGuid(reader.GetOrdinal("professor_user_id")),
                TeacherName = GetNullableString(reader, "teacher_name"),
                ReservationPaymentId = GetNullableGuid(reader, "id_reservation_payment"),
                PaymentStatus = GetNullableString(reader, "payment_status"),
                PlatformFeeAmount = GetNullableDecimal(reader, "platform_fee_amount") ?? 0m,
                TeacherNetAmount = GetNullableDecimal(reader, "teacher_net_amount") ?? 0m,
            };
        }

        private async Task<WalletSnapshot> EnsureWalletAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid ownerUserId,
            string ownerType,
            string currency)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
SELECT id_wallet, COALESCE(balance, 0) AS balance, COALESCE(NULLIF(currency, ''), @currency) AS currency
FROM public.wallets
WHERE owner_user_id = @owner_user_id
ORDER BY
    CASE
        WHEN LOWER(COALESCE(owner_type, '')) = LOWER(@owner_type) THEN 0
        WHEN owner_type IS NULL THEN 1
        ELSE 2
    END,
    updated_at DESC NULLS LAST,
    created_at DESC NULLS LAST
LIMIT 1
FOR UPDATE;";
            cmd.Parameters.AddWithValue("owner_user_id", ownerUserId);
            cmd.Parameters.AddWithValue("owner_type", ownerType);
            cmd.Parameters.AddWithValue("currency", string.IsNullOrWhiteSpace(currency) ? "EUR" : currency);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new WalletSnapshot
                {
                    IdWallet = reader.GetGuid(reader.GetOrdinal("id_wallet")),
                    Balance = GetNullableDecimal(reader, "balance") ?? 0m,
                    Currency = GetNullableString(reader, "currency") ?? "EUR",
                };
            }

            await reader.DisposeAsync();

            await using var insertCmd = conn.CreateCommand();
            insertCmd.Transaction = tx;
            insertCmd.CommandText = @"
INSERT INTO public.wallets (owner_type, owner_user_id, balance, hold_amount, currency, created_at, updated_at)
VALUES (@owner_type, @owner_user_id, 0, 0, @currency, now(), now())
RETURNING id_wallet;";
            insertCmd.Parameters.AddWithValue("owner_type", ownerType);
            insertCmd.Parameters.AddWithValue("owner_user_id", ownerUserId);
            insertCmd.Parameters.AddWithValue("currency", string.IsNullOrWhiteSpace(currency) ? "EUR" : currency);
            var result = await insertCmd.ExecuteScalarAsync();

            return new WalletSnapshot
            {
                IdWallet = result == null || result == DBNull.Value ? Guid.Empty : (Guid)result,
                Balance = 0m,
                Currency = string.IsNullOrWhiteSpace(currency) ? "EUR" : currency,
            };
        }

        private async Task UpdateWalletBalanceAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid walletId, decimal balance)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
UPDATE public.wallets
SET balance = @balance,
    updated_at = now()
WHERE id_wallet = @id_wallet;";
            cmd.Parameters.AddWithValue("balance", balance);
            cmd.Parameters.AddWithValue("id_wallet", walletId);
            await cmd.ExecuteNonQueryAsync();
        }

        private async Task<Guid> InsertWalletTransactionAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid walletId,
            string transactionType,
            decimal amount,
            decimal balanceBefore,
            decimal balanceAfter,
            Guid relatedEntityId,
            string status)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
INSERT INTO public.transactions (
    wallet_id,
    transaction_type,
    amount,
    balance_before,
    balance_after,
    related_id,
    related_entity_id,
    status,
    created_at
)
VALUES (
    @wallet_id,
    @transaction_type,
    @amount,
    @balance_before,
    @balance_after,
    NULL,
    @related_entity_id,
    @status,
    now()
)
RETURNING id_transaction;";
            cmd.Parameters.AddWithValue("wallet_id", walletId);
            cmd.Parameters.AddWithValue("transaction_type", transactionType);
            cmd.Parameters.AddWithValue("amount", amount);
            cmd.Parameters.AddWithValue("balance_before", balanceBefore);
            cmd.Parameters.AddWithValue("balance_after", balanceAfter);
            cmd.Parameters.AddWithValue("related_entity_id", relatedEntityId);
            cmd.Parameters.AddWithValue("status", status);
            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? Guid.Empty : (Guid)result;
        }

        private async Task<Guid> InsertReservationPaymentRecordAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid reservationId,
            Guid payerWalletId,
            Guid transactionId,
            Guid? commissionRuleId,
            decimal amount,
            decimal platformFeeAmount,
            decimal teacherNetAmount)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
INSERT INTO public.reservation_payments (
    reservation_id,
    payer_wallet_id,
    transaction_id,
    commission_rule_id,
    amount,
    gross_amount,
    platform_fee_amount,
    teacher_net_amount,
    status,
    hold_release_at,
    created_at
)
VALUES (
    @reservation_id,
    @payer_wallet_id,
    @transaction_id,
    @commission_rule_id,
    @amount,
    @gross_amount,
    @platform_fee_amount,
    @teacher_net_amount,
    @status,
    NULL,
    now()
)
RETURNING id_reservation_payment;";
            cmd.Parameters.AddWithValue("reservation_id", reservationId);
            cmd.Parameters.AddWithValue("payer_wallet_id", payerWalletId);
            cmd.Parameters.AddWithValue("transaction_id", transactionId);
            cmd.Parameters.Add(new NpgsqlParameter("commission_rule_id", NpgsqlDbType.Uuid)
            {
                Value = (object?)commissionRuleId ?? DBNull.Value,
            });
            cmd.Parameters.AddWithValue("amount", amount);
            cmd.Parameters.AddWithValue("gross_amount", amount);
            cmd.Parameters.AddWithValue("platform_fee_amount", platformFeeAmount);
            cmd.Parameters.AddWithValue("teacher_net_amount", teacherNetAmount);
            cmd.Parameters.AddWithValue("status", "paid");
            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? Guid.Empty : (Guid)result;
        }

        private async Task<ReservationRefundContext?> LoadReservationRefundContextAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid idReservation)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
SELECT
    r.id_reservation,
    r.id_user AS student_user_id,
    COALESCE(pu.id_user, '00000000-0000-0000-0000-000000000000'::uuid) AS professor_user_id,
    COALESCE(NULLIF(sw.currency, ''), NULLIF(pw.currency, ''), 'EUR') AS currency,
    COALESCE(rp.id_reservation_payment, '00000000-0000-0000-0000-000000000000'::uuid) AS id_reservation_payment,
    rp.transaction_id,
    COALESCE(rp.amount, 0) AS amount,
    COALESCE(rp.teacher_net_amount, 0) AS teacher_net_amount,
    COALESCE(rp.status, '') AS payment_status
FROM public.reservations r
JOIN public.lessons l ON l.id_lesson = r.id_lesson
LEFT JOIN public.professors p ON p.id_professor = l.id_professor
LEFT JOIN public.users pu ON pu.id_user = p.id_user
LEFT JOIN LATERAL (
    SELECT w.currency
    FROM public.wallets w
    WHERE w.owner_user_id = r.id_user
    ORDER BY updated_at DESC NULLS LAST, created_at DESC NULLS LAST
    LIMIT 1
) sw ON TRUE
LEFT JOIN LATERAL (
    SELECT w.currency
    FROM public.wallets w
    WHERE w.owner_user_id = p.id_user
    ORDER BY updated_at DESC NULLS LAST, created_at DESC NULLS LAST
    LIMIT 1
) pw ON TRUE
LEFT JOIN LATERAL (
    SELECT rp1.id_reservation_payment, rp1.transaction_id, rp1.amount, rp1.teacher_net_amount, rp1.status
    FROM public.reservation_payments rp1
    WHERE rp1.reservation_id = r.id_reservation
    ORDER BY rp1.created_at DESC NULLS LAST, rp1.id_reservation_payment DESC
    LIMIT 1
) rp ON TRUE
WHERE r.id_reservation = @id_reservation
FOR UPDATE OF r;";
            cmd.Parameters.AddWithValue("id_reservation", idReservation);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            var reservationPaymentId = GetNullableGuid(reader, "id_reservation_payment");
            if (reservationPaymentId == Guid.Empty) reservationPaymentId = null;

            return new ReservationRefundContext
            {
                ReservationId = reader.GetGuid(reader.GetOrdinal("id_reservation")),
                StudentUserId = reader.GetGuid(reader.GetOrdinal("student_user_id")),
                ProfessorUserId = reader.GetGuid(reader.GetOrdinal("professor_user_id")),
                Currency = GetNullableString(reader, "currency") ?? "EUR",
                ReservationPaymentId = reservationPaymentId,
                TransactionId = GetNullableGuid(reader, "transaction_id"),
                Amount = GetNullableDecimal(reader, "amount") ?? 0m,
                TeacherNetAmount = GetNullableDecimal(reader, "teacher_net_amount") ?? 0m,
                PaymentStatus = GetNullableString(reader, "payment_status"),
                HasPaidPayment = IsSuccessfulPaymentStatus(GetNullableString(reader, "payment_status")),
            };
        }

        private async Task<Guid> InsertRefundRecordAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid? transactionId,
            Guid toWalletId,
            decimal amount)
        {
            if (transactionId == null || transactionId == Guid.Empty) return Guid.Empty;

            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
INSERT INTO public.refunds (transaction_id, to_wallet_id, amount, status, created_at)
VALUES (@transaction_id, @to_wallet_id, @amount, @status, now())
RETURNING id_refund;";
            cmd.Parameters.AddWithValue("transaction_id", transactionId.Value);
            cmd.Parameters.AddWithValue("to_wallet_id", toWalletId);
            cmd.Parameters.AddWithValue("amount", amount);
            cmd.Parameters.AddWithValue("status", "completed");
            var result = await cmd.ExecuteScalarAsync();
            return result == null || result == DBNull.Value ? Guid.Empty : (Guid)result;
        }

        private async Task UpdateReservationPaymentStatusAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            Guid reservationPaymentId,
            string status)
        {
            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
UPDATE public.reservation_payments
SET status = @status
WHERE id_reservation_payment = @id_reservation_payment;";
            cmd.Parameters.AddWithValue("status", status);
            cmd.Parameters.AddWithValue("id_reservation_payment", reservationPaymentId);
            await cmd.ExecuteNonQueryAsync();
        }

        private async Task<CommissionRuleSnapshot?> GetActiveCommissionRuleAsync(NpgsqlConnection conn, NpgsqlTransaction tx, Guid idProfessor)
        {
            if (idProfessor == Guid.Empty) return null;

            await using var cmd = conn.CreateCommand();
            cmd.Transaction = tx;
            cmd.CommandText = @"
SELECT id_commission_rule, COALESCE(percent, 0), COALESCE(fixed_fee, 0)
FROM public.commission_rules
WHERE (id_professor = @id_professor OR id_professor IS NULL)
  AND (effective_from IS NULL OR effective_from <= now())
  AND (effective_to IS NULL OR effective_to >= now())
ORDER BY CASE WHEN id_professor = @id_professor THEN 0 ELSE 1 END,
         effective_from DESC NULLS LAST,
         effective_to DESC NULLS LAST,
         id_commission_rule DESC
LIMIT 1;";
            cmd.Parameters.AddWithValue("id_professor", idProfessor);

            await using var reader = await cmd.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return null;

            return new CommissionRuleSnapshot
            {
                IdCommissionRule = reader.GetGuid(0),
                Percent = reader.GetDecimal(1),
                FixedFee = reader.GetDecimal(2),
            };
        }

        private static bool IsSuccessfulPaymentStatus(string? status)
        {
            var normalized = status?.Trim().ToLowerInvariant() ?? string.Empty;
            return normalized == "paid"
                || normalized == "completed"
                || normalized == "success"
                || normalized == "succeeded"
                || normalized == "pago"
                || normalized == "concluido";
        }

        private static decimal RoundMoney(decimal value) =>
            Math.Round(value, 2, MidpointRounding.AwayFromZero);

        private sealed class ReservationPaymentContext
        {
            public Guid ReservationId { get; set; }
            public Guid StudentUserId { get; set; }
            public string? ReservationStatus { get; set; }
            public Guid LessonId { get; set; }
            public string? LessonTitle { get; set; }
            public string? Subject { get; set; }
            public string? TutoringTypeName { get; set; }
            public DateTime? StartTime { get; set; }
            public DateTime? EndTime { get; set; }
            public decimal Amount { get; set; }
            public decimal AvailableCredits { get; set; }
            public string Currency { get; set; } = "EUR";
            public Guid IdProfessor { get; set; }
            public Guid ProfessorUserId { get; set; }
            public string? TeacherName { get; set; }
            public Guid? ReservationPaymentId { get; set; }
            public string? PaymentStatus { get; set; }
            public decimal PlatformFeeAmount { get; set; }
            public decimal TeacherNetAmount { get; set; }
        }

        private sealed class WalletSnapshot
        {
            public Guid IdWallet { get; set; }
            public decimal Balance { get; set; }
            public string Currency { get; set; } = "EUR";
        }

        private sealed class CommissionRuleSnapshot
        {
            public Guid IdCommissionRule { get; set; }
            public decimal Percent { get; set; }
            public decimal FixedFee { get; set; }
        }

        private sealed class ReservationRefundContext
        {
            public Guid ReservationId { get; set; }
            public Guid StudentUserId { get; set; }
            public Guid ProfessorUserId { get; set; }
            public Guid? ReservationPaymentId { get; set; }
            public Guid? TransactionId { get; set; }
            public decimal Amount { get; set; }
            public decimal TeacherNetAmount { get; set; }
            public string? PaymentStatus { get; set; }
            public string Currency { get; set; } = "EUR";
            public bool HasPaidPayment { get; set; }
        }

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
                RelatedEntityId = GetNullableGuid(reader, "related_entity_id"),
                Status = GetNullableString(reader, "status"),
                CreatedAt = GetNullableDateTime(reader, "created_at")
            };
        }

        private static Invoice MapInvoice(NpgsqlDataReader reader)
        {
            return new Invoice
            {
                IdInvoice = reader.GetGuid(reader.GetOrdinal("id_invoice")),
                IdTransaction = reader.GetGuid(reader.GetOrdinal("id_transaction")),
                IdUser = reader.GetGuid(reader.GetOrdinal("id_user")),
                InvoiceType = GetNullableString(reader, "invoice_type"),
                DocumentReference = GetNullableString(reader, "document_reference"),
                PdfUrl = GetNullableString(reader, "pdf_url"),
                TotalAmount = GetNullableDecimal(reader, "total_amount"),
                TaxAmount = GetNullableDecimal(reader, "tax_amount"),
                IssuedAt = GetNullableDateTime(reader, "issued_at"),
                RelatedInvoiceId = GetNullableGuid(reader, "related_invoice_id"),
                AtStatus = GetNullableString(reader, "at_status")
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
                TransactionId = GetNullableGuid(reader, "transaction_id"),
                IdReservation = GetNullableGuid(reader, "id_reservation"),
                ReservationPaymentId = GetNullableGuid(reader, "reservation_payment_id"),
                TopupId = GetNullableGuid(reader, "topup_id"),
                RaisedByUserId = GetNullableGuid(reader, "raised_by_user_id"),
                ReporterName = GetNullableString(reader, "reporter_name"),
                ReporterEmail = GetNullableString(reader, "reporter_email"),
                ReporterRole = GetNullableString(reader, "reporter_role"),
                Subject = GetNullableString(reader, "subject"),
                Reason = GetNullableString(reader, "reason"),
                PaymentReference = GetNullableString(reader, "payment_reference"),
                PaymentSource = GetNullableString(reader, "payment_source"),
                Status = GetNullableString(reader, "status"),
                ResolutionNote = GetNullableString(reader, "resolution_note"),
                CreatedAt = GetNullableDateTime(reader, "created_at"),
                UpdatedAt = GetNullableDateTime(reader, "updated_at")
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
                GrossAmount = GetNullableDecimal(reader, "gross_amount"),
                PlatformFeeAmount = GetNullableDecimal(reader, "platform_fee_amount"),
                TeacherNetAmount = GetNullableDecimal(reader, "teacher_net_amount"),
                Status = GetNullableString(reader, "status"),
                HoldReleaseAt = GetNullableDateTime(reader, "hold_release_at"),
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
