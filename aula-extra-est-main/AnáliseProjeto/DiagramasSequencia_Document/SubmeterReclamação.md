```Mermaid
sequenceDiagram
    autonumber
    actor Aluno
    actor Professor
    participant Site as Site de Explicações
    participant API as API (backend)
    participant BD as Banco de Dados
    participant BO as Backoffice
    actor Admin

    Note over Aluno, Professor: Qualquer um pode reclamar
    Aluno->>Site: Submeter reclamação
    Professor->>Site: Submeter reclamação
    Site->>API: Valida requisitos da reclamação

    alt Reclamação Válida
        API->>BD: Guarda reclamação submetida
        API->>BO: Notifica nova reclamação
        BO->>Admin: Notificação para análise
        Admin->>BO: Toma ação/decisão
        BO->>API: Envia decisão
        API-->>Site: Resultado da decisão
        Site-->>Aluno: Notificação da decisão tomada
        Site-->>Professor: Notificação da decisão tomada
    else Reclamação Inválida
        API-->>Site: Reclamação inválida
        Site-->>Aluno: Mensagem de erro
        Site-->>Professor: Mensagem de erro
    end
```