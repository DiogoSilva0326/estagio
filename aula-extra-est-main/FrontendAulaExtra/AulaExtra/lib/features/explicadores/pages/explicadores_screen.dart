import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/components/header/variants/header_aluno.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/education/dtos/ciclo_estudo_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/tutors/dtos/tutor_browse_item_dto.dart';
import 'package:aula_extra/core/data/tutors/tutors_browse_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/aluno/marcar_aula_professor/models/marcar_aula_professor_args.dart';
import 'package:aula_extra/features/explicadores/sections/explicadores_mobile_content_header_section.dart';
import 'package:aula_extra/features/explicadores/sections/explicadores_mobile_filters_sheet.dart';
import 'package:aula_extra/features/explicadores/sections/explicadores_mobile_hero_section.dart';
import 'package:aula_extra/features/explicadores/sections/explicadores_hero_section.dart';
import 'package:aula_extra/features/explicadores/sections/filters_sidebar_section.dart';
import 'package:aula_extra/features/explicadores/sections/main_content_header_section.dart';
import 'package:aula_extra/features/explicadores/widgets/explicadores_mobile_tutor_card.dart';
import 'package:aula_extra/features/explicadores/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/explicadores/widgets/tutor_card.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExplicadoresScreenArgs {
  const ExplicadoresScreenArgs({this.initialQuery = ''});

  final String initialQuery;
}

class ExplicadoresScreen extends StatefulWidget {
  const ExplicadoresScreen({super.key});

  @override
  State<ExplicadoresScreen> createState() => _ExplicadoresScreenState();
}

class _ExplicadoresScreenState extends State<ExplicadoresScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PrimaryScrollController(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: PinnedHeaderDelegate(
                height: AppHeader.resolvedHeight(context),
                child: AppHeader(
                  headerAlunoActiveItem: HeaderAlunoItem.maisExplicadores,
                  onRegisterTap: () =>
                      Navigator.of(context).pushNamed(Routes.registerStudent),
                  onLoginTap: () =>
                      Navigator.of(context).pushNamed(Routes.login),
                  onLogoTap: () => Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(Routes.home, (route) => false),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (isMobile)
                    SizedBox(
                      width: double.infinity,
                      child: ExplicadoresMobileHeroSection(
                        onCustomizeTap: () {
                          _scrollController.animateTo(
                            AppHeader.resolvedHeight(context) + 360,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          );
                        },
                      ),
                    )
                  else
                    const SizedBox(
                      width: double.infinity,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
                          ),
                        ),
                        child: FullBleedScaledSection(
                          child: ExplicadoresHeroSection(),
                        ),
                      ),
                    ),
                  ColoredBox(
                    color: const Color(0xFFF9F9F9),
                    child: SizedBox(
                      width: double.infinity,
                      child: isMobile
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 32),
                              child: _MobileMainArea(),
                            )
                          : const FullBleedScaledSection(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: _MainArea(),
                              ),
                            ),
                    ),
                  ),
                  const ColoredBox(
                    color: Color(0xFFF9F9F9),
                    child: FooterSection(),
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

class _MobileMainArea extends StatelessWidget {
  const _MobileMainArea();

  @override
  Widget build(BuildContext context) {
    return const _MainAreaContent();
  }
}

class _MainArea extends StatelessWidget {
  const _MainArea();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.85),
      child: _MainAreaContent(),
    );
  }
}

class _MainAreaContent extends StatefulWidget {
  const _MainAreaContent();

  @override
  State<_MainAreaContent> createState() => _MainAreaContentState();
}

class _MainAreaContentState extends State<_MainAreaContent> {
  static const int _pageSize = 4;

  final _browseService = TutorsBrowseService();
  final _educationService = EducationService();
  final _searchController = TextEditingController();
  final _priceController = TextEditingController();
  bool _didApplyRouteArgs = false;
  bool _initialFetchTriggered = false;

  bool _loading = false;
  String? _error;

  int _page = 1;
  int _total = 0;
  List<TutorBrowseItemDto> _items = const [];

  List<DisciplinaDto> _disciplinas = const [];
  List<CicloEstudoDto> _ciclos = const [];

  String? _selectedDisciplinaId;
  String? _selectedCicloId;
  Set<AvailabilityOption> _availability = <AvailabilityOption>{};
  double? _maxPrice;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _loadLookups();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyIncomingArgs();
    _triggerInitialFetchIfNeeded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final ciclos = await _educationService.getPublicCiclosEstudo();
      final disciplinas = await _educationService
          .getPublicDisciplinasWithProfessors();
      if (!mounted) return;
      final matchedDisciplinaId = _didApplyRouteArgs
          ? _findMatchingDisciplinaId(_searchController.text, disciplinas)
          : null;

      setState(() {
        _ciclos = ciclos;
        _disciplinas = disciplinas;
        if (matchedDisciplinaId != null) {
          _selectedDisciplinaId = matchedDisciplinaId;
        }
      });

      if (matchedDisciplinaId != null && _initialFetchTriggered) {
        _fetch(page: 1, append: false);
      }
    } catch (_) {
      // Ignore lookup failures; tutors list still works (browse endpoint is public).
    }
  }

  void _applyIncomingArgs() {
    if (_didApplyRouteArgs) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ExplicadoresScreenArgs) {
      final query = args.initialQuery.trim();
      _searchController.text = query;
      _selectedDisciplinaId = _findMatchingDisciplinaId(query, _disciplinas);
    }

    _didApplyRouteArgs = true;
  }

  void _triggerInitialFetchIfNeeded() {
    if (_initialFetchTriggered) return;
    _initialFetchTriggered = true;
    _fetch(page: 1, append: false);
  }

  String _normalizeText(String value) {
    const source = 'áàâãäåéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÅÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
    const target = 'aaaaaaeeeeiiiiooooouuuucnAAAAAAEEEEIIIIOOOOOUUUUCN';

    final buffer = StringBuffer();
    for (final rune in value.trim().toLowerCase().runes) {
      final character = String.fromCharCode(rune);
      final index = source.indexOf(character);
      buffer.write(index >= 0 ? target[index].toLowerCase() : character);
    }

    return buffer.toString();
  }

  String? _findMatchingDisciplinaId(
    String query,
    List<DisciplinaDto> disciplinas,
  ) {
    final normalizedQuery = _normalizeText(query);
    if (normalizedQuery.isEmpty) return null;

    DisciplinaDto? partialMatch;

    for (final disciplina in disciplinas) {
      final normalizedName = _normalizeText(disciplina.nome);
      if (normalizedName == normalizedQuery) {
        return disciplina.idDisciplina;
      }

      if (normalizedName.contains(normalizedQuery) ||
          normalizedQuery.contains(normalizedName)) {
        partialMatch ??= disciplina;
      }
    }

    return partialMatch?.idDisciplina;
  }

  List<String>? _availabilityQuery() {
    if (_availability.isEmpty) return null;
    return _availability
        .map(
          (a) => switch (a) {
            AvailabilityOption.morning => 'morning',
            AvailabilityOption.afternoon => 'afternoon',
            AvailabilityOption.evening => 'evening',
            AvailabilityOption.weekend => 'weekend',
          },
        )
        .toList(growable: false);
  }

  Future<void> _fetch({required int page, required bool append}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final q = _searchController.text.trim();
      final resp = await _browseService.browse(
        q: q.isEmpty ? null : q,
        disciplinaId: _selectedDisciplinaId,
        cicloId: _selectedCicloId,
        maxPrice: _maxPrice,
        minRating: _minRating,
        availability: _availabilityQuery(),
        page: page,
        pageSize: _pageSize,
      );

      if (mounted) {
        setState(() {
          _page = resp.page;
          _total = resp.total;
          _items = append ? [..._items, ...resp.items] : resp.items;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedDisciplinaId = null;
      _selectedCicloId = null;
      _availability = <AvailabilityOption>{};
      _maxPrice = null;
      _minRating = null;
      _searchController.clear();
      _priceController.clear();
    });
    _fetch(page: 1, append: false);
  }

  void _onPriceChanged(String rawValue) {
    final normalized = rawValue.trim().replaceAll(',', '.');
    setState(() {
      if (normalized.isEmpty) {
        _maxPrice = null;
        return;
      }

      final parsed = double.tryParse(normalized);
      if (parsed != null && parsed > 0) {
        _maxPrice = parsed;
      }
    });
  }

  void _applyFilters() {
    _fetch(page: 1, append: false);
  }

  void _loadMore() {
    final hasMore = _items.length < _total;
    if (!hasMore) return;
    _fetch(page: _page + 1, append: true);
  }

  String? _resolvedPhotoUrl(String? rawValue) {
    final normalized = rawValue?.trim() ?? '';
    if (normalized.isEmpty) return null;

    final absoluteUri = Uri.tryParse(normalized);
    if (absoluteUri != null && absoluteUri.hasScheme) {
      return absoluteUri.toString();
    }

    final baseUri = Uri.parse(
      ApiConfig.baseUrl.endsWith('/')
          ? ApiConfig.baseUrl
          : '${ApiConfig.baseUrl}/',
    );
    final sanitized = normalized.replaceAll('\\', '/');
    return baseUri
        .resolve(sanitized.startsWith('/') ? sanitized.substring(1) : sanitized)
        .toString();
  }

  List<String> _tagsForTutor(TutorBrowseItemDto tutor) {
    final candidates = [
      ...tutor.tags,
      ...tutor.educationLevels,
      if (tutor.primarySubject.trim().isNotEmpty) tutor.primarySubject.trim(),
    ];

    final deduped = <String>[];
    for (final value in candidates) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      if (deduped.contains(trimmed)) continue;
      deduped.add(trimmed);
    }
    return deduped;
  }

  TutorProfileArgs _profileArgsForTutor(TutorBrowseItemDto tutor) {
    final country = tutor.subtitle.trim().isEmpty
        ? 'Online'
        : tutor.subtitle.trim();

    return TutorProfileArgs(
      professorId: tutor.idProfessor,
      name: tutor.name,
      country: country,
      rating: tutor.rating,
      reviewCount: tutor.reviewCount,
      description: tutor.description,
      lessonsText: '${tutor.lessonsCount} aulas',
      pricePerHour: tutor.minPrice.round(),
      tags: _tagsForTutor(tutor),
    );
  }

  void _openTutorProfile(TutorBrowseItemDto tutor) {
    Navigator.of(
      context,
    ).pushNamed(Routes.tutorProfile, arguments: _profileArgsForTutor(tutor));
  }

  void _openBookLesson(TutorBrowseItemDto tutor) {
    final role = context.read<UserProvider>().role;
    if (role != Role.student) {
      Navigator.of(context).pushNamed(Routes.login);
      return;
    }

    final subject = tutor.primarySubject.trim().isNotEmpty
        ? tutor.primarySubject.trim()
        : (_tagsForTutor(tutor).isNotEmpty
              ? _tagsForTutor(tutor).first
              : 'Explicação');

    Navigator.of(context).pushNamed(
      Routes.marcarAulaProfessor,
      arguments: MarcarAulaProfessorArgs(
        professorId: tutor.idProfessor,
        tutorName: tutor.name,
        subject: subject,
        rating: tutor.rating,
        reviewCount: tutor.reviewCount,
        location: tutor.subtitle.trim().isEmpty
            ? 'Online'
            : tutor.subtitle.trim(),
        pricePerHour: tutor.minPrice.round(),
      ),
    );
  }

  String? _accentChipLabel(String country) {
    final normalized = _normalizeText(country);
    if (normalized.isEmpty ||
        normalized == 'portugal' ||
        normalized == 'online') {
      return null;
    }
    return 'Nativo';
  }

  Future<void> _showMobileFiltersSheet({
    required List<FilterOption> levelOptions,
    required List<FilterOption> disciplinaOptions,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ExplicadoresMobileFiltersSheet(
          initialMaxPrice: _maxPrice,
          initialPriceText: _priceController.text,
          initialSelectedLevelId: _selectedCicloId,
          initialAvailability: _availability,
          initialSelectedDisciplinaId: _selectedDisciplinaId,
          initialMinRating: _minRating,
          levelOptions: levelOptions,
          disciplinaOptions: disciplinaOptions,
          onApply:
              ({
                String? selectedLevelId,
                Set<AvailabilityOption>? availability,
                String? selectedDisciplinaId,
                double? maxPrice,
                double? minRating,
                String? priceText,
              }) {
                setState(() {
                  _selectedCicloId = selectedLevelId;
                  _availability = availability ?? <AvailabilityOption>{};
                  _selectedDisciplinaId = selectedDisciplinaId;
                  _maxPrice = maxPrice;
                  _minRating = minRating;
                  _priceController.text = priceText ?? '';
                });
                _applyFilters();
              },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;
    final disciplinaOptions = <DisciplinaOption>[
      const DisciplinaOption(id: null, label: 'Todos'),
      ..._disciplinas
          .where((d) => d.idDisciplina.trim().isNotEmpty)
          .map((d) => DisciplinaOption(id: d.idDisciplina, label: d.nome)),
    ];

    final levelOptions = _ciclos
        .where((c) => c.idCicloEstudo.trim().isNotEmpty)
        .map((c) => FilterOption(id: c.idCicloEstudo, label: c.nome))
        .toList(growable: false);

    final disciplinaFilterOptions = _disciplinas
        .where((d) => d.idDisciplina.trim().isNotEmpty)
        .map((d) => FilterOption(id: d.idDisciplina, label: d.nome))
        .toList(growable: false);

    final hasMore = _items.length < _total;

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExplicadoresMobileContentHeaderSection(
            searchController: _searchController,
            onSearchSubmitted: (_) => _applyFilters(),
            disciplinaOptions: disciplinaOptions,
            selectedDisciplinaId: _selectedDisciplinaId,
            onDisciplinaChanged: (id) {
              setState(() => _selectedDisciplinaId = id);
              _applyFilters();
            },
            onFiltersTap: () => _showMobileFiltersSheet(
              levelOptions: levelOptions,
              disciplinaOptions: disciplinaFilterOptions,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _TutorsSection(
              items: _items,
              loading: _loading,
              error: _error,
              hasMore: hasMore,
              onLoadMore: _loadMore,
              isMobile: true,
              onViewProfileTap: _openTutorProfile,
              onBookLessonTap: _openBookLesson,
              resolvePhotoUrl: _resolvedPhotoUrl,
              accentChipLabelForCountry: _accentChipLabel,
              tagsForTutor: _tagsForTutor,
            ),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FiltersSidebarSection(
          maxPrice: _maxPrice,
          priceController: _priceController,
          onPriceTextChanged: _onPriceChanged,
          onMaxPriceChanged: (v) {
            setState(() {
              _maxPrice = v;
              _priceController.text = v.round().toString();
            });
          },
          levelOptions: levelOptions,
          selectedLevelId: _selectedCicloId,
          onLevelChanged: (id) => setState(() => _selectedCicloId = id),
          availability: _availability,
          onAvailabilityChanged: (v) => setState(() => _availability = v),
          disciplinaOptions: disciplinaFilterOptions,
          selectedDisciplinaId: _selectedDisciplinaId,
          onDisciplinaChanged: (id) =>
              setState(() => _selectedDisciplinaId = id),
          minRating: _minRating,
          onMinRatingChanged: (v) => setState(() => _minRating = v),
          onClear: _clearFilters,
          onApply: _applyFilters,
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MainContentHeaderSection(
                searchController: _searchController,
                onSearchSubmitted: (_) => _applyFilters(),
                disciplinaOptions: disciplinaOptions,
                selectedDisciplinaId: _selectedDisciplinaId,
                onDisciplinaChanged: (id) {
                  setState(() => _selectedDisciplinaId = id);
                  _applyFilters();
                },
              ),
              const SizedBox(height: 30),
              _TutorsSection(
                items: _items,
                loading: _loading,
                error: _error,
                hasMore: hasMore,
                onLoadMore: _loadMore,
                isMobile: false,
                onViewProfileTap: _openTutorProfile,
                onBookLessonTap: _openBookLesson,
                resolvePhotoUrl: _resolvedPhotoUrl,
                accentChipLabelForCountry: _accentChipLabel,
                tagsForTutor: _tagsForTutor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TutorsSection extends StatelessWidget {
  const _TutorsSection({
    required this.items,
    required this.loading,
    required this.error,
    required this.hasMore,
    required this.onLoadMore,
    required this.isMobile,
    required this.onViewProfileTap,
    required this.onBookLessonTap,
    required this.resolvePhotoUrl,
    required this.accentChipLabelForCountry,
    required this.tagsForTutor,
  });

  final List<TutorBrowseItemDto> items;
  final bool loading;
  final String? error;
  final bool hasMore;
  final VoidCallback onLoadMore;
  final bool isMobile;
  final ValueChanged<TutorBrowseItemDto> onViewProfileTap;
  final ValueChanged<TutorBrowseItemDto> onBookLessonTap;
  final String? Function(String?) resolvePhotoUrl;
  final String? Function(String) accentChipLabelForCountry;
  final List<String> Function(TutorBrowseItemDto) tagsForTutor;

  @override
  Widget build(BuildContext context) {
    if (loading && items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(color: Color(0xFFFC9039)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error != null && items.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Não foi possível carregar os explicadores.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A7282),
              ),
            ),
          ),
        if (isMobile)
          Column(
            children: [
              for (final tutor in items) ...[
                ExplicadoresMobileTutorCard(
                  photoUrl: resolvePhotoUrl(tutor.photo),
                  name: tutor.name,
                  country: tutor.subtitle.trim().isEmpty
                      ? 'Online'
                      : tutor.subtitle.trim(),
                  rating: tutor.rating,
                  reviewCount: tutor.reviewCount,
                  description: tutor.description,
                  lessonsText: '${tutor.lessonsCount}+ aulas',
                  pricePerHour: tutor.minPrice.round(),
                  tags: tagsForTutor(tutor),
                  accentChipLabel: accentChipLabelForCountry(
                    tutor.subtitle.trim().isEmpty
                        ? 'Online'
                        : tutor.subtitle.trim(),
                  ),
                  onViewProfileTap: () => onViewProfileTap(tutor),
                  onBookLessonTap: () => onBookLessonTap(tutor),
                ),
                if (tutor != items.last) const SizedBox(height: 16),
              ],
            ],
          )
        else
          Wrap(
            spacing: 30,
            runSpacing: 30,
            children: [
              for (final tutor in items)
                TutorCard(
                  name: tutor.name,
                  country: tutor.subtitle.isNotEmpty
                      ? tutor.subtitle
                      : 'Online',
                  rating: tutor.rating,
                  reviewCount: tutor.reviewCount,
                  description: tutor.description,
                  lessonsText: '${tutor.lessonsCount} aulas',
                  pricePerHour: tutor.minPrice.round(),
                  tags: tutor.tags,
                  onViewProfileTap: () => onViewProfileTap(tutor),
                ),
            ],
          ),
        if (!loading && items.isEmpty) ...[
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Sem resultados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A7282),
              ),
            ),
          ),
        ],
        if (hasMore) ...[
          const SizedBox(height: 30),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 220,
              height: 56,
              child: OutlinedButton(
                onPressed: loading ? null : onLoadMore,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFC9039), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.766),
                  ),
                ),
                child: Text(
                  loading ? 'A carregar...' : 'Mostrar mais',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFC9039),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
