class ConfiguracoesState {
  const ConfiguracoesState({
    required this.platformName,
    required this.supportEmail,
    required this.systemEmail,
    required this.agoraAppId,
    required this.agoraAppCertificate,
    required this.stripePublishableKey,
    required this.timezone,
    required this.sessionTimeout,
    required this.payoutDay,
    required this.platformCommission,
    required this.vatRate,
    required this.maintenanceMode,
    required this.registrationsOpen,
    required this.require2faForAdmins,
    required this.automaticBackups,
    required this.enableEmailAlerts,
    required this.enableSlackAlerts,
    required this.dailySummaryEnabled,
    required this.websocketLogsEnabled,
  });

  final String platformName;
  final String supportEmail;
  final String systemEmail;
  final String agoraAppId;
  final String agoraAppCertificate;
  final String stripePublishableKey;
  final String timezone;
  final String sessionTimeout;
  final String payoutDay;
  final String platformCommission;
  final String vatRate;
  final bool maintenanceMode;
  final bool registrationsOpen;
  final bool require2faForAdmins;
  final bool automaticBackups;
  final bool enableEmailAlerts;
  final bool enableSlackAlerts;
  final bool dailySummaryEnabled;
  final bool websocketLogsEnabled;

  ConfiguracoesState copyWith({
    String? platformName,
    String? supportEmail,
    String? systemEmail,
    String? agoraAppId,
    String? agoraAppCertificate,
    String? stripePublishableKey,
    String? timezone,
    String? sessionTimeout,
    String? payoutDay,
    String? platformCommission,
    String? vatRate,
    bool? maintenanceMode,
    bool? registrationsOpen,
    bool? require2faForAdmins,
    bool? automaticBackups,
    bool? enableEmailAlerts,
    bool? enableSlackAlerts,
    bool? dailySummaryEnabled,
    bool? websocketLogsEnabled,
  }) {
    return ConfiguracoesState(
      platformName: platformName ?? this.platformName,
      supportEmail: supportEmail ?? this.supportEmail,
      systemEmail: systemEmail ?? this.systemEmail,
      agoraAppId: agoraAppId ?? this.agoraAppId,
      agoraAppCertificate: agoraAppCertificate ?? this.agoraAppCertificate,
      stripePublishableKey: stripePublishableKey ?? this.stripePublishableKey,
      timezone: timezone ?? this.timezone,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      payoutDay: payoutDay ?? this.payoutDay,
      platformCommission: platformCommission ?? this.platformCommission,
      vatRate: vatRate ?? this.vatRate,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      registrationsOpen: registrationsOpen ?? this.registrationsOpen,
      require2faForAdmins: require2faForAdmins ?? this.require2faForAdmins,
      automaticBackups: automaticBackups ?? this.automaticBackups,
      enableEmailAlerts: enableEmailAlerts ?? this.enableEmailAlerts,
      enableSlackAlerts: enableSlackAlerts ?? this.enableSlackAlerts,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      websocketLogsEnabled: websocketLogsEnabled ?? this.websocketLogsEnabled,
    );
  }
}
