import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/professors/dtos/public_professor_profile_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/core/data/professor_ads/professor_ads_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/aluno/chats/models/chat_bootstrap_args.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/constants/marcar_aula_professor_constants.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/models/marcar_aula_professor_args.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/features/tutor_profile_view/widgets/schedule_grid.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const List<String> _monthShortPt = [
  'jan.',
  'fev.',
  'mar.',
  'abr.',
  'mai.',
  'jun.',
  'jul.',
  'ago.',
  'set.',
  'out.',
  'nov.',
  'dez.',
];

class MarcarAulaProfessorContentSection extends StatefulWidget {
  const MarcarAulaProfessorContentSection({
    super.key,
    required this.args,
  });

  final MarcarAulaProfessorArgs args;

  @override
  State<MarcarAulaProfessorContentSection> createState() =>
      _MarcarAulaProfessorContentSectionState();
}

class _FallbackOption {
  const _FallbackOption({
    required this.id,
    required this.title,
    required this.durationText,
    required this.priceText,
    this.badgeText,
    this.priceHintText,
  });

  final String id;
  final String title;
  final String durationText;
  final String priceText;
  final String? badgeText;
  final String? priceHintText;
}

class _BookingOption {
  const _BookingOption({
    required this.id,
    required this.title,
    required this.kindLabel,
    required this.durationText,
    required this.priceValue,
    required this.priceText,
    required this.subtitle,
    this.badgeText,
    this.priceHintText,
  });

  final String id;
  final String title;
  final String kindLabel;
  final String durationText;
  final double priceValue;
  final String priceText;
  final String subtitle;
  final String? badgeText;
  final String? priceHintText;
}

class _SelectedSlot {
  const _SelectedSlot({
    required this.date,
    required this.startTimeLabel,
    required this.endTimeLabel,
  });

  final DateTime date;
  final String startTimeLabel;
  final String endTimeLabel;
}

class _MarcarAulaProfessorContentSectionState
    extends State<MarcarAulaProfessorContentSection> {
  static const List<_FallbackOption> _fallbackOptions = [
    _FallbackOption(
      id: 'experimental',
      title: 'Aula Experimental',
      durationText: '30 minutos',
      priceText: '15€',
    ),
    _FallbackOption(
      id: 'individual',
      title: 'Aula Individual',
      durationText: '60 minutos',
      priceText: '25€',
    ),
    _FallbackOption(
      id: 'pack-5',
      title: 'Pacote 5 Aulas',
      durationText: '60 minutos × 5',
      priceText: '110€',
      badgeText: '-10%',
      priceHintText: '(22€/aula)',
    ),
    _FallbackOption(
      id: 'pack-10',
      title: 'Pacote 10 Aulas',
      durationText: '60 minutos × 10',
      priceText: '200€',
      badgeText: '-20%',
      priceHintText: '(20€/aula)',
    ),
  ];

  final ProfessorAdsService _adsService = ProfessorAdsService();
  final EducationService _educationService = EducationService(); 
  final ProfessorsService _professorsService = ProfessorsService();

  List<ProfessorAdDto> _ads = const <ProfessorAdDto>[];
  String? _selectedOptionId;
  _SelectedSlot? _selectedSlot;
  String? _adsError;
  String? _profileError;
  bool _isLoadingAds = false;
  bool _isLoadingProfile = false;
  PublicProfessorProfileDto? _publicProfile;

  @override
  void initState() {
    super.initState();
    _selectedOptionId = _buildFallbackOptions().first.id;
    _loadProfessorAds();
    _loadPublicProfessor();
  }

  Future<void> _loadPublicProfessor() async {
    final professorId = widget.args.professorId.trim();
    if (professorId.isEmpty) return;

    setState(() {
      _isLoadingProfile = true;
      _profileError = null;
    });

    try {
      final profile = await _professorsService.getPublicProfessorProfile(
        idProfessor: professorId,
      );
      if (!mounted) return;
      setState(() {
        _publicProfile = profile;
        _isLoadingProfile = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _profileError = error.toString();
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadProfessorAds() async {
    final professorId = widget.args.professorId.trim();
    if (professorId.isEmpty) return;

    setState(() {
      _isLoadingAds = true;
      _adsError = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentTargetRole = userProvider.role == Role.psychologist ? 'psicologia' 
                              : userProvider.role == Role.tutor ? 'tutoria' 
                              : 'ensino';

      final results = await Future.wait([
        _adsService.getProfessorAdsForProfessor(professorId: professorId),
        _educationService.getAreas(targetRole: currentTargetRole),
        _educationService.getCatalog(), 
      ]);

      if (!mounted) return;

      final ads = results[0] as List<ProfessorAdDto>;
      final allowedAreas = results[1] as List<AreaDto>;
      final catalog = results[2] as List<DisciplinaDto>;
      
      final allowedAreaIds = allowedAreas.map((a) => a.idArea).toSet();

      final visibleAds = ads.where((item) {
        final status = item.status.trim().toLowerCase();
        if (!(status.isEmpty || status == 'published' || status == 'active')) return false;

        final disciplina = catalog.firstWhere(
          (d) => d.idDisciplina == item.idDisciplina,
          orElse: () => DisciplinaDto(idDisciplina: '', nome: ''), 
        );
        
        return disciplina.idArea != null && allowedAreaIds.contains(disciplina.idArea);
      }).toList(growable: false);

      final options = _mapAdsToOptions(visibleAds);

      setState(() {
        _ads = visibleAds;
        _selectedOptionId = options.isEmpty
            ? _selectedOptionId
            : _resolveInitialOptionId(options);
        _isLoadingAds = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _adsError = error.toString();
        _isLoadingAds = false;
      });
    }
  }

  List<_BookingOption> _buildFallbackOptions() {
    return _fallbackOptions
        .map(
          (item) => _BookingOption(
            id: item.id,
            title: item.title,
            kindLabel: widget.args.subject,
            durationText: item.durationText,
            priceValue: _parsePrice(item.priceText),
            priceText: item.priceText,
            subtitle: 'Anúncio padrão do explicador',
            badgeText: item.badgeText,
            priceHintText: item.priceHintText,
          ),
        )
        .toList(growable: false);
  }

  List<_BookingOption> _mapAdsToOptions(List<ProfessorAdDto> ads) {
    return ads.map((ad) {
      final title = _displayTitleForAd(ad);
      final kindLabel = (ad.tutoringTypeName ?? '').trim().isEmpty
          ? 'Aula'
          : ad.tutoringTypeName!.trim();
      final priceValue = ad.sessionPrice ?? widget.args.pricePerHour.toDouble();
      return _BookingOption(
        id: ad.idProfessorAd,
        title: title,
        kindLabel: kindLabel,
        durationText: _durationFromType(kindLabel),
        priceValue: priceValue,
        priceText: _formatCurrency(priceValue),
        subtitle: _subtitleForAd(ad),
        badgeText: _badgeForType(kindLabel),
        priceHintText: _hintForType(kindLabel, priceValue),
      );
    }).toList(growable: false);
  }

  List<_BookingOption> get _options {
    final mapped = _mapAdsToOptions(_ads);
    return mapped.isEmpty ? _buildFallbackOptions() : mapped;
  }

  _BookingOption get _selectedOption {
    final options = _options;
    return options.firstWhere(
      (item) => item.id == _selectedOptionId,
      orElse: () => options.first,
    );
  }

  String _resolveInitialOptionId(List<_BookingOption> options) {
    if (_selectedOptionId != null &&
        options.any((item) => item.id == _selectedOptionId)) {
      return _selectedOptionId!;
    }

    final subject = widget.args.subject.trim().toLowerCase();
    final match = options.where(
      (item) => [item.title, item.kindLabel, item.subtitle]
          .join(' ')
          .toLowerCase()
          .contains(subject),
    );

    return match.isNotEmpty ? match.first.id : options.first.id;
  }

  String _displayTitleForAd(ProfessorAdDto ad) {
    final disciplina = ad.disciplinaNome?.trim();
    if (disciplina != null && disciplina.isNotEmpty) return disciplina;
    if (ad.courseName.trim().isNotEmpty) return ad.courseName.trim();
    return widget.args.subject;
  }

  String _subtitleForAd(ProfessorAdDto ad) {
    final parts = <String>[
      if ((ad.cicloEstudos ?? '').trim().isNotEmpty) ad.cicloEstudos!.trim(),
      if (ad.courseName.trim().isNotEmpty &&
          ad.courseName.trim() != _displayTitleForAd(ad))
        ad.courseName.trim(),
    ];
    return parts.isEmpty
        ? 'Disponível com ${widget.args.tutorName}'
        : parts.join(' · ');
  }

  String _durationFromType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('experimental')) return '30 minutos';
    if (normalized.contains('10')) return '60 minutos × 10';
    if (normalized.contains('5')) return '60 minutos × 5';
    return '60 minutos';
  }

  String? _badgeForType(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('10')) return '-20%';
    if (normalized.contains('5')) return '-10%';
    return null;
  }

  String? _hintForType(String value, double priceValue) {
    final normalized = value.trim().toLowerCase();
    if (normalized.contains('10')) return '(${_formatCurrency(priceValue / 10)}/aula)';
    if (normalized.contains('5')) return '(${_formatCurrency(priceValue / 5)}/aula)';
    return null;
  }

  double _parsePrice(String value) {
    final normalized = value.replaceAll('€', '').replaceAll(',', '.').trim();
    return double.tryParse(normalized) ?? 0;
  }

  String _formatCurrency(double value) {
    if (value == value.roundToDouble()) return '${value.round()}€';
    return '${value.toStringAsFixed(2).replaceAll('.', ',')}€';
  }

  void _openTutorProfile() {
    final args = widget.args;
    Navigator.of(context).pushNamed(
      Routes.tutorProfile,
      arguments: TutorProfileArgs(
        professorId: args.professorId,
        name: args.tutorName,
        country: 'Portugal',
        rating: args.rating,
        reviewCount: args.reviewCount,
        description:
            'Sou ${args.tutorName}, um explicador apaixonado por ensinar e ajudar alunos a alcançarem os seus objetivos.',
        lessonsText: '—',
        pricePerHour: args.pricePerHour,
        tags: [args.subject],
      ),
    );
  }

  TimeOfDay _parseTimeLabel(String label, {TimeOfDay fallback = const TimeOfDay(hour: 18, minute: 0)}) {
    final parts = label.split(':');
    if (parts.isEmpty) return fallback;
    final hour = int.tryParse(parts[0]);
    final minute = parts.length > 1 ? int.tryParse(parts[1]) : 0;
    if (hour == null || minute == null) return fallback;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  int _estimatedSessionMinutes() {
    final match = RegExp(r'(\d+)').firstMatch(_selectedOption.durationText);
    final parsed = match == null ? null : int.tryParse(match.group(1)!);
    if (parsed == null || parsed <= 0) return 60;
    return parsed;
  }

  TimeOfDay _addMinutes(TimeOfDay base, int minutesToAdd) {
    final totalMinutes = base.hour * 60 + base.minute + minutesToAdd;
    final normalized = totalMinutes.clamp(0, (23 * 60) + 59);
    return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
  }

  bool _isEndAfterStart(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  Future<void> _pickPreferredSlot() async {
    final now = DateTime.now();
    final initialDate = _selectedSlot?.date ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
    );
    if (!mounted || pickedDate == null) return;

    final initialStartTime = _selectedSlot != null
        ? _parseTimeLabel(_selectedSlot!.startTimeLabel)
        : TimeOfDay.fromDateTime(now);

    final pickedStartTime = await showTimePicker(
      context: context,
      initialTime: initialStartTime,
    );
    if (!mounted || pickedStartTime == null) return;

    final initialEndTime = _selectedSlot != null
        ? _parseTimeLabel(
            _selectedSlot!.endTimeLabel,
            fallback: _addMinutes(pickedStartTime, _estimatedSessionMinutes()),
          )
        : _addMinutes(pickedStartTime, _estimatedSessionMinutes());

    final pickedEndTime = await showTimePicker(
      context: context,
      initialTime: initialEndTime,
    );
    if (!mounted || pickedEndTime == null) return;

    if (!_isEndAfterStart(pickedStartTime, pickedEndTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A hora de fim tem de ser posterior à hora de início.'),
        ),
      );
      return;
    }

    final startTimeLabel = _formatTimeOfDay(pickedStartTime);
    final endTimeLabel = _formatTimeOfDay(pickedEndTime);

    setState(() {
      _selectedSlot = _SelectedSlot(
        date: pickedDate,
        startTimeLabel: startTimeLabel,
        endTimeLabel: endTimeLabel,
      );
    });
  }

  String _formatSelectedDateTime(_SelectedSlot slot) {
    final month = _monthShortPt[slot.date.month - 1];
    return '${slot.date.day} $month, das ${slot.startTimeLabel} às ${slot.endTimeLabel}';
  }

  String _buildInitialContactMessage() {
    final selectedSlot = _selectedSlot;
    final preferredTime = selectedSlot == null
        ? 'A combinar'
        : _formatSelectedDateTime(selectedSlot);

    return [
      'Ola ${widget.args.tutorName}, tenho interesse em marcar uma aula consigo.',
      'Tipo de aula: ${_selectedOption.title}',
      'Modalidade: ${_selectedOption.kindLabel}',
      'Duracao prevista: ${_selectedOption.durationText}',
      'Horario pretendido: $preferredTime',
      'Podemos combinar os detalhes por aqui?',
    ].join('\n');
  }

  void _openContactChat() {
    final profile = _publicProfile;
    final selectedSlot = _selectedSlot;
    if (profile == null || selectedSlot == null) return;

    Navigator.of(context).pushNamed(
      Routes.chats,
      arguments: ChatBootstrapArgs(
        contactUserId: profile.idUser,
        contactName: profile.displayName,
        contactUsername: profile.username,
        initialMessage: _buildInitialContactMessage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;
    final horizontalPadding = isMobile
        ? MarcarAulaProfessorConstants.mobileHorizontalPadding
        : MarcarAulaProfessorConstants.horizontalPadding;
    final verticalPadding = isMobile
        ? MarcarAulaProfessorConstants.mobileVerticalPadding
        : MarcarAulaProfessorConstants.verticalPadding;
    final canOpenContactChat =
        _selectedSlot != null &&
        !_isLoadingProfile &&
        _publicProfile != null &&
        (_publicProfile!.idUser.trim().isNotEmpty ||
            _publicProfile!.username.trim().isNotEmpty);

    final mainColumn = _MainColumn(
      args: args,
      isMobile: isMobile,
      options: _options,
      selectedOptionId: _selectedOption.id,
      selectedSlot: _selectedSlot,
      adsError: _adsError,
      profileError: _profileError,
      isLoadingAds: _isLoadingAds,
      isLoadingProfile: _isLoadingProfile,
      availability: _publicProfile?.availability ?? const [],
      onOptionSelected: (id) => setState(() => _selectedOptionId = id),
      onRetryAds: _loadProfessorAds,
      onRetryProfile: _loadPublicProfessor,
      onPickPreferredSlot: _pickPreferredSlot,
      onClearPreferredSlot: () => setState(() => _selectedSlot = null),
      onViewProfileTap: _openTutorProfile,
    );

    final summary = _SummaryCard(
      args: args,
      isMobile: isMobile,
      option: _selectedOption,
      selectedSlot: _selectedSlot,
      onConfirmTap: canOpenContactChat ? _openContactChat : null,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
            tutorName: args.tutorName,
            isMobile: isMobile,
            onBackTap: () => Navigator.of(context).maybePop(),
          ),
          SizedBox(height: isMobile ? 16 : 24),
          if (isMobile) ...[
            mainColumn,
            const SizedBox(height: 16),
            summary,
          ] else
            LayoutBuilder(
              builder: (context, constraints) {
                final showSideSummary = constraints.maxWidth >= 980;
                if (!showSideSummary) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      mainColumn,
                      const SizedBox(height: 24),
                      summary,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: mainColumn),
                    const SizedBox(width: 32),
                    SizedBox(width: 400, child: summary),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.tutorName,
    required this.isMobile,
    required this.onBackTap,
  });

  final String tutorName;
  final bool isMobile;
  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MarcarAulaProfessorConstants.border),
        borderRadius: BorderRadius.circular(
          MarcarAulaProfessorConstants.cardRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 20,
          vertical: isMobile ? 12 : 16,
        ),
        child: SizedBox(
          height: isMobile ? 54 : 44,
          child: isMobile
              ? Row(
                  children: [
                    IconButton(
                      onPressed: onBackTap,
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(0xFF4A5565),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Marcar aula',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: MarcarAulaProfessorConstants.textMuted,
                            ),
                          ),
                          Text(
                            tutorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: MarcarAulaProfessorConstants.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _TutorBadge(),
                  ],
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onBackTap,
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF4A5565),
                        ),
                        label: const Text(
                          'Voltar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4A5565),
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 84),
                      child: Text.rich(
                        TextSpan(
                          text: 'Marcar Aula com ',
                          style: MarcarAulaProfessorConstants.topBarTitleStyle,
                          children: [
                            TextSpan(
                              text: tutorName,
                              style: MarcarAulaProfessorConstants
                                  .topBarTutorNameStyle,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: _TutorBadge(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _TutorBadge extends StatelessWidget {
  const _TutorBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: MarcarAulaProfessorConstants.orangeGradient,
      ),
      child: const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text(
            'E',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}

class _MainColumn extends StatelessWidget {
  const _MainColumn({
    required this.args,
    required this.isMobile,
    required this.options,
    required this.selectedOptionId,
    required this.selectedSlot,
    required this.adsError,
    required this.profileError,
    required this.isLoadingAds,
    required this.isLoadingProfile,
    required this.availability,
    required this.onOptionSelected,
    required this.onRetryAds,
    required this.onRetryProfile,
    required this.onPickPreferredSlot,
    required this.onClearPreferredSlot,
    required this.onViewProfileTap,
  });

  final MarcarAulaProfessorArgs args;
  final bool isMobile;
  final List<_BookingOption> options;
  final String selectedOptionId;
  final _SelectedSlot? selectedSlot;
  final String? adsError;
  final String? profileError;
  final bool isLoadingAds;
  final bool isLoadingProfile;
  final List<PublicProfessorAvailabilityDto> availability;
  final ValueChanged<String> onOptionSelected;
  final Future<void> Function() onRetryAds;
  final Future<void> Function() onRetryProfile;
  final Future<void> Function() onPickPreferredSlot;
  final VoidCallback onClearPreferredSlot;
  final VoidCallback onViewProfileTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TutorSummaryCard(
          args: args,
          isMobile: isMobile,
          onViewProfileTap: onViewProfileTap,
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _SectionCard(
          isMobile: isMobile,
          child: _LessonOptionsSection(
            options: options,
            selectedOptionId: selectedOptionId,
            isMobile: isMobile,
            isLoadingAds: isLoadingAds,
            errorText: adsError,
            onOptionSelected: onOptionSelected,
            onRetry: onRetryAds,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _SectionCard(
          isMobile: isMobile,
          child: _ScheduleSection(
            isMobile: isMobile,
            selectedSlot: selectedSlot,
            availability: availability,
            isLoadingProfile: isLoadingProfile,
            errorText: profileError,
            onRetryProfile: onRetryProfile,
            onPickPreferredSlot: onPickPreferredSlot,
            onClearPreferredSlot: onClearPreferredSlot,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, required this.isMobile});

  final Widget child;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MarcarAulaProfessorConstants.borderSoft),
        borderRadius: BorderRadius.circular(
          MarcarAulaProfessorConstants.cardRadius,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: child,
      ),
    );
  }
}

class _TutorSummaryCard extends StatelessWidget {
  const _TutorSummaryCard({
    required this.args,
    required this.isMobile,
    required this.onViewProfileTap,
  });

  final MarcarAulaProfessorArgs args;
  final bool isMobile;
  final VoidCallback onViewProfileTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MarcarAulaProfessorConstants.borderSoft),
        borderRadius: BorderRadius.circular(
          MarcarAulaProfessorConstants.cardRadius,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: MarcarAulaProfessorConstants.orange,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            color: MarcarAulaProfessorConstants.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              args.tutorName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: MarcarAulaProfessorConstants.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  label: args.subject.toUpperCase(),
                                  backgroundColor:
                                      MarcarAulaProfessorConstants.blue,
                                  foregroundColor: Colors.white,
                                ),
                                _InfoChip(
                                  label: args.location,
                                  backgroundColor: const Color(0xFFF3F4F6),
                                  foregroundColor:
                                      MarcarAulaProfessorConstants.textMuted,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 20,
                        color: MarcarAulaProfessorConstants.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        args.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${args.reviewCount} avaliações',
                          style: const TextStyle(
                            fontSize: 14,
                            color: MarcarAulaProfessorConstants.textSubtle,
                          ),
                        ),
                      ),
                      Text(
                        '${args.pricePerHour}€/hora',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: MarcarAulaProfessorConstants.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onViewProfileTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: MarcarAulaProfessorConstants.orange,
                        side: const BorderSide(
                          color: MarcarAulaProfessorConstants.orange,
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Ver Perfil'),
                    ),
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: MarcarAulaProfessorConstants.orange,
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: MarcarAulaProfessorConstants.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      args.tutorName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            MarcarAulaProfessorConstants.textDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: MarcarAulaProfessorConstants.blue,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      args.subject.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: onViewProfileTap,
                              child: const Text(
                                'Ver Perfil',
                                style: MarcarAulaProfessorConstants.linkStyle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: MarcarAulaProfessorConstants.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              args.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF4A5565),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '(${args.reviewCount} avaliações)',
                              style: const TextStyle(
                                fontSize: 14,
                                color: MarcarAulaProfessorConstants.textSubtle,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Color(0xFF4A5565),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              args.location,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A5565),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text(
                              'A partir de ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: MarcarAulaProfessorConstants.textDark,
                              ),
                            ),
                            Text(
                              '${args.pricePerHour}€/hora',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: MarcarAulaProfessorConstants.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _LessonOptionsSection extends StatelessWidget {
  const _LessonOptionsSection({
    required this.options,
    required this.selectedOptionId,
    required this.isMobile,
    required this.isLoadingAds,
    required this.errorText,
    required this.onOptionSelected,
    required this.onRetry,
  });

  final List<_BookingOption> options;
  final String selectedOptionId;
  final bool isMobile;
  final bool isLoadingAds;
  final String? errorText;
  final ValueChanged<String> onOptionSelected;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Escolha o tipo de aula',
                style: MarcarAulaProfessorConstants.sectionTitleStyle.copyWith(
                  fontSize: isMobile ? 18 : 20,
                ),
              ),
            ),
            if (isLoadingAds)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Os anúncios do professor aparecem aqui em formato reduzido, no lugar do bloco de tipo de aula.',
          style: TextStyle(
            fontSize: 14,
            color: MarcarAulaProfessorConstants.textMuted,
            height: 1.5,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD6A7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: MarcarAulaProfessorConstants.orange,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Não foi possível carregar os anúncios reais. A mostrar opções padrão.',
                      style: TextStyle(
                        fontSize: 13,
                        color: MarcarAulaProfessorConstants.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => onRetry(),
                    child: const Text('Tentar'),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (isMobile)
          SizedBox(
            height: 178,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final option = options[index];
                return SizedBox(
                  width: 244,
                  child: _CompactBookingOptionCard(
                    option: option,
                    isSelected: option.id == selectedOptionId,
                    onTap: () => onOptionSelected(option.id),
                  ),
                );
              },
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 12.0;
              final itemWidth = constraints.maxWidth >= 920
                  ? (constraints.maxWidth - spacing) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: options
                    .map(
                      (option) => SizedBox(
                        width: itemWidth,
                        child: _CompactBookingOptionCard(
                          option: option,
                          isSelected: option.id == selectedOptionId,
                          onTap: () => onOptionSelected(option.id),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
      ],
    );
  }
}

class _CompactBookingOptionCard extends StatelessWidget {
  const _CompactBookingOptionCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _BookingOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? MarcarAulaProfessorConstants.orange
        : MarcarAulaProfessorConstants.lessonTypeBorder;
    final backgroundColor = isSelected ? const Color(0xFFFFF7ED) : Colors.white;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        MarcarAulaProfessorConstants.compactCardRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              MarcarAulaProfessorConstants.compactCardRadius,
            ),
            border: Border.all(color: borderColor, width: 1.8),
            boxShadow: const [
              BoxShadow(color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        option.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: MarcarAulaProfessorConstants.textDark,
                        ),
                      ),
                    ),
                    if (option.badgeText != null) ...[
                      const SizedBox(width: 8),
                      _InfoChip(
                        label: option.badgeText!,
                        backgroundColor:
                            MarcarAulaProfessorConstants.greenSoft,
                        foregroundColor: MarcarAulaProfessorConstants.green,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      label: option.kindLabel,
                      backgroundColor: const Color(0xFFEFF6FF),
                      foregroundColor: const Color(0xFF155DFC),
                    ),
                    if (option.subtitle.isNotEmpty)
                      _InfoChip(
                        label: option.subtitle,
                        backgroundColor: const Color(0xFFF3F4F6),
                        foregroundColor:
                            MarcarAulaProfessorConstants.textMuted,
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: Color(0xFF4A5565),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        option.durationText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      option.priceText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: MarcarAulaProfessorConstants.orange,
                      ),
                    ),
                    if (option.priceHintText != null) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          option.priceHintText!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: MarcarAulaProfessorConstants.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: foregroundColor,
        ),
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.isMobile,
    required this.selectedSlot,
    required this.availability,
    required this.isLoadingProfile,
    required this.errorText,
    required this.onRetryProfile,
    required this.onPickPreferredSlot,
    required this.onClearPreferredSlot,
  });

  final bool isMobile;
  final _SelectedSlot? selectedSlot;
  final List<PublicProfessorAvailabilityDto> availability;
  final bool isLoadingProfile;
  final String? errorText;
  final Future<void> Function() onRetryProfile;
  final Future<void> Function() onPickPreferredSlot;
  final VoidCallback onClearPreferredSlot;

  @override
  Widget build(BuildContext context) {
    String formatSelectedDate(_SelectedSlot slot) {
      final month = _monthShortPt[slot.date.month - 1];
      return '${slot.date.day} $month, das ${slot.startTimeLabel} às ${slot.endTimeLabel}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disponibilidade do professor',
          style: MarcarAulaProfessorConstants.sectionTitleStyle.copyWith(
            fontSize: isMobile ? 18 : 20,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Estes horários correspondem à disponibilidade real definida no perfil público do professor.',
          style: TextStyle(
            fontSize: 14,
            color: MarcarAulaProfessorConstants.textMuted,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoadingProfile)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (errorText != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFD6A7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: MarcarAulaProfessorConstants.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Não foi possível carregar a disponibilidade real. $errorText',
                      style: const TextStyle(
                        fontSize: 13,
                        color: MarcarAulaProfessorConstants.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => onRetryProfile(),
                    child: const Text('Tentar'),
                  ),
                ],
              ),
            ),
          )
        else
          ScheduleGrid(availability: availability),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: MarcarAulaProfessorConstants.borderSoft),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escolha o horário pretendido para enviar ao professor',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: MarcarAulaProfessorConstants.textDark,
                  ),
                ),
                const SizedBox(height: 10),
                if (selectedSlot != null)
                  Text(
                    formatSelectedDate(selectedSlot!),
                    style: const TextStyle(
                      fontSize: 14,
                      color: MarcarAulaProfessorConstants.orange,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  const Text(
                    'Ainda não escolheu nenhum horário preferido.',
                    style: TextStyle(
                      fontSize: 14,
                      color: MarcarAulaProfessorConstants.textMuted,
                    ),
                  ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => onPickPreferredSlot(),
                      icon: const Icon(Icons.event_available_outlined),
                      label: Text(
                        selectedSlot == null
                            ? 'Escolher início e fim'
                            : 'Alterar horário',
                      ),
                    ),
                    if (selectedSlot != null)
                      TextButton(
                        onPressed: onClearPreferredSlot,
                        child: const Text('Limpar'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.args,
    required this.isMobile,
    required this.option,
    required this.selectedSlot,
    required this.onConfirmTap,
  });

  final MarcarAulaProfessorArgs args;
  final bool isMobile;
  final _BookingOption option;
  final _SelectedSlot? selectedSlot;
  final VoidCallback? onConfirmTap;

  @override
  Widget build(BuildContext context) {
    String formatSelectedDate(_SelectedSlot slot) {
      final month = _monthShortPt[slot.date.month - 1];
      return '${slot.date.day} $month, das ${slot.startTimeLabel} às ${slot.endTimeLabel}';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: MarcarAulaProfessorConstants.borderSoft),
        borderRadius: BorderRadius.circular(
          MarcarAulaProfessorConstants.cardRadius,
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo do Pedido',
              style: MarcarAulaProfessorConstants.sectionTitleStyle.copyWith(
                fontSize: isMobile ? 18 : 20,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              color: MarcarAulaProfessorConstants.borderSoft,
              height: 1,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: MarcarAulaProfessorConstants.orange,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: MarcarAulaProfessorConstants.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        args.tutorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MarcarAulaProfessorConstants.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A5565),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SummaryRow(
              icon: Icons.class_outlined,
              label: 'TIPO DE AULA',
              value: option.kindLabel,
              isMuted: false,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              icon: Icons.event_available,
              label: 'HORÁRIO PRETENDIDO',
              value: selectedSlot == null
                  ? 'Selecione um horário'
                  : formatSelectedDate(selectedSlot!),
              isMuted: selectedSlot == null,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              icon: Icons.schedule,
              label: 'DURAÇÃO',
              value: option.durationText,
              isMuted: false,
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFEDD4)),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFF7ED), Colors.white],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Preço anunciado',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4A5565),
                          ),
                        ),
                        Text(
                          option.priceText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (option.priceHintText != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          option.priceHintText!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: MarcarAulaProfessorConstants.textMuted,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFFFD6A7), height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Duração estimada',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          option.durationText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: MarcarAulaProfessorConstants.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onConfirmTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: onConfirmTap == null
                      ? const Color(0xFFD1D5DC)
                      : MarcarAulaProfessorConstants.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Entrar em contacto',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Será aberta uma conversa com o professor com a sua preferência de horário.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: MarcarAulaProfessorConstants.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isMuted,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: MarcarAulaProfessorConstants.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.4,
                  color: MarcarAulaProfessorConstants.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isMuted
                      ? MarcarAulaProfessorConstants.textSubtle
                      : MarcarAulaProfessorConstants.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}