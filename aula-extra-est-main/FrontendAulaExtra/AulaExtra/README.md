AulaExtra (Frontend)

Aplicação frontend escrita em Flutter para o projeto "AulaExtra".

Este repositório contém um frontend (Flutter) e um backend (.NET) separados na raiz do workspace.

Sumário rápido
- Frontend (Flutter): `FrontendAulaExtra/AulaExtra` — aplicação Web/Desktop/Mobile em Flutter.
- Backend (.NET): `BackendAulaExtra` — API e serviços (ver `ENDPOINTS.md` para detalhe dos endpoints).

Estrutura importante (apenas os pontos mais relevantes):

- `lib/` — código principal do app Flutter.
	- `lib/routes/routes.dart` — mapa de rotas nomeadas da app.
	- `lib/features/` — funcionalidades organizadas por feature (ex.: `become_teacher`, `faq`, `register`, `aluno`, `professor`, ...).
	- `lib/features/become_teacher/` — nova feature "Tornar-se Explicador" (páginas, widgets e `constants/`).
	- `lib/core/` — componentes reutilizáveis (header, footer, menus, providers, etc.).

Como executar (Frontend)

Pré-requisitos
- Flutter SDK instalado e configurado: https://docs.flutter.dev/get-started/install
- Um dispositivo/emulador disponível ou executar como web (`chrome`) ou desktop (se suportado).

Comandos comuns

Para instalar dependências:

```bash
cd FrontendAulaExtra/AulaExtra
flutter pub get
```

Para correr na web (Chrome):

```bash
flutter run -d chrome
```

Para correr no dispositivo conectado (ex.: iOS/Android) ou no desktop:

```bash
flutter run
```

Verificações úteis

```bash
cd FrontendAulaExtra/AulaExtra
flutter analyze   # análise estática
flutter format .  # formata código (opcional)
```

Como executar (Backend)

O backend encontra-se em `BackendAulaExtra` e possui um `Dockerfile` e `docker-compose.yml`.

Executar com dotnet (se quiser correr localmente sem docker):

```bash
cd BackendAulaExtra
dotnet run
```

Executar com Docker Compose:

```bash
cd BackendAulaExtra
docker-compose up --build
```

Notas e documentação útil no repositório
- `ENDPOINTS.md` — lista de endpoints e rotas da API.
- `WEBSOCKETS_README.md` — detalhes sobre websockets usados pelo projeto.
- `AgoraIntegrator/` — integração com o serviço Agora (media/RTC); ver `AUTH_IMPLEMENTATION.md`.
- `sql/` e `ConfidantPostgreSQL/` — scripts e infra para base de dados (Postgres).

Onde olhar para alterações recentes que fiz
- `lib/features/become_teacher/constants/become_teacher_constants.dart` — novas constantes centralizadas para a feature "Tornar-se Explicador".
- `lib/features/become_teacher/pages/become_teacher_screen.dart` e `lib/features/become_teacher/widgets/become_teacher_card.dart` — refatorados para usar as constantes.

Contribuir / Desenvolvimento

- Abra uma branch por feature/bugfix e faça PRs contra `main`.
- Execute `flutter analyze` antes de submeter PRs.

Contacto / Ajuda
- Se precisares que eu atualize a documentação com mais detalhes (ex.: variáveis de ambiente necessárias, passos de deploy, ou exemplos de requests à API), diz-me exatamente o que queres incluir e eu edito o README.

---
Arquivo gerado automaticamente: atualizei o README para refletir a estrutura e passos básicos para executar o projeto.

# aula_extra

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
