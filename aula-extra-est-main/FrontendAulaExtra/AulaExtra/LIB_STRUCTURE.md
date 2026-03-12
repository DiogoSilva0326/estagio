# Estrutura da pasta `lib`

Esta é a estrutura principal da pasta `lib/` do projeto Flutter. Cada pasta tem um propósito específico e deve conter arquivos relacionados à sua funcionalidade. Este guia ajuda a manter o projeto organizado e facilita a colaboração.

```text
lib/
├── core/                  # Componentes e funcionalidades reutilizáveis
│   ├── components/        # Widgets compartilhados (header, footer, menus)
│   ├── providers/         # Gerenciamento de estado (Provider, Bloc, etc.)
│   ├── theme/             # Temas, cores, tipografia e fontes
│   ├── widgets/           # Widgets genéricos usados em todo o app
│   └── packages/          # Integrações ou pacotes internos específicos
│
├── design/                # Configurações visuais do app
│   ├── theme/             # Temas e cores
│   └── typography/        # Fontes e estilos de texto
│
├── features/              # Funcionalidades específicas do app
│   ├── home/              # Tela inicial
│   ├── login/             # Autenticação
│   ├── register/          # Registro de usuários
│   ├── tutor_profile_view/# Perfil de tutores
│   ├── disciplinas/       # Funcionalidade de disciplinas
│   ├── faq/               # Perguntas frequentes
│   ├── explicadores/      # Funcionalidade de explicadores
│   ├── aluno/             # Funcionalidades do lado do aluno
│   │   ├── calendario/    # Calendário de aulas
│   │   ├── pagamentos/    # Gestão de pagamentos
│   │   ├── perfil/        # Perfil do aluno
│   │   ├── avaliacoes/    # Avaliações
│   │   └── areas_aluno/   # Áreas específicas do aluno
│   └── professor/         # Funcionalidades do lado do professor
│       ├── calendario/    # Calendário de aulas
│       ├── pagamentos/    # Gestão de pagamentos
│       ├── perfil/        # Perfil do professor
│       ├── avaliacoes/    # Avaliações de alunos
│       └── meus_alunos/   # Gestão dos alunos do professor
│
├── data/                  # Modelos de dados, mocks ou repositórios
├── routes/                # Configuração de rotas do app
```

## Notas importantes

- **`core/`**: Contém tudo que é compartilhável e reutilizável em várias partes do app, evitando duplicação de código.  
- **`features/`**: Cada funcionalidade tem sua própria pasta; dentro de cada uma, organize arquivos por tipo: `pages`, `widgets`, `sections`, `constants`, `assets`.  
- **`design/`**: Centraliza configurações visuais, como temas e tipografia, para facilitar manutenção e consistência.  
- **`data/`**: Modelos de dados, serviços e repositórios.  
- **`routes/`**: Mantém todas as rotas do aplicativo centralizadas, útil para navegação limpa.