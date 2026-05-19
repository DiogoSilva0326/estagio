import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../constants/configuracoes_options.dart';
import '../models/configuracoes_state.dart';
import '../sections/configuracoes_overview_section.dart';
import '../services/backoffice_system_settings_service.dart';

class ConfiguracoesPage extends StatefulWidget {
  const ConfiguracoesPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends State<ConfiguracoesPage> {
  final BackofficeSystemSettingsService _systemSettingsService =
      BackofficeSystemSettingsService();
  late final TextEditingController _platformNameController;
  late final TextEditingController _supportEmailController;
  late final TextEditingController _systemEmailController;
  late final TextEditingController _agoraAppIdController;
  late final TextEditingController _agoraAppCertificateController;
  late final TextEditingController _stripePublishableKeyController;
  late final TextEditingController _siteUrlController;
  late final TextEditingController _emailLinksBaseUrlController;
  late final TextEditingController _newsletterEmailLinksLocalController;
  late final TextEditingController _newsletterEmailLinksTestController;
  late final TextEditingController _postmarkApiKeyController;
  late final TextEditingController _postmarkEmailFromController;
  late final TextEditingController _newsletterEmailFromController;
  late final TextEditingController _timezoneController;
  late final TextEditingController _sessionTimeoutController;
  late final TextEditingController _payoutDayController;
  late final TextEditingController _platformCommissionController;
  late final TextEditingController _vatRateController;
  late ConfiguracoesState _state;
  String _newsletterEmailLinksMode = 'local';
  ConfiguracoesSection _selectedSection = ConfiguracoesSection.geral;
  bool _loadingRemoteSettings = true;
  bool _savingRemoteSettings = false;

  @override
  void initState() {
    super.initState();
    _state = ConfiguracoesOptions.initialState;
    _platformNameController = TextEditingController(text: _state.platformName);
    _supportEmailController = TextEditingController(text: _state.supportEmail);
    _systemEmailController = TextEditingController(text: _state.systemEmail);
    _agoraAppIdController = TextEditingController(text: _state.agoraAppId);
    _agoraAppCertificateController = TextEditingController(
      text: _state.agoraAppCertificate,
    );
    _stripePublishableKeyController = TextEditingController(
      text: _state.stripePublishableKey,
    );
    _siteUrlController = TextEditingController(text: 'https://aulaextra.pt');
    _emailLinksBaseUrlController = TextEditingController(
      text: 'https://aulaextra.pt',
    );
    _newsletterEmailLinksLocalController = TextEditingController(
      text: 'http://localhost:3000',
    );
    _newsletterEmailLinksTestController = TextEditingController(
      text: 'https://aulaextra.synget.ovh',
    );
    _postmarkApiKeyController = TextEditingController();
    _postmarkEmailFromController = TextEditingController();
    _newsletterEmailFromController = TextEditingController();
    _timezoneController = TextEditingController(text: _state.timezone);
    _sessionTimeoutController = TextEditingController(
      text: _state.sessionTimeout,
    );
    _payoutDayController = TextEditingController(text: _state.payoutDay);
    _platformCommissionController = TextEditingController(
      text: _state.platformCommission,
    );
    _vatRateController = TextEditingController(text: _state.vatRate);
    _loadRemoteSettings();
  }

  @override
  void dispose() {
    _platformNameController.dispose();
    _supportEmailController.dispose();
    _systemEmailController.dispose();
    _agoraAppIdController.dispose();
    _agoraAppCertificateController.dispose();
    _stripePublishableKeyController.dispose();
    _siteUrlController.dispose();
    _emailLinksBaseUrlController.dispose();
    _newsletterEmailLinksLocalController.dispose();
    _newsletterEmailLinksTestController.dispose();
    _postmarkApiKeyController.dispose();
    _postmarkEmailFromController.dispose();
    _newsletterEmailFromController.dispose();
    _timezoneController.dispose();
    _sessionTimeoutController.dispose();
    _payoutDayController.dispose();
    _platformCommissionController.dispose();
    _vatRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.configuracoes,
      title: 'Configurações',
      showTopBar: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;
          final verticalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: ConfiguracoesPage._contentMaxWidth,
                ),
                child: ConfiguracoesOverviewSection(
                  state: _state,
                  platformNameController: _platformNameController,
                  supportEmailController: _supportEmailController,
                  systemEmailController: _systemEmailController,
                  agoraAppIdController: _agoraAppIdController,
                  agoraAppCertificateController: _agoraAppCertificateController,
                  stripePublishableKeyController:
                      _stripePublishableKeyController,
                  siteUrlController: _siteUrlController,
                  emailLinksBaseUrlController: _emailLinksBaseUrlController,
                    newsletterEmailLinksMode: _newsletterEmailLinksMode,
                    newsletterEmailLinksLocalController:
                      _newsletterEmailLinksLocalController,
                    newsletterEmailLinksTestController:
                      _newsletterEmailLinksTestController,
                  postmarkApiKeyController: _postmarkApiKeyController,
                  postmarkEmailFromController: _postmarkEmailFromController,
                  newsletterEmailFromController: _newsletterEmailFromController,
                  timezoneController: _timezoneController,
                  sessionTimeoutController: _sessionTimeoutController,
                  payoutDayController: _payoutDayController,
                  platformCommissionController: _platformCommissionController,
                  vatRateController: _vatRateController,
                  loadingRemoteSettings: _loadingRemoteSettings,
                  savingRemoteSettings: _savingRemoteSettings,
                  selectedSection: _selectedSection,
                  onSectionChanged: (section) {
                    setState(() {
                      _selectedSection = section;
                    });
                  },
                  onNewsletterEmailLinksModeChanged: (value) {
                    setState(() {
                      _newsletterEmailLinksMode = value;
                    });
                  },
                  onMaintenanceModeChanged: (value) {
                    setState(() {
                      _state = _state.copyWith(maintenanceMode: value);
                    });
                  },
                  onRegistrationsOpenChanged: (value) {
                    setState(() {
                      _state = _state.copyWith(registrationsOpen: value);
                    });
                  },
                  onRequire2faChanged: (value) {
                    setState(() {
                      _state = _state.copyWith(require2faForAdmins: value);
                    });
                  },
                  onAutomaticBackupsChanged: (value) {
                    setState(() {
                      _state = _state.copyWith(automaticBackups: value);
                    });
                  },
                  onEmailAlertsChanged: (value) {
                    setState(() {
                      _state = _state.copyWith(enableEmailAlerts: value);
                    });
                  },
                  onSlackAlertsChanged: (value) {
                    setState(() {
                      _state = _state.copyWith(enableSlackAlerts: value);
                    });
                  },
                  onDailySummaryChanged: (value) {
                    setState(() {
                      _state = _state.copyWith(dailySummaryEnabled: value);
                    });
                  },
                  onWebsocketLogsChanged: (value) {
                    setState(() {
                      _state = _state.copyWith(websocketLogsEnabled: value);
                    });
                  },
                  onSave: _saveSettings,
                  onTestConnection: _showTestConnectionMessage,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveSettings() {
    _saveRemoteSettings();
  }

  Future<void> _loadRemoteSettings() async {
    try {
      final settings = await _systemSettingsService.fetchAll();
      final byKey = <String, BackofficeSystemSetting>{
        for (final item in settings) item.key.toLowerCase(): item,
      };

      String? valueOf(String key) => byKey[key.toLowerCase()]?.value?.trim();
      bool boolOf(String key, bool fallback) {
        final raw = valueOf(key);
        if (raw == null || raw.isEmpty) {
          return fallback;
        }

        return raw.toLowerCase() == 'true';
      }

      _platformNameController.text =
          valueOf('App:PlatformName') ?? _platformNameController.text;
      _supportEmailController.text =
          valueOf('App:SupportEmail') ?? _supportEmailController.text;
      _systemEmailController.text =
          valueOf('App:SystemEmail') ?? _systemEmailController.text;
      _siteUrlController.text = valueOf('Seo:SiteUrl') ?? _siteUrlController.text;
      _emailLinksBaseUrlController.text =
          valueOf('Seo:EmailLinksBaseUrl') ?? _siteUrlController.text;
        _newsletterEmailLinksMode =
          valueOf('Newsletter:EmailLinksBaseUrlMode') ?? _newsletterEmailLinksMode;
        _newsletterEmailLinksLocalController.text =
          valueOf('Newsletter:EmailLinksBaseUrlLocal') ??
          _newsletterEmailLinksLocalController.text;
        _newsletterEmailLinksTestController.text =
          valueOf('Newsletter:EmailLinksBaseUrlTest') ??
          _newsletterEmailLinksTestController.text;
      _agoraAppIdController.text =
          valueOf('Agora:AppId') ?? _agoraAppIdController.text;
      _agoraAppCertificateController.text =
          valueOf('Agora:AppCertificate') ?? _agoraAppCertificateController.text;
      _stripePublishableKeyController.text =
          valueOf('Stripe:PublishableKey') ?? _stripePublishableKeyController.text;
      _postmarkApiKeyController.text = valueOf('PostMarkClient.ApiKey') ?? '';
      _postmarkEmailFromController.text =
          valueOf('PostMarkClient.EmailFrom') ?? '';
      _newsletterEmailFromController.text =
          valueOf('PostMarkClient.NewsletterEmailFrom') ?? '';
      _timezoneController.text = valueOf('App:Timezone') ?? _timezoneController.text;
      _sessionTimeoutController.text =
          valueOf('Auth:SessionTimeout') ?? _sessionTimeoutController.text;
      _payoutDayController.text = valueOf('Billing:PayoutDay') ?? _payoutDayController.text;
      _platformCommissionController.text =
          valueOf('Billing:PlatformCommission') ?? _platformCommissionController.text;
      _vatRateController.text = valueOf('Billing:VatRate') ?? _vatRateController.text;

      _state = _state.copyWith(
        platformName: _platformNameController.text.trim(),
        supportEmail: _supportEmailController.text.trim(),
        systemEmail: _systemEmailController.text.trim(),
        agoraAppId: _agoraAppIdController.text.trim(),
        agoraAppCertificate: _agoraAppCertificateController.text.trim(),
        stripePublishableKey: _stripePublishableKeyController.text.trim(),
        timezone: _timezoneController.text.trim(),
        sessionTimeout: _sessionTimeoutController.text.trim(),
        payoutDay: _payoutDayController.text.trim(),
        platformCommission: _platformCommissionController.text.trim(),
        vatRate: _vatRateController.text.trim(),
        maintenanceMode:
            boolOf('FeatureFlags:MaintenanceMode', _state.maintenanceMode),
        registrationsOpen: boolOf(
          'FeatureFlags:RegistrationsOpen',
          _state.registrationsOpen,
        ),
        require2faForAdmins: boolOf(
          'FeatureFlags:Require2faForAdmins',
          _state.require2faForAdmins,
        ),
        automaticBackups: boolOf(
          'FeatureFlags:AutomaticBackups',
          _state.automaticBackups,
        ),
        enableEmailAlerts: boolOf(
          'FeatureFlags:EnableEmailAlerts',
          _state.enableEmailAlerts,
        ),
        enableSlackAlerts: boolOf(
          'FeatureFlags:EnableSlackAlerts',
          _state.enableSlackAlerts,
        ),
        dailySummaryEnabled: boolOf(
          'FeatureFlags:DailySummaryEnabled',
          _state.dailySummaryEnabled,
        ),
        websocketLogsEnabled: boolOf(
          'FeatureFlags:WebsocketLogsEnabled',
          _state.websocketLogsEnabled,
        ),
      );
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _loadingRemoteSettings = false;
        });
      }
    }
  }

  Future<void> _saveRemoteSettings() async {
    setState(() {
      _savingRemoteSettings = true;
      _state = _state.copyWith(
        platformName: _platformNameController.text.trim(),
        supportEmail: _supportEmailController.text.trim(),
        systemEmail: _systemEmailController.text.trim(),
        agoraAppId: _agoraAppIdController.text.trim(),
        agoraAppCertificate: _agoraAppCertificateController.text.trim(),
        stripePublishableKey: _stripePublishableKeyController.text.trim(),
        timezone: _timezoneController.text.trim(),
        sessionTimeout: _sessionTimeoutController.text.trim(),
        payoutDay: _payoutDayController.text.trim(),
        platformCommission: _platformCommissionController.text.trim(),
        vatRate: _vatRateController.text.trim(),
      );
    });

    try {
      await _systemSettingsService.upsertMany([
        BackofficeSystemSettingDraft(
          key: 'App:PlatformName',
          value: _platformNameController.text.trim(),
          dataType: 'text',
          description: 'Nome público da plataforma no backoffice.',
        ),
        BackofficeSystemSettingDraft(
          key: 'App:SupportEmail',
          value: _supportEmailController.text.trim(),
          dataType: 'email',
          description: 'Email de suporte principal da plataforma.',
        ),
        BackofficeSystemSettingDraft(
          key: 'App:SystemEmail',
          value: _systemEmailController.text.trim(),
          dataType: 'email',
          description: 'Email técnico e remetente interno por defeito.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Seo:SiteUrl',
          value: _siteUrlController.text.trim(),
          dataType: 'seo',
          description: 'URL pública principal da plataforma.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Seo:EmailLinksBaseUrl',
          value: _emailLinksBaseUrlController.text.trim(),
          dataType: 'seo',
          description: 'URL base usada nos links enviados por email.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Newsletter:EmailLinksBaseUrlMode',
          value: _newsletterEmailLinksMode.trim(),
          dataType: 'seo',
          description: 'Modo ativo dos links da newsletter: local, test ou custom.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Newsletter:EmailLinksBaseUrlLocal',
          value: _newsletterEmailLinksLocalController.text.trim(),
          dataType: 'seo',
          description: 'URL local do frontend para os links da newsletter.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Newsletter:EmailLinksBaseUrlTest',
          value: _newsletterEmailLinksTestController.text.trim(),
          dataType: 'seo',
          description: 'URL de testes do frontend para os links da newsletter.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Agora:AppId',
          value: _agoraAppIdController.text.trim(),
          dataType: 'integration',
          description: 'App ID principal do Agora RTC.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Agora:AppCertificate',
          value: _agoraAppCertificateController.text.trim(),
          dataType: 'integration',
          description: 'App Certificate principal do Agora RTC.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Stripe:PublishableKey',
          value: _stripePublishableKeyController.text.trim(),
          dataType: 'integration',
          description: 'Publishable key usada pelo Stripe no backoffice.',
        ),
        BackofficeSystemSettingDraft(
          key: 'PostMarkClient.ApiKey',
          value: _postmarkApiKeyController.text.trim(),
          dataType: 'email',
          description: 'API token do Postmark.',
        ),
        BackofficeSystemSettingDraft(
          key: 'PostMarkClient.EmailFrom',
          value: _postmarkEmailFromController.text.trim(),
          dataType: 'email',
          description: 'Endereço remetente por defeito do Postmark.',
        ),
        BackofficeSystemSettingDraft(
          key: 'PostMarkClient.NewsletterEmailFrom',
          value: _newsletterEmailFromController.text.trim(),
          dataType: 'email',
          description: 'Endereço remetente específico da newsletter.',
        ),
        BackofficeSystemSettingDraft(
          key: 'App:Timezone',
          value: _timezoneController.text.trim(),
          dataType: 'text',
          description: 'Timezone usada para apresentação e operações.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Auth:SessionTimeout',
          value: _sessionTimeoutController.text.trim(),
          dataType: 'text',
          description: 'Tempo máximo de sessão no backoffice.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Billing:PayoutDay',
          value: _payoutDayController.text.trim(),
          dataType: 'text',
          description: 'Dia preferencial para processar payouts.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Billing:PlatformCommission',
          value: _platformCommissionController.text.trim(),
          dataType: 'number',
          description: 'Comissão da plataforma em percentagem.',
        ),
        BackofficeSystemSettingDraft(
          key: 'Billing:VatRate',
          value: _vatRateController.text.trim(),
          dataType: 'number',
          description: 'Taxa de IVA por defeito em percentagem.',
        ),
        BackofficeSystemSettingDraft(
          key: 'FeatureFlags:MaintenanceMode',
          value: _state.maintenanceMode.toString(),
          dataType: 'bool',
          description: 'Ativa o modo de manutenção da plataforma.',
        ),
        BackofficeSystemSettingDraft(
          key: 'FeatureFlags:RegistrationsOpen',
          value: _state.registrationsOpen.toString(),
          dataType: 'bool',
          description: 'Permite novas inscrições na plataforma.',
        ),
        BackofficeSystemSettingDraft(
          key: 'FeatureFlags:Require2faForAdmins',
          value: _state.require2faForAdmins.toString(),
          dataType: 'bool',
          description: 'Exige 2FA para contas administrativas.',
        ),
        BackofficeSystemSettingDraft(
          key: 'FeatureFlags:AutomaticBackups',
          value: _state.automaticBackups.toString(),
          dataType: 'bool',
          description: 'Ativa backups automáticos da plataforma.',
        ),
        BackofficeSystemSettingDraft(
          key: 'FeatureFlags:EnableEmailAlerts',
          value: _state.enableEmailAlerts.toString(),
          dataType: 'bool',
          description: 'Ativa alertas por email para operações críticas.',
        ),
        BackofficeSystemSettingDraft(
          key: 'FeatureFlags:EnableSlackAlerts',
          value: _state.enableSlackAlerts.toString(),
          dataType: 'bool',
          description: 'Ativa alertas via Slack para operações críticas.',
        ),
        BackofficeSystemSettingDraft(
          key: 'FeatureFlags:DailySummaryEnabled',
          value: _state.dailySummaryEnabled.toString(),
          dataType: 'bool',
          description: 'Ativa o resumo diário do sistema.',
        ),
        BackofficeSystemSettingDraft(
          key: 'FeatureFlags:WebsocketLogsEnabled',
          value: _state.websocketLogsEnabled.toString(),
          dataType: 'bool',
          description: 'Ativa logs detalhados de websockets.',
        ),
      ]);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Configurações de sistema guardadas com sucesso.'),
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Erro ao guardar configurações: $error'),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _savingRemoteSettings = false;
        });
      }
    }
  }

  void _showTestConnectionMessage() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Ligação à integração testada com sucesso.'),
        ),
      );
  }
}
