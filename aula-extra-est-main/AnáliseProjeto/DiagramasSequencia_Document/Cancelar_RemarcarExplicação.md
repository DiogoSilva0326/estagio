# Processo de Avaliação de Professor
Este documento descreve o processo de avaliação de professores na plataforma de explicações online, tendo como base exclusiva o diagrama de sequência abaixo.

# Diagrama de fluxos - Avaliação de professor

O diagrama de fluxos apresenta uma visão funcional do processo de avaliação de professores, evidenciando as diferentes áreas da aplicação (Área Pública, Área do Aluno, Área de Administração e Serviços Externos) e a forma como o utilizador navega entre elas.
Este diagrama permite compreender:
- O ponto de entrada do utilizador no perfil do professor
- A necessidade de autenticação para submeter uma avaliação
- A submissão e o resultado da avaliação
- O processo de moderação administrativa e envio de notificações por email

```mermaid
---
config:
  layout: dagre
---
flowchart LR
 subgraph site["Interface (Aluno/Professor)"]
        Escolha["Escolher Aula"]
        Opcao{"Ação?"}
        MsgErro["Mensagem de Erro"]
        Confirma["Mensagem de Sucesso"]
  end
 subgraph api["Lógica de Negócio (API)"]
        Validar["Verificar Condições <br> de Tempo/Data"]
        StatusBD[("Atualizar Status <br> na Base de Dados")]
  end
 subgraph pagamentos["External"]
        Stripe["Stripe"]
        Email["Notificar Professor"]
  end
    Escolha --> Opcao
    Validar -- Fora do Prazo --> Pergunta{"Deseja cancelar <br> sem reembolso?"}
    Validar -- No Prazo para cancelar --> Stripe
    StatusBD --> Email
    Opcao -- Remarcar / Cancelar --> Validar
    Validar -- Invalido --> MsgErro
    Validar -- Valido --> Prop["Enviar Proposta <br> ao Professor"]
    Prop --> Aceita{"Professor <br> Aceita?"}
    Aceita -- Sim --> Confirma
    Aceita -- Não --> MsgErro
    Confirma --> StatusBD
    Pergunta -- Sim --> Confirma
```

```mermaid
---
config:
  sequence:
    actorFontSize: 18
    noteFontSize: 40 
    messageFontSize: 26
---
sequenceDiagram
    autonumber
    actor Aluno
    participant Site as Site de Explicações
    participant API as API (backend)
    participant Stripe as Stripe (Pagamentos)
    actor Professor
    participant BD@{ "type": "database" }
    
    
    title Remarcar/Cancelar aula
    Aluno->>Site: Escolhe aula para cancelar/remarcar
    
    
    alt Opção: Cancelar
        Site->>API: Pedido de informações sobre condições de cancelamento
        API->>BD: Devolve os dados da explicação a ser cancelada
        BD->>API: Devolve os dados da explicação a ser cancelada
        API->>BD: Verifica condições de cancelamento (data/hora)
        API->>Site: Envio de mensagem de sucesso / erro das condições para cancelar
        alt Condições válidas para cancelar
            Note over Site: Condição <br/> (Horas de antecedência cumpridas)
            Site->>API: Solicita cancelamento
            API->>Stripe: Envio de dados para devolução
            Stripe-->>API: Estado de devolução alterado
            API-->>Site: Confirmação de devolução/cancelamento
            Site-->>Aluno: Mensagem de confirmação
            Site->>Professor: Notificação de explicação cancelada
            Site->>API: Envio de dados para atualização
            API->>BD: Envio de dados para atualização
            BD->>BD: Ediçao de dados da explicação <br/> (Colocar como cancelada)
        else Condições para cancelar não validas
            Note over Site: Condição <br/> (Horas de antecedência não cumpridas)
            Site->>Aluno: Mensagem a informar que não dá para cancelar a explicação
            Site->>API: Envio de dados para atualização
            API->>BD: Envio de dados para atualização
            BD->>BD: Ediçao de dados da explicação <br/> (Colocar como cancelada)
            alt Aluno escolhe mesmo assim cancelar a aula
                Site->>Aluno: Mensagem a informar que <br/> não dá para cancelar a explicação <br/> e que não será realizado o reembolso
            else Aluno escolhe não cancelar a aula
                Site->>Aluno: Mensagem a informar que a aula continua marcada
            end
            Site->>BD: Envio de dados para atualização
            BD->>BD: Ediçao de dados da explicação <br/> (Colocar como cancelada)
        end
    else Opção: Remarcar
        Site->>API: Pedido de informações sobre condições para remarcar
        API->>BD: Devolve os dados da explicação a ser remarcada
        BD->>API: Devolve os dados da explicação a ser remarcada
        API->>BD: Verifica condições para remarcar (data/hora)
        API->>Site: Envio de mensagem de <br/> sucesso / erro das condições para remarcar
        alt Condições válidas
            Site->>Professor: Notificação de proposta de remarcação
            alt Professor aceita
                Site->>API: Envio de dados para atualização
                API->>BD: Envio de dados para atualização
                BD->>BD: Ediçao de dados da explicação <br/> (Colocar como remarcada e <br/> editar dados de dia/hora da explicação)
                BD->>API: Envio de mensagem de erro / sucesso
                API->>Site: Envio de mensagem de erro / sucesso <br/> de remarcação da aula
                alt Aula remarcada
                    Site-->>Aluno: Envio de mensagem a informar que a explicação foi remarcada
                    Site-->>Professor: Envio de mensagem a informar que a <br/> explicação foi remarcada
                else Aula não remarcada
                    Site-->>Aluno: Envio de mensagem de erro a informar sobre erro a remarcar aula
                    Site-->>Professor: Envio de mensagem de erro a informar sobre erro a remarcar aula
                end
            else Professor não aceita
                Site->>Aluno: Envio de mensagem a dizer que <br/> o professor não aceitou remarcar a explicação
            end
        else Condições inválidas
            Site-->>Aluno: Envio de mensagem de erro sobre impossibilidade de remarcar a explicação
        end
    end
```

# Rotas Necessárias
As rotas apresentadas abaixo são estritamente derivadas dos passos representados nos diagramas, cobrindo todas as funcionalidades e direitos envolvidos (aluno, professor, admin).

### Rotas Frontend
```dart
// Rotas Frontend em formato Flutter (Dart)
const Map<String, Map<String, dynamic>> frontendRoutes = {
    // Cancelar aula (aluno)
    'aulas/{id}/cancelar': {
        'controller': 'LessonController',
        'action': 'cancel',
        'auth': 'aluno',
    },
    // Remarcar aula (aluno)
    'aulas/{id}/remarcar': {
        'controller': 'LessonController',
        'action': 'reschedule',
        'auth': 'aluno',
    },
    // Notificação para professor
    'professor/notificacoes': {
        'controller': 'ProfessorController',
        'action': 'notifications',
        'auth': 'professor',
    },
    // Área do aluno
    'area-aluno': {
        'controller': 'AlunoController',
        'action': 'dashboard',
        'auth': 'aluno',
    },
    // Administração – gestão de aulas
    'admin/aulas': {
        'controller': 'admin/LessonController',
        'action': 'index',
        'auth': true,
        'role': 'admin',
    },
    'admin/aulas/{id}/cancelar': {
        'controller': 'admin/LessonController',
        'action': 'cancel',
        'auth': true,
        'role': 'admin',
    },
    'admin/aulas/{id}/remarcar': {
        'controller': 'admin/LessonController',
        'action': 'reschedule',
        'auth': true,
        'role': 'admin',
    },
};
```

### Rotas API
```C
// Verificar se o aluno pode cancelar/remarcar a aula
GET /api/lessons/can-cancel/{lessonId}
GET /api/lessons/can-reschedule/{lessonId}

// Cancelar aula (aluno)
POST /api/lessons/{id}/cancel

// Remarcar aula (aluno)
POST /api/lessons/{id}/reschedule

// Notificar professor
POST /api/professors/{id}/notify

// Listar aulas (admin)
GET /api/lessons

// Cancelar aula (admin)
PUT /api/lessons/{id}/cancel

// Remarcar aula (admin)
PUT /api/lessons/{id}/reschedule
```

### Tabelas necessárias para cancelar/remarcar explicação
As tabelas abaixo são essenciais para suportar todas as funcionalidades descritas neste documento (aulas, reservas, pagamentos, notificações, permissões, histórico, etc):

```sql
-- Usuários e permissões
CREATE TABLE IF NOT EXISTS roles (...);
CREATE TABLE IF NOT EXISTS users (...);
CREATE TABLE IF NOT EXISTS professors (...);

-- Aulas e agendamentos
CREATE TABLE IF NOT EXISTS lessons (...);
CREATE TABLE IF NOT EXISTS enrollments (...);
CREATE TABLE IF NOT EXISTS reservations (...);
CREATE TABLE IF NOT EXISTS exception_rules (...);
CREATE TABLE IF NOT EXISTS exception_requests (...);

-- Pagamentos e reembolsos
CREATE TABLE IF NOT EXISTS wallets (...);
CREATE TABLE IF NOT EXISTS transactions (...);
CREATE TABLE IF NOT EXISTS refunds (...);

-- Notificações e mensagens
CREATE TABLE IF NOT EXISTS notifications (...);
CREATE TABLE IF NOT EXISTS messages (...);

-- Histórico de alterações (opcional)
-- CREATE TABLE IF NOT EXISTS lesson_history (...);
```

> Para detalhes completos de cada tabela, consulte o arquivo `sql/postgres/schema_all.sql`.