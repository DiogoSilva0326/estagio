import 'package:flutter/material.dart';

import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/configuracoes_state.dart';
import 'configuracoes_header_section.dart';

enum ConfiguracoesSection {
  geral,
  integracoesApi,
  videochamadas,
  autenticacao,
  servidorEmail,
}

extension ConfiguracoesSectionPresentation on ConfiguracoesSection {
  String get navigationLabel {
    switch (this) {
      case ConfiguracoesSection.geral:
        return 'Geral';
      case ConfiguracoesSection.integracoesApi:
        return 'Integrações API';
      case ConfiguracoesSection.videochamadas:
        return 'Videochamadas (Agora)';
      case ConfiguracoesSection.autenticacao:
        return 'Autenticação';
      case ConfiguracoesSection.servidorEmail:
        return 'Servidor de Email';
    }
  }

  String get title {
    switch (this) {
      case ConfiguracoesSection.geral:
        return 'Geral';
      case ConfiguracoesSection.integracoesApi:
        return 'Integrações API';
      case ConfiguracoesSection.videochamadas:
        return 'Videochamadas';
      case ConfiguracoesSection.autenticacao:
        return 'Autenticação';
      case ConfiguracoesSection.servidorEmail:
        return 'Servidor de Email';
    }
  }

  String get subtitle {
    switch (this) {
      case ConfiguracoesSection.geral:
        return 'Parâmetros base da plataforma, faturação e monitorização operacional.';
      case ConfiguracoesSection.integracoesApi:
        return 'Credenciais e chaves de serviços externos e pagamentos.';
      case ConfiguracoesSection.videochamadas:
        return 'Configuração da integração Agora RTC e testes de ligação.';
      case ConfiguracoesSection.autenticacao:
        return 'Controlos de acesso, disponibilidade e políticas de autenticação.';
      case ConfiguracoesSection.servidorEmail:
        return 'Emails institucionais, links públicos e parâmetros do Postmark.';
    }
  }

  IconData get icon {
    switch (this) {
      case ConfiguracoesSection.geral:
        return Icons.public_rounded;
      case ConfiguracoesSection.integracoesApi:
        return Icons.storage_rounded;
      case ConfiguracoesSection.videochamadas:
        return Icons.videocam_outlined;
      case ConfiguracoesSection.autenticacao:
        return Icons.shield_outlined;
      case ConfiguracoesSection.servidorEmail:
        return Icons.mail_outline_rounded;
    }
  }

  Color get iconBackgroundColor {
    switch (this) {
      case ConfiguracoesSection.geral:
        return const Color(0x26FC9039);
      case ConfiguracoesSection.integracoesApi:
        return const Color(0x2641A7D7);
      case ConfiguracoesSection.videochamadas:
        return const Color(0x26FB7B02);
      case ConfiguracoesSection.autenticacao:
        return const Color(0x26FDB022);
      case ConfiguracoesSection.servidorEmail:
        return const Color(0x26F15C64);
    }
  }

  Color get iconColor {
    switch (this) {
      case ConfiguracoesSection.geral:
        return const Color(0xFFFC9039);
      case ConfiguracoesSection.integracoesApi:
        return const Color(0xFF41A7D7);
      case ConfiguracoesSection.videochamadas:
        return const Color(0xFFFB7B02);
      case ConfiguracoesSection.autenticacao:
        return const Color(0xFFFDB022);
      case ConfiguracoesSection.servidorEmail:
        return const Color(0xFFF15C64);
    }
  }
}

class ConfiguracoesOverviewSection extends StatelessWidget {
  const ConfiguracoesOverviewSection({
    required this.state,
    required this.platformNameController,
    required this.supportEmailController,
    required this.systemEmailController,
    required this.agoraAppIdController,
    required this.agoraAppCertificateController,
    required this.stripePublishableKeyController,
    required this.siteUrlController,
    required this.emailLinksBaseUrlController,
    required this.postmarkApiKeyController,
    required this.postmarkEmailFromController,
    required this.newsletterEmailFromController,
    required this.timezoneController,
    required this.sessionTimeoutController,
    required this.payoutDayController,
    required this.platformCommissionController,
    required this.vatRateController,
    required this.loadingRemoteSettings,
    required this.savingRemoteSettings,
    required this.selectedSection,
    required this.onSectionChanged,
    required this.onMaintenanceModeChanged,
    required this.onRegistrationsOpenChanged,
    required this.onRequire2faChanged,
    required this.onAutomaticBackupsChanged,
    required this.onEmailAlertsChanged,
    required this.onSlackAlertsChanged,
    required this.onDailySummaryChanged,
    required this.onWebsocketLogsChanged,
    required this.onSave,
    required this.onTestConnection,
    super.key,
  });

  final ConfiguracoesState state;
  final TextEditingController platformNameController;
  final TextEditingController supportEmailController;
  final TextEditingController systemEmailController;
  final TextEditingController agoraAppIdController;
  final TextEditingController agoraAppCertificateController;
  final TextEditingController stripePublishableKeyController;
  final TextEditingController siteUrlController;
  final TextEditingController emailLinksBaseUrlController;
  final TextEditingController postmarkApiKeyController;
  final TextEditingController postmarkEmailFromController;
  final TextEditingController newsletterEmailFromController;
  final TextEditingController timezoneController;
  final TextEditingController sessionTimeoutController;
  final TextEditingController payoutDayController;
  final TextEditingController platformCommissionController;
  final TextEditingController vatRateController;
  final bool loadingRemoteSettings;
  final bool savingRemoteSettings;
  final ConfiguracoesSection selectedSection;
  final ValueChanged<ConfiguracoesSection> onSectionChanged;
  final ValueChanged<bool> onMaintenanceModeChanged;
  final ValueChanged<bool> onRegistrationsOpenChanged;
  final ValueChanged<bool> onRequire2faChanged;
  final ValueChanged<bool> onAutomaticBackupsChanged;
  final ValueChanged<bool> onEmailAlertsChanged;
  final ValueChanged<bool> onSlackAlertsChanged;
  final ValueChanged<bool> onDailySummaryChanged;
  final ValueChanged<bool> onWebsocketLogsChanged;
  final VoidCallback onSave;
  final VoidCallback onTestConnection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConfiguracoesHeaderSection(onSave: onSave),
        const SizedBox(height: 37.273),
        DashboardSurfaceCard(
          padding: const EdgeInsets.all(1.165),
          borderRadius: 27.955,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 860;

              if (isCompact) {
                return Column(
                  children: [
                    _SettingsNavigation(
                      selectedSection: selectedSection,
                      onSectionChanged: onSectionChanged,
                    ),
                    const Divider(height: 1.165, color: Color(0xFFF9FAFB)),
                    _SettingsContent(
                      state: state,
                      selectedSection: selectedSection,
                      platformNameController: platformNameController,
                      supportEmailController: supportEmailController,
                      systemEmailController: systemEmailController,
                      agoraAppIdController: agoraAppIdController,
                      agoraAppCertificateController: agoraAppCertificateController,
                      stripePublishableKeyController: stripePublishableKeyController,
                      siteUrlController: siteUrlController,
                      emailLinksBaseUrlController: emailLinksBaseUrlController,
                      postmarkApiKeyController: postmarkApiKeyController,
                      postmarkEmailFromController: postmarkEmailFromController,
                      newsletterEmailFromController: newsletterEmailFromController,
                      timezoneController: timezoneController,
                      sessionTimeoutController: sessionTimeoutController,
                      payoutDayController: payoutDayController,
                      platformCommissionController: platformCommissionController,
                      vatRateController: vatRateController,
                      loadingRemoteSettings: loadingRemoteSettings,
                      savingRemoteSettings: savingRemoteSettings,
                      onMaintenanceModeChanged: onMaintenanceModeChanged,
                      onRegistrationsOpenChanged: onRegistrationsOpenChanged,
                      onRequire2faChanged: onRequire2faChanged,
                      onAutomaticBackupsChanged: onAutomaticBackupsChanged,
                      onEmailAlertsChanged: onEmailAlertsChanged,
                      onSlackAlertsChanged: onSlackAlertsChanged,
                      onDailySummaryChanged: onDailySummaryChanged,
                      onWebsocketLogsChanged: onWebsocketLogsChanged,
                      onTestConnection: onTestConnection,
                    ),
                  ],
                );
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 298,
                      child: _SettingsNavigation(
                        selectedSection: selectedSection,
                        onSectionChanged: onSectionChanged,
                      ),
                    ),
                    const VerticalDivider(
                      width: 1.165,
                      color: Color(0xFFF9FAFB),
                    ),
                    Expanded(
                      child: _SettingsContent(
                        state: state,
                        selectedSection: selectedSection,
                        platformNameController: platformNameController,
                        supportEmailController: supportEmailController,
                        systemEmailController: systemEmailController,
                        agoraAppIdController: agoraAppIdController,
                        agoraAppCertificateController: agoraAppCertificateController,
                        stripePublishableKeyController: stripePublishableKeyController,
                        siteUrlController: siteUrlController,
                        emailLinksBaseUrlController: emailLinksBaseUrlController,
                        postmarkApiKeyController: postmarkApiKeyController,
                        postmarkEmailFromController: postmarkEmailFromController,
                        newsletterEmailFromController: newsletterEmailFromController,
                        timezoneController: timezoneController,
                        sessionTimeoutController: sessionTimeoutController,
                        payoutDayController: payoutDayController,
                        platformCommissionController: platformCommissionController,
                        vatRateController: vatRateController,
                        loadingRemoteSettings: loadingRemoteSettings,
                        savingRemoteSettings: savingRemoteSettings,
                        onMaintenanceModeChanged: onMaintenanceModeChanged,
                        onRegistrationsOpenChanged: onRegistrationsOpenChanged,
                        onRequire2faChanged: onRequire2faChanged,
                        onAutomaticBackupsChanged: onAutomaticBackupsChanged,
                        onEmailAlertsChanged: onEmailAlertsChanged,
                        onSlackAlertsChanged: onSlackAlertsChanged,
                        onDailySummaryChanged: onDailySummaryChanged,
                        onWebsocketLogsChanged: onWebsocketLogsChanged,
                        onTestConnection: onTestConnection,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SettingsNavigation extends StatelessWidget {
  const _SettingsNavigation({
    required this.selectedSection,
    required this.onSectionChanged,
  });

  final ConfiguracoesSection selectedSection;
  final ValueChanged<ConfiguracoesSection> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x80F9FAFB),
      padding: const EdgeInsets.fromLTRB(27.955, 27.955, 29.12, 27.955),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _NavigationButton(
            icon: ConfiguracoesSection.geral.icon,
            label: ConfiguracoesSection.geral.navigationLabel,
            isActive: selectedSection == ConfiguracoesSection.geral,
            onTap: () => onSectionChanged(ConfiguracoesSection.geral),
          ),
          const SizedBox(height: 9.318),
          _NavigationButton(
            icon: ConfiguracoesSection.integracoesApi.icon,
            label: ConfiguracoesSection.integracoesApi.navigationLabel,
            isActive: selectedSection == ConfiguracoesSection.integracoesApi,
            onTap: () => onSectionChanged(ConfiguracoesSection.integracoesApi),
          ),
          const SizedBox(height: 9.318),
          _NavigationButton(
            icon: ConfiguracoesSection.videochamadas.icon,
            label: ConfiguracoesSection.videochamadas.navigationLabel,
            isActive: selectedSection == ConfiguracoesSection.videochamadas,
            onTap: () => onSectionChanged(ConfiguracoesSection.videochamadas),
          ),
          const SizedBox(height: 9.318),
          _NavigationButton(
            icon: ConfiguracoesSection.autenticacao.icon,
            label: ConfiguracoesSection.autenticacao.navigationLabel,
            isActive: selectedSection == ConfiguracoesSection.autenticacao,
            onTap: () => onSectionChanged(ConfiguracoesSection.autenticacao),
          ),
          const SizedBox(height: 9.318),
          _NavigationButton(
            icon: ConfiguracoesSection.servidorEmail.icon,
            label: ConfiguracoesSection.servidorEmail.navigationLabel,
            isActive: selectedSection == ConfiguracoesSection.servidorEmail,
            onTap: () => onSectionChanged(ConfiguracoesSection.servidorEmail),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.307),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.307),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18.55, vertical: 14.05),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16.307),
            border: isActive ? Border.all(color: const Color(0xFFF3F4F6)) : null,
            boxShadow: isActive
                ? const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 16.307,
                      offset: Offset(0, 4.659),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 23.296,
                color: isActive ? const Color(0xFFFC9039) : const Color(0xFF6A7282),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? const Color(0xFFFC9039)
                        : const Color(0xFF6A7282),
                    fontSize: 16.307,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1752,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.state,
    required this.selectedSection,
    required this.platformNameController,
    required this.supportEmailController,
    required this.systemEmailController,
    required this.agoraAppIdController,
    required this.agoraAppCertificateController,
    required this.stripePublishableKeyController,
    required this.siteUrlController,
    required this.emailLinksBaseUrlController,
    required this.postmarkApiKeyController,
    required this.postmarkEmailFromController,
    required this.newsletterEmailFromController,
    required this.timezoneController,
    required this.sessionTimeoutController,
    required this.payoutDayController,
    required this.platformCommissionController,
    required this.vatRateController,
    required this.loadingRemoteSettings,
    required this.savingRemoteSettings,
    required this.onMaintenanceModeChanged,
    required this.onRegistrationsOpenChanged,
    required this.onRequire2faChanged,
    required this.onAutomaticBackupsChanged,
    required this.onEmailAlertsChanged,
    required this.onSlackAlertsChanged,
    required this.onDailySummaryChanged,
    required this.onWebsocketLogsChanged,
    required this.onTestConnection,
  });

  final ConfiguracoesState state;
  final ConfiguracoesSection selectedSection;
  final TextEditingController platformNameController;
  final TextEditingController supportEmailController;
  final TextEditingController systemEmailController;
  final TextEditingController agoraAppIdController;
  final TextEditingController agoraAppCertificateController;
  final TextEditingController stripePublishableKeyController;
  final TextEditingController siteUrlController;
  final TextEditingController emailLinksBaseUrlController;
  final TextEditingController postmarkApiKeyController;
  final TextEditingController postmarkEmailFromController;
  final TextEditingController newsletterEmailFromController;
  final TextEditingController timezoneController;
  final TextEditingController sessionTimeoutController;
  final TextEditingController payoutDayController;
  final TextEditingController platformCommissionController;
  final TextEditingController vatRateController;
  final bool loadingRemoteSettings;
  final bool savingRemoteSettings;
  final ValueChanged<bool> onMaintenanceModeChanged;
  final ValueChanged<bool> onRegistrationsOpenChanged;
  final ValueChanged<bool> onRequire2faChanged;
  final ValueChanged<bool> onAutomaticBackupsChanged;
  final ValueChanged<bool> onEmailAlertsChanged;
  final ValueChanged<bool> onSlackAlertsChanged;
  final ValueChanged<bool> onDailySummaryChanged;
  final ValueChanged<bool> onWebsocketLogsChanged;
  final VoidCallback onTestConnection;

  @override
  Widget build(BuildContext context) {
    final cards = _buildCards();

    return Container(
      padding: const EdgeInsets.fromLTRB(46.592, 46.592, 64.064, 46.592),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContentHeader(section: selectedSection),
          const SizedBox(height: 37.273),
          for (var index = 0; index < cards.length; index++) ...[
            cards[index],
            if (index != cards.length - 1) const SizedBox(height: 27.955),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildCards() {
    switch (selectedSection) {
      case ConfiguracoesSection.geral:
        return [
          _IntegrationCard(
            title: 'Geral da Plataforma',
            subtitle: 'Identidade pública e parâmetros base da operação diária.',
            icon: Icons.public_rounded,
            iconBackgroundColor: const Color(0x26FC9039),
            iconColor: const Color(0xFFFC9039),
            statusLabel: 'ATIVO',
            statusTextColor: const Color(0xFF4CAF50),
            statusBackgroundColor: const Color(0x1A4CAF50),
            children: [
              _ConfigField(
                label: 'NOME DA PLATAFORMA',
                controller: platformNameController,
                icon: Icons.badge_rounded,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'URL PÚBLICA PRINCIPAL',
                controller: siteUrlController,
                icon: Icons.language_rounded,
                readOnly: loadingRemoteSettings || savingRemoteSettings,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'TIMEZONE',
                controller: timezoneController,
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
          _IntegrationCard(
            title: 'Operação e Faturação',
            subtitle: 'Regras operacionais e parâmetros económicos usados pela plataforma.',
            icon: Icons.tune_rounded,
            iconBackgroundColor: const Color(0x2641A7D7),
            iconColor: const Color(0xFF41A7D7),
            statusLabel: 'CONFIGURÁVEL',
            statusTextColor: const Color(0xFF6A7282),
            statusBackgroundColor: const Color(0xFFF3F4F6),
            children: [
              _ConfigField(
                label: 'DIA DE PAYOUT',
                controller: payoutDayController,
                icon: Icons.calendar_month_rounded,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'COMISSÃO DA PLATAFORMA (%)',
                controller: platformCommissionController,
                icon: Icons.percent_rounded,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'IVA (%)',
                controller: vatRateController,
                icon: Icons.receipt_long_rounded,
              ),
            ],
          ),
          _IntegrationCard(
            title: 'Alertas e Observabilidade',
            subtitle: 'Controlo de backups, alertas operacionais e sinais internos de monitorização.',
            icon: Icons.monitor_heart_outlined,
            iconBackgroundColor: const Color(0x2612B76A),
            iconColor: const Color(0xFF12B76A),
            statusLabel: 'MONITORIZADO',
            statusTextColor: const Color(0xFF12B76A),
            statusBackgroundColor: const Color(0x1A12B76A),
            children: [
              _ToggleField(
                label: 'Backups automáticos',
                description: 'Mantém snapshots automáticos das entidades críticas.',
                value: state.automaticBackups,
                onChanged: onAutomaticBackupsChanged,
              ),
              const SizedBox(height: 14),
              _ToggleField(
                label: 'Alertas por email',
                description: 'Envia notificações por email quando há eventos críticos.',
                value: state.enableEmailAlerts,
                onChanged: onEmailAlertsChanged,
              ),
              const SizedBox(height: 14),
              _ToggleField(
                label: 'Alertas por Slack',
                description: 'Replica alertas operacionais para canais internos.',
                value: state.enableSlackAlerts,
                onChanged: onSlackAlertsChanged,
              ),
              const SizedBox(height: 14),
              _ToggleField(
                label: 'Resumo diário',
                description: 'Ativa o envio ou geração de um resumo diário do sistema.',
                value: state.dailySummaryEnabled,
                onChanged: onDailySummaryChanged,
              ),
              const SizedBox(height: 14),
              _ToggleField(
                label: 'Logs de websocket',
                description: 'Mantém logs detalhados da camada realtime.',
                value: state.websocketLogsEnabled,
                onChanged: onWebsocketLogsChanged,
              ),
            ],
          ),
        ];
      case ConfiguracoesSection.integracoesApi:
        return [
          _IntegrationCard(
            title: 'Stripe / Pagamentos',
            subtitle: 'Processamento de pagamentos e payouts automáticos.',
            icon: Icons.credit_card_rounded,
            iconBackgroundColor: const Color(0x2641A7D7),
            iconColor: const Color(0xFF41A7D7),
            statusLabel: 'MODO TESTE',
            statusTextColor: const Color(0xFF6A7282),
            statusBackgroundColor: const Color(0xFFF3F4F6),
            children: [
              _ConfigField(
                label: 'PUBLISHABLE KEY',
                controller: stripePublishableKeyController,
                icon: Icons.key_rounded,
                readOnly: loadingRemoteSettings || savingRemoteSettings,
              ),
            ],
          ),
        ];
      case ConfiguracoesSection.videochamadas:
        return [
          _IntegrationCard(
            title: 'Agora RTC (Videochamadas)',
            subtitle: 'Motor de chamadas de voz e vídeo em tempo real.',
            icon: Icons.videocam_outlined,
            iconBackgroundColor: const Color(0x26FB7B02),
            iconColor: const Color(0xFFFB7B02),
            statusLabel: 'ATIVO',
            statusTextColor: const Color(0xFF4CAF50),
            statusBackgroundColor: const Color(0x1A4CAF50),
            children: [
              _ConfigField(
                label: 'APP ID',
                controller: agoraAppIdController,
                icon: Icons.key_rounded,
                readOnly: loadingRemoteSettings || savingRemoteSettings,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'APP CERTIFICATE',
                controller: agoraAppCertificateController,
                icon: Icons.vpn_key_outlined,
                readOnly: loadingRemoteSettings || savingRemoteSettings,
              ),
              const SizedBox(height: 18.637),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: onTestConnection,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4A5565),
                    side: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1.165,
                    ),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.637,
                      vertical: 10.483,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.978,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.648),
                    ),
                  ),
                  child: const Text('Testar Conexão'),
                ),
              ),
            ],
          ),
        ];
      case ConfiguracoesSection.autenticacao:
        return [
          _IntegrationCard(
            title: 'Acesso e Segurança',
            subtitle: 'Flags de acesso, segurança operacional e disponibilidade do sistema.',
            icon: Icons.shield_outlined,
            iconBackgroundColor: const Color(0x26FDB022),
            iconColor: const Color(0xFFFDB022),
            statusLabel: state.maintenanceMode ? 'MANUTENÇÃO' : 'ATIVO',
            statusTextColor: state.maintenanceMode
                ? const Color(0xFFED1C24)
                : const Color(0xFF4CAF50),
            statusBackgroundColor: state.maintenanceMode
                ? const Color(0x80FFBDC0)
                : const Color(0x1A4CAF50),
            children: [
              _ConfigField(
                label: 'TIMEOUT DE SESSÃO',
                controller: sessionTimeoutController,
                icon: Icons.timer_outlined,
              ),
              const SizedBox(height: 18.637),
              _ToggleField(
                label: 'Modo de manutenção',
                description: 'Bloqueia acesso normal e deixa a plataforma em modo controlado.',
                value: state.maintenanceMode,
                onChanged: onMaintenanceModeChanged,
              ),
              const SizedBox(height: 14),
              _ToggleField(
                label: 'Inscrições abertas',
                description: 'Permite o registo de novos utilizadores e adesões.',
                value: state.registrationsOpen,
                onChanged: onRegistrationsOpenChanged,
              ),
              const SizedBox(height: 14),
              _ToggleField(
                label: '2FA obrigatório para admins',
                description: 'Exige autenticação de dois fatores nas contas administrativas.',
                value: state.require2faForAdmins,
                onChanged: onRequire2faChanged,
              ),
            ],
          ),
        ];
      case ConfiguracoesSection.servidorEmail:
        return [
          _IntegrationCard(
            title: 'Identidade e Entrega de Email',
            subtitle: 'Emails institucionais, links públicos e remetentes operacionais.',
            icon: Icons.email_outlined,
            iconBackgroundColor: const Color(0x26F15C64),
            iconColor: const Color(0xFFF15C64),
            statusLabel: loadingRemoteSettings
                ? 'A CARREGAR'
                : savingRemoteSettings
                    ? 'A GUARDAR'
                    : 'ATIVO',
            statusTextColor: loadingRemoteSettings || savingRemoteSettings
                ? const Color(0xFF6A7282)
                : const Color(0xFF4CAF50),
            statusBackgroundColor: loadingRemoteSettings || savingRemoteSettings
                ? const Color(0xFFF3F4F6)
                : const Color(0x1A4CAF50),
            children: [
              _ConfigField(
                label: 'EMAIL DE SUPORTE',
                controller: supportEmailController,
                icon: Icons.support_agent_rounded,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'EMAIL DE SISTEMA',
                controller: systemEmailController,
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'URL BASE PARA LINKS DE EMAIL',
                controller: emailLinksBaseUrlController,
                icon: Icons.link_rounded,
                readOnly: loadingRemoteSettings || savingRemoteSettings,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'POSTMARK API KEY',
                controller: postmarkApiKeyController,
                icon: Icons.key_rounded,
                readOnly: loadingRemoteSettings || savingRemoteSettings,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'EMAIL FROM',
                controller: postmarkEmailFromController,
                icon: Icons.alternate_email_rounded,
                readOnly: loadingRemoteSettings || savingRemoteSettings,
              ),
              const SizedBox(height: 18.637),
              _ConfigField(
                label: 'NEWSLETTER EMAIL FROM',
                controller: newsletterEmailFromController,
                icon: Icons.forward_to_inbox_rounded,
                readOnly: loadingRemoteSettings || savingRemoteSettings,
              ),
            ],
          ),
        ];
    }
  }
}

class _ContentHeader extends StatelessWidget {
  const _ContentHeader({required this.section});

  final ConfiguracoesSection section;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 29.12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF9FAFB), width: 1.165),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55.91,
            height: 55.91,
            decoration: BoxDecoration(
              color: section.iconBackgroundColor,
              borderRadius: BorderRadius.circular(18.637),
            ),
            child: Icon(
              section.icon,
              color: section.iconColor,
              size: 27.955,
            ),
          ),
          const SizedBox(width: 18.637),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                section.title,
                style: const TextStyle(
                  color: Color(0xFF101828),
                  fontSize: 27.955,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.0819,
                ),
              ),
              const SizedBox(height: 4.659),
              Text(
                section.subtitle,
                style: const TextStyle(
                  color: Color(0xFF99A1AF),
                  fontSize: 16.307,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.1752,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IntegrationCard extends StatelessWidget {
  const _IntegrationCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.statusLabel,
    required this.statusTextColor,
    required this.statusBackgroundColor,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String statusLabel;
  final Color statusTextColor;
  final Color statusBackgroundColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(29.12, 29.12, 29.12, 29.12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.637),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.165),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 11.648,
            offset: Offset(0, 2.33),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46.592,
                height: 46.592,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(16.307),
                ),
                child: Icon(icon, color: iconColor, size: 23.296),
              ),
              const SizedBox(width: 18.637),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 20.966,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5119,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF99A1AF),
                        fontSize: 15.142,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                        letterSpacing: -0.0887,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(
                label: statusLabel,
                textColor: statusTextColor,
                backgroundColor: statusBackgroundColor,
                showDot: statusLabel == 'ATIVO',
              ),
            ],
          ),
          if (children.isNotEmpty) ...[
            const SizedBox(height: 27.955),
            ...children,
          ],
        ],
      ),
    );
  }
}

class _ConfigField extends StatelessWidget {
  const _ConfigField({
    required this.label,
    required this.controller,
    required this.icon,
    this.readOnly = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6A7282),
            fontSize: 12.813,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3563,
          ),
        ),
        const SizedBox(height: 9.318),
        Container(
          height: 48.921,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16.307),
            border: Border.all(color: const Color(0xFFF3F4F6), width: 1.165),
          ),
          child: Row(
            children: [
              const SizedBox(width: 13.89),
              Icon(icon, size: 18.637, color: const Color(0xFF9AA1AF)),
              const SizedBox(width: 13.89),
              Expanded(
                child: TextField(
                  controller: controller,
                  readOnly: readOnly,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: TextStyle(
                    color: Color(0xFF4A5565),
                    fontSize: 16.307,
                  ),
                ),
              ),
              const SizedBox(width: 18.637),
            ],
          ),
        ),
      ],
    );
  }
}

class _ToggleField extends StatelessWidget {
  const _ToggleField({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18.637, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16.307),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.165),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontSize: 15.142,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF6A7282),
                    fontSize: 13.978,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFC9039),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    this.showDot = false,
  });

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13.978, vertical: 6.989),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(11.648),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6.989,
              height: 6.989,
              decoration: BoxDecoration(
                color: textColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: textColor.withValues(alpha: 0.5),
                    blurRadius: 9.318,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 9.318),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 13.978,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6989,
            ),
          ),
        ],
      ),
    );
  }
}
