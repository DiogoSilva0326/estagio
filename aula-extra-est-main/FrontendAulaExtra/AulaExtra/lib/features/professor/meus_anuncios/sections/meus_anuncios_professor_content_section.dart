import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ads_form_data_dto.dart';
import 'package:aula_extra/core/data/professor_ads/professor_ads_api.dart';
import 'package:aula_extra/core/data/professor_ads/professor_ads_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 
import 'package:aula_extra/core/widgets/app_confirmation_dialog.dart';
import 'package:aula_extra/features/home/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/meus_anuncios/constants/meus_anuncios_professor_constants.dart';
import 'package:aula_extra/features/professor/meus_anuncios/widgets/meus_anuncios_ad_card.dart';
import 'package:aula_extra/features/professor/meus_anuncios/widgets/meus_anuncios_shared_widgets.dart';
import 'package:aula_extra/features/professor/meus_anuncios/widgets/meus_anuncios_stat_card.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/models/publicar_anuncio_professor_args.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum _AdsFilter { active, inactive }

class MeusAnunciosProfessorContentSection extends StatefulWidget {
  const MeusAnunciosProfessorContentSection({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  State<MeusAnunciosProfessorContentSection> createState() =>
      _MeusAnunciosProfessorContentSectionState();
}

class _MeusAnunciosProfessorContentSectionState
    extends State<MeusAnunciosProfessorContentSection> {
  final ProfessorAdsService _adsService = ProfessorAdsService();
  final EducationService _educationService = EducationService();

  bool _loading = true;
  String? _error;
  List<ProfessorAdDto> _ads = const <ProfessorAdDto>[];
  final Set<String> _statusLoadingIds = <String>{};
  _AdsFilter _selectedFilter = _AdsFilter.active;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentTargetRole = userProvider.role == Role.psychologist ? 'psicologia' 
                              : userProvider.role == Role.tutor ? 'tutoria' 
                              : 'ensino';

      final results = await Future.wait([
        _adsService.getMyData(),
        _educationService.getAreas(targetRole: currentTargetRole),
      ]);

      final data = results[0] as ProfessorAdsFormDataDto;
      final allowedAreas = results[1] as List<AreaDto>;
      
      final allowedAreaIds = allowedAreas.map((a) => a.idArea).toSet();

      final roleFilteredAds = data.ads.where((ad) {
        final disciplina = data.disciplinas.cast<DisciplinaDto?>().firstWhere(
          (d) => d?.idDisciplina == ad.idDisciplina,
          orElse: () => null,
        );
        if (disciplina == null) return false;
        
        return allowedAreaIds.contains(disciplina.idArea);
      }).toList(growable: false);

      if (!mounted) return;
      setState(() {
        _ads = roleFilteredAds;
        _loading = false;
      });
    } on ProfessorAdsException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _openEditor(ProfessorAdDto ad) async {
    await Navigator.of(context).pushNamed(
      Routes.professorPublicarAnuncio,
      arguments: PublicarAnuncioProfessorArgs(ad: ad),
    );
    if (!mounted) return;
    await _load();
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).pushNamed(Routes.professorPublicarAnuncio);
    if (!mounted) return;
    await _load();
  }

  void _openPublicProfile(ProfessorAdDto ad, String displayName, TeachingRoleConfig config) {
    Navigator.of(context).pushNamed(
      Routes.tutorProfile,
      arguments: TutorProfileArgs(
        professorId: ad.idProfessor,
        name: displayName,
        country: 'Online',
        rating: 0,
        reviewCount: 0,
        description: ad.description?.trim().isNotEmpty == true
            ? ad.description!.trim()
            : config.publicarAnuncio.defaultProfileDescription,
        lessonsText: config.publicarAnuncio.profileBadgeText,
        pricePerHour: (ad.sessionPrice ?? 0).round(),
        tags: [
          if ((ad.disciplinaNome ?? '').trim().isNotEmpty)
            ad.disciplinaNome!.trim(),
          if ((ad.tutoringTypeName ?? '').trim().isNotEmpty)
            ad.tutoringTypeName!.trim(),
        ],
      ),
    );
  }

  Future<void> _toggleAdStatus(ProfessorAdDto ad) async {
    final currentStatus = ad.status.trim().toLowerCase();
    final nextStatus = currentStatus == 'inactive' ? 'published' : 'inactive';

    setState(() {
      _statusLoadingIds.add(ad.idProfessorAd);
    });

    try {
      final updated = await _adsService.updateMyAdStatus(
        idProfessorAd: ad.idProfessorAd,
        status: nextStatus,
      );

      if (!mounted) return;
      setState(() {
        _ads = _ads
            .map(
              (item) =>
                  item.idProfessorAd == updated.idProfessorAd ? updated : item,
            )
            .toList(growable: false);
        _statusLoadingIds.remove(ad.idProfessorAd);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextStatus == 'inactive'
                ? 'Anúncio marcado como inativo.'
                : 'Anúncio reativado com sucesso.',
          ),
        ),
      );
    } on ProfessorAdsException catch (error) {
      if (!mounted) return;
      setState(() {
        _statusLoadingIds.remove(ad.idProfessorAd);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statusLoadingIds.remove(ad.idProfessorAd);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _handleStatusAction(ProfessorAdDto ad) async {
    final isInactive = ad.status.trim().toLowerCase() == 'inactive';
    if (isInactive) {
      await _toggleAdStatus(ad);
      return;
    }

    final confirmed = await showAppConfirmationDialog(
      context,
      title: 'Colocar anúncio inativo?',
      content: const Text(
        'Tem a certeza que quer realmente colocar inativo o anúncio?',
      ),
      confirmLabel: 'Colocar inativo',
      cancelLabel: 'Cancelar',
      icon: Icons.visibility_off_rounded,
      confirmGradient: const [Color(0xFFF15C64), Color(0xFFFC9039)],
    );

    if (confirmed == true && mounted) {
      await _toggleAdStatus(ad);
    }
  }

  List<ProfessorAdDto> get _filteredAds {
    final showInactive = _selectedFilter == _AdsFilter.inactive;
    return _ads
        .where((ad) {
          final isInactive = ad.status.trim().toLowerCase() == 'inactive';
          return showInactive ? isInactive : !isInactive;
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final account = userProvider.account;
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    final displayName = (account?.fullName?.trim().isNotEmpty ?? false)
        ? account!.fullName!.trim()
        : (account?.username?.trim().isNotEmpty ?? false)
        ? account!.username!.trim()
        : config.roleName;
    final filteredAds = _filteredAds;

    if (widget.isMobile) {
      return _buildMobileContent(displayName, filteredAds, config);
    }

    return Container(
      color: MeusAnunciosProfessorColors.pageBackground,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(42, 42, 42, 56),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showSidebar = constraints.maxWidth >= 1180;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSidebar) ...[
                    const ProfessorMenuNav(selectedIndex: 6),
                    const SizedBox(width: 28),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Os meus anúncios',
                                    style: TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w700,
                                      color: MeusAnunciosProfessorColors.title,
                                      height: 1.1,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Consulte os anúncios publicados, controle quais estão ativos e ajuste rapidamente o que aparece aos utilizadores.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          MeusAnunciosProfessorColors.mutedText,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),
                            _NewAdButton(onPressed: _openCreate, config: config),
                          ],
                        ),
                        const SizedBox(height: 28),
                        if (!showSidebar)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: ProfessorMenuNav(selectedIndex: 6),
                          ),
                        if (_loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_error != null)
                          MeusAnunciosPanelCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Não foi possível carregar os anúncios.',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: MeusAnunciosProfessorColors.title,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    color:
                                        MeusAnunciosProfessorColors.mutedText,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                OutlinedButton(
                                  onPressed: _load,
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          _buildStatsRow(config),
                          const SizedBox(height: 24),
                          _buildFilterRow(config),
                          const SizedBox(height: 24),
                          if (_ads.isEmpty)
                            MeusAnunciosPanelCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ainda não tem anúncios publicados.',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: MeusAnunciosProfessorColors.title,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Crie o seu primeiro anúncio para começar a ser descoberto.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          MeusAnunciosProfessorColors.mutedText,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  FilledButton.icon(
                                    onPressed: _openCreate,
                                    icon: const Icon(Icons.campaign_rounded),
                                    label: const Text('Publicar anúncio'),
                                    style: FilledButton.styleFrom(
                                        backgroundColor: config.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (filteredAds.isEmpty)
                            MeusAnunciosPanelCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedFilter == _AdsFilter.active
                                        ? 'Não tem anúncios ativos neste momento.'
                                        : 'Não tem anúncios inativos neste momento.',
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      color: MeusAnunciosProfessorColors.title,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _selectedFilter == _AdsFilter.active
                                        ? 'Pode criar um novo anúncio ou reativar um anúncio inativo.'
                                        : 'Quando desativar anúncios, eles aparecem aqui para poder reativá-los mais tarde.',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color:
                                          MeusAnunciosProfessorColors.mutedText,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            LayoutBuilder(
                              builder: (context, adConstraints) {
                                final useTwoColumns =
                                    adConstraints.maxWidth >= 760;
                                final cardWidth = useTwoColumns
                                    ? (adConstraints.maxWidth - 24) / 2
                                    : adConstraints.maxWidth;

                                return Wrap(
                                  spacing: 24,
                                  runSpacing: 24,
                                  children: filteredAds
                                      .map(
                                        (ad) => SizedBox(
                                          width: cardWidth,
                                          child: MeusAnunciosAdCard(
                                            ad: ad,
                                            displayName: displayName,
                                            onEdit: () => _openEditor(ad),
                                            onToggleStatus: () =>
                                                _handleStatusAction(ad),
                                            onViewProfile: () =>
                                                _openPublicProfile(
                                                  ad,
                                                  displayName,
                                                  config
                                                ),
                                            processingStatus: _statusLoadingIds
                                                .contains(ad.idProfessorAd),
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                );
                              },
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContent(
    String displayName,
    List<ProfessorAdDto> filteredAds,
    TeachingRoleConfig config,
  ) {
    return Container(
      width: double.infinity,
      color: MeusAnunciosProfessorColors.pageBackground,
      padding: const EdgeInsets.fromLTRB(
        MeusAnunciosProfessorLayout.mobileHorizontalPadding,
        MeusAnunciosProfessorLayout.mobileTopPadding,
        MeusAnunciosProfessorLayout.mobileHorizontalPadding,
        MeusAnunciosProfessorLayout.mobileBottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Os meus anúncios',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: MeusAnunciosProfessorColors.title,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Consulte os anúncios publicados, veja o estado de cada um e faça alterações rapidamente no telemóvel.',
            style: TextStyle(
              fontSize: 14,
              color: MeusAnunciosProfessorColors.mutedText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: _NewAdButton(onPressed: _openCreate, config: config),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            MeusAnunciosPanelCard(
              padding: const EdgeInsets.all(
                MeusAnunciosProfessorLayout.mobileCardPadding,
              ),
              radius: MeusAnunciosProfessorLayout.mobileCardRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Não foi possível carregar os anúncios.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: MeusAnunciosProfessorColors.title,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: MeusAnunciosProfessorColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _load,
                      child: const Text('Tentar novamente'),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            _buildStatsRow(config),
            const SizedBox(height: 16),
            _buildMobileFilterRow(config),
            const SizedBox(height: 16),
            if (_ads.isEmpty)
              MeusAnunciosPanelCard(
                padding: const EdgeInsets.all(
                  MeusAnunciosProfessorLayout.mobileCardPadding,
                ),
                radius: MeusAnunciosProfessorLayout.mobileCardRadius,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ainda não tem anúncios publicados.',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: MeusAnunciosProfessorColors.title,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Crie o seu primeiro anúncio para começar a ser descoberto.',
                      style: TextStyle(
                        fontSize: 14,
                        color: MeusAnunciosProfessorColors.mutedText,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _openCreate,
                        icon: const Icon(Icons.campaign_rounded),
                        label: const Text('Publicar anúncio'),
                        style: FilledButton.styleFrom(
                            backgroundColor: config.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (filteredAds.isEmpty)
              MeusAnunciosPanelCard(
                padding: const EdgeInsets.all(
                  MeusAnunciosProfessorLayout.mobileCardPadding,
                ),
                radius: MeusAnunciosProfessorLayout.mobileCardRadius,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedFilter == _AdsFilter.active
                          ? 'Não tem anúncios ativos neste momento.'
                          : 'Não tem anúncios inativos neste momento.',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: MeusAnunciosProfessorColors.title,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedFilter == _AdsFilter.active
                          ? 'Pode criar um novo anúncio ou reativar um anúncio inativo.'
                          : 'Quando desativar anúncios, eles aparecem aqui para poder reativá-los mais tarde.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: MeusAnunciosProfessorColors.mutedText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (var index = 0; index < filteredAds.length; index++) ...[
                    MeusAnunciosAdCard(
                      ad: filteredAds[index],
                      displayName: displayName,
                      isMobile: true,
                      onEdit: () => _openEditor(filteredAds[index]),
                      onToggleStatus: () =>
                          _handleStatusAction(filteredAds[index]),
                      onViewProfile: () =>
                          _openPublicProfile(filteredAds[index], displayName, config),
                      processingStatus: _statusLoadingIds.contains(
                        filteredAds[index].idProfessorAd,
                      ),
                    ),
                    if (index != filteredAds.length - 1)
                      const SizedBox(height: 16),
                  ],
                ],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow(TeachingRoleConfig config) {
    final published = _ads.where((ad) => ad.status == 'published').length;
    final inactive = _ads
        .where((ad) => ad.status.trim().toLowerCase() == 'inactive')
        .length;
    final disciplines = _ads
        .map((ad) => ad.idDisciplina)
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .length;

    final isSpecialized = config.roleName != 'Explicador';
    final areasLabel = isSpecialized ? 'Áreas anunciadas' : 'Disciplinas anunciadas';

    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = [
          MeusAnunciosStatCard(
            label: 'Anúncios ativos',
            value: '$published',
            icon: Icons.campaign_rounded,
            color: config.primaryColor,
          ),
          MeusAnunciosStatCard(
            label: 'Anúncios inativos',
            value: '$inactive',
            icon: Icons.pause_circle_outline_rounded,
            color: config.primaryColor,
          ),
          MeusAnunciosStatCard(
            label: areasLabel,
            value: '$disciplines',
            icon: Icons.menu_book_rounded,
            color: config.primaryColor,
          ),
        ];

        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              for (var index = 0; index < cards.length; index++) ...[
                cards[index],
                if (index != cards.length - 1) const SizedBox(height: 16),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              Expanded(child: cards[index]),
              if (index != cards.length - 1) const SizedBox(width: 18),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFilterRow(TeachingRoleConfig config) {
    final activeCount = _ads
        .where((ad) => ad.status.trim().toLowerCase() != 'inactive')
        .length;
    final inactiveCount = _ads
        .where((ad) => ad.status.trim().toLowerCase() == 'inactive')
        .length;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _FilterChipButton(
          label: 'Ativos',
          count: activeCount,
          selected: _selectedFilter == _AdsFilter.active,
          color: config.primaryColor,
          expand: false,
          onTap: () {
            setState(() {
              _selectedFilter = _AdsFilter.active;
            });
          },
        ),
        _FilterChipButton(
          label: 'Inativos',
          count: inactiveCount,
          selected: _selectedFilter == _AdsFilter.inactive,
          color: config.primaryColor,
          expand: false,
          onTap: () {
            setState(() {
              _selectedFilter = _AdsFilter.inactive;
            });
          },
        ),
      ],
    );
  }

  Widget _buildMobileFilterRow(TeachingRoleConfig config) {
    final activeCount = _ads
        .where((ad) => ad.status.trim().toLowerCase() != 'inactive')
        .length;
    final inactiveCount = _ads
        .where((ad) => ad.status.trim().toLowerCase() == 'inactive')
        .length;

    return Row(
      children: [
        Expanded(
          child: _FilterChipButton(
            label: 'Ativos',
            count: activeCount,
            selected: _selectedFilter == _AdsFilter.active,
            color: config.primaryColor,
            expand: true,
            onTap: () {
              setState(() {
                _selectedFilter = _AdsFilter.active;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _FilterChipButton(
            label: 'Inativos',
            count: inactiveCount,
            selected: _selectedFilter == _AdsFilter.inactive,
            color: config.primaryColor,
            expand: true,
            onTap: () {
              setState(() {
                _selectedFilter = _AdsFilter.inactive;
              });
            },
          ),
        ),
      ],
    );
  }
}

class _NewAdButton extends StatelessWidget {
  const _NewAdButton({required this.onPressed, required this.config});

  final VoidCallback onPressed;
  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    final isOrange = config.roleName == 'Explicador';
    final color = config.primaryColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isOrange ? null : color,
        gradient: isOrange
            ? const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFFB923C)],
              )
            : null,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Novo anúncio'),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
    required this.label,
    required this.count,
    required this.selected,
    required this.color,
    this.expand = false,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final Color color;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: expand ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          horizontal: expand ? 14 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : MeusAnunciosProfessorColors.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: expand
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: selected ? color : MeusAnunciosProfessorColors.title,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: selected
                    ? color.withOpacity(0.15)
                    : MeusAnunciosProfessorColors.mutedSurface,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? color
                      : MeusAnunciosProfessorColors.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}