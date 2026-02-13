
sequenceDiagram
    autonumber
    actor Aluno
    participant Site as Site de Explicações
    participant API as API (backend)
    participant BD as BD
    actor Professor

    Aluno->>Site: Escolhe professor e data/hora
    Site->>Site: Cria pedido de pagamento (idempotencyKey)
    Site->>API: Submete pedido de pagamento (idempotencyKey, reservation details)

    Note over API: API valida disponibilidade e calcula preço final
    API->>BD: Criar `ReservationPayment` (status = pending)
    API->>API: Aplicar `CommissionRule` e calcular `commission_amount`/`platform_fee`
    API->>API: Iniciar processamento de pagamento (provider abstrato)

    alt Pagamento bem sucedido imediatamente
        opt Top-up / Creditar wallet (pagamento via provider -> créditos)
            API->>BD: Criar `Transaction` (type=topup) e creditar `Wallet` do aluno
            API->>BD: Criar registo de funding para `ReservationPayment` (source = wallet/provider)
        end
        alt Payment funded by wallet
            API->>BD: Debitar `Wallet` do aluno (Transaction type=debit) e marcar `ReservationPayment` = paid
        else Payment via provider
            API->>BD: Criar `Transaction` (type=payment) e marcar `ReservationPayment` = paid
        end
        API->>BD: Criar registo de Invoice / fatura (ou preparar dados da fatura)
        API-->>Site: Confirmação de pagamento (idempotencyKey)
        Site-->>Aluno: Mostrar confirmação + fatura
        API->>BD: Criar `Enrollment` / associar aluno à aula
        API->>Professor: Notificação de aula marcada
    else Pagamento pendente (ex.: 3DS / require_action)
        API-->>Site: Redirecionar aluno para autenticação externa
        Note over API: Aguardar webhook/confirmacao do provider
        API->>BD: (on webhook success) Criar `Transaction`, marcar `ReservationPayment` = paid
        API->>BD: Criar registo de Invoice
        API-->>Site: Notificar sucesso
        Site-->>Aluno: Mostrar confirmação
    else Falha no pagamento
        API->>BD: Actualizar `ReservationPayment` = failed
        API->>BD: Criar `Transaction` (failed)
        API-->>Site: Notificar falha
        Site-->>Aluno: Mensagem de erro / instruções para retry
    end

    Note over API: Usar webhooks e idempotency keys, persistir estado (pending|succeeded|failed) no BD.
    Note over BD: Guardar ReservationPayment, Transaction, Invoice e histórico para reconciliação.

    %% Dispute / refund flow when credits or payments are contested
    Note over API: Fluxo de disputa e reembolso (créditos internamente)
    Aluno->>Site: Abrir disputa (motivo, evidence)
    Site->>API: Submeter disputa
    API->>BD: Criar `Dispute` (status = pending) e marcar `ReservationPayment` = disputed
    API->>BD: Criar `Refund` (status = pending, amount)
    API->>API: Bloquear fundos / criar hold ou iniciar refund provider

    alt Disputa favorável ao aluno
        API->>BD: Processar `Refund` = completed
        API->>BD: Se refund interno -> creditar `Wallet` do aluno (Transaction type=refund)
        API->>BD: Se refund provider -> registrar provider refund transaction
        API-->>Site: Notificar aluno (reembolso emitido)
    else Disputa favorável ao professor
        API->>BD: Liberar holds marcar `ReservationPayment` = completed `Dispute` = resolved
        API-->>Site: Notificar resultado (rejeitado)
    end