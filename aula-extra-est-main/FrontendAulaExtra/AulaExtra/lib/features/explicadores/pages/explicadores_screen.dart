import 'package:aula_extra/core/components/footer/sections/footer_section.dart';
import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/core/components/header/variants/header_aluno.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/education/dtos/ciclo_estudo_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/tutors/dtos/tutor_browse_item_dto.dart';
import 'package:aula_extra/core/data/tutors/tutors_browse_service.dart';
import 'package:aula_extra/core/widgets/pinned_header_delegate.dart';
import 'package:aula_extra/features/explicadores/sections/explicadores_hero_section.dart';
import 'package:aula_extra/features/explicadores/sections/filters_sidebar_section.dart';
import 'package:aula_extra/features/explicadores/sections/main_content_header_section.dart';
import 'package:aula_extra/features/explicadores/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/explicadores/widgets/tutor_card.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

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
                height: AppHeader.height,
                child: AppHeader(
                  headerAlunoActiveItem: HeaderAlunoItem.maisExplicadores,
                  onRegisterTap: () => Navigator.of(context).pushNamed(Routes.registerStudent),
                  onLoginTap: () => Navigator.of(context).pushNamed(Routes.login),
                  onLogoTap: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(Routes.home, (route) => false),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
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
                      child: FullBleedScaledSection(child: ExplicadoresHeroSection()),
                    ),
                  ),
                  const ColoredBox(
                    color: Color(0xFFF9F9F9),
                    child: SizedBox(
                      width: double.infinity,
                      child: FullBleedScaledSection(
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
  double _maxPrice = 80;
  double? _minRating;

  @override
  void initState() {
    super.initState();
    _loadLookups();
    _fetch(page: 1, append: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLookups() async {
    try {
      final ciclos = await _educationService.getCiclosEstudo();
      final disciplinas = await _educationService.getCatalog();
      if (!mounted) return;
      setState(() {
        _ciclos = ciclos;
        _disciplinas = disciplinas;
      });
    } catch (_) {
      // Ignore lookup failures; tutors list still works (browse endpoint is public).
    }
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
        maxPrice: _maxPrice >= 80 ? null : _maxPrice,
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
      _maxPrice = 80;
      _minRating = null;
      _searchController.clear();
    });
    _fetch(page: 1, append: false);
  }

  void _applyFilters() {
    _fetch(page: 1, append: false);
  }

  void _loadMore() {
    final hasMore = _items.length < _total;
    if (!hasMore) return;
    _fetch(page: _page + 1, append: true);
  }

  @override
  Widget build(BuildContext context) {
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

    final specializationOptions = _disciplinas
        .where((d) => d.idDisciplina.trim().isNotEmpty)
        .take(10)
        .map((d) => FilterOption(id: d.idDisciplina, label: d.nome))
        .toList(growable: false);

    final hasMore = _items.length < _total;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FiltersSidebarSection(
          maxPrice: _maxPrice,
          onMaxPriceChanged: (v) => setState(() => _maxPrice = v),
          levelOptions: levelOptions,
          selectedLevelId: _selectedCicloId,
          onLevelChanged: (id) => setState(() => _selectedCicloId = id),
          availability: _availability,
          onAvailabilityChanged: (v) => setState(() => _availability = v),
          specializationOptions: specializationOptions,
          selectedSpecializationId: _selectedDisciplinaId,
          onSpecializationChanged: (id) => setState(() => _selectedDisciplinaId = id),
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
  });

  final List<TutorBrowseItemDto> items;
  final bool loading;
  final String? error;
  final bool hasMore;
  final VoidCallback onLoadMore;

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
        Wrap(
          spacing: 30,
          runSpacing: 30,
          children: [
            for (final tutor in items)
              TutorCard(
                name: tutor.name,
                country: tutor.subtitle.isNotEmpty ? tutor.subtitle : 'Online',
                rating: tutor.rating,
                reviewCount: tutor.reviewCount,
                description: tutor.description,
                lessonsText: '${tutor.lessonsCount} aulas',
                pricePerHour: tutor.minPrice.round(),
                tags: tutor.tags,
                onViewProfileTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.tutorProfile,
                    arguments: TutorProfileArgs(
                      professorId: tutor.idProfessor,
                      name: tutor.name,
                      country: tutor.subtitle.isNotEmpty ? tutor.subtitle : 'Online',
                      rating: tutor.rating,
                      reviewCount: tutor.reviewCount,
                      description: tutor.description,
                      lessonsText: '${tutor.lessonsCount} aulas',
                      pricePerHour: tutor.minPrice.round(),
                      tags: tutor.tags,
                    ),
                  );
                },
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
