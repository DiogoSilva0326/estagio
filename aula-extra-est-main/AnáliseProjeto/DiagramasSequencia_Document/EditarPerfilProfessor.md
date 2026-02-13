```mermaid
sequenceDiagram
    actor Professor
    participant Site as Site de Explicações
    participant API as API (backend)
    participant BD@{ "type": "database" }
    autonumber

    title Fluxo de Edição de Perfil do Professor

    Professor->>Site: Acessa página de edição de perfil
    Site->>API: Solicita dados do perfil
    API->>BD: Consulta informações do perfil
    BD-->>API: Retorna dados do perfil
    API-->>Site: Envia dados do perfil
    Site-->>Professor: Exibe dados atuais do perfil
    Professor->>Site: Submete alterações no perfil (e.g., disponibilidade, disciplinas)
    Site->>Site: Valida dados inseridos (formulário preenchido corretamente)
    Site->>API: Envia dados para serem atualizados
    API->>API: Valida dados recebidos
    alt Dados válidos
        API->>BD: Envio dados do perfil
        BD->>BD: Atualiza os dados do perfil
        BD-->>API: Confirmação de atualização
        API->>Site: Mensagem de sucesso
        Site-->>Professor: Notificação de perfil atualizado com sucesso
    else Dados inválidos
        API->>Site: Mensagem de erro de validação
        Site-->>Professor: Notificação de erro nos dados enviados
    end
    
    Note over Professor: Pode visualizar as alterações no perfil atualizado caso a atualização seja bem-sucedida
```