import '../models/configuracoes_state.dart';

class ConfiguracoesOptions {
  const ConfiguracoesOptions._();

  static const List<String> timezoneOptions = [
    'Europe/Lisbon',
    'Europe/Madrid',
    'UTC',
  ];

  static const List<String> sessionTimeoutOptions = [
    '15 min',
    '30 min',
    '1 hora',
    '2 horas',
  ];

  static const List<String> payoutDayOptions = [
    'Segunda-feira',
    'Quarta-feira',
    'Sexta-feira',
  ];

  static const ConfiguracoesState initialState = ConfiguracoesState(
    platformName: 'Aula Extra',
    supportEmail: 'suporte@aulaextra.pt',
    systemEmail: 'no-reply@aulaextra.pt',
    agoraAppId: '3f8b8e0a8d29480a9d0f5e1f0e3a6c9d',
    agoraAppCertificate: '********************************',
    stripePublishableKey:
        'pk_test_51NxXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
    timezone: 'Europe/Lisbon',
    sessionTimeout: '30 min',
    payoutDay: 'Sexta-feira',
    platformCommission: '15',
    vatRate: '23',
    maintenanceMode: false,
    registrationsOpen: true,
    require2faForAdmins: true,
    automaticBackups: true,
    enableEmailAlerts: true,
    enableSlackAlerts: false,
    dailySummaryEnabled: true,
    websocketLogsEnabled: true,
  );
}
