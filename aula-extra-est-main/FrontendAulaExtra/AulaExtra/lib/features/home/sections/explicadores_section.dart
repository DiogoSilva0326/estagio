import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/tutors/dtos/tutor_browse_item_dto.dart';
import 'package:aula_extra/core/data/tutors/tutors_browse_service.dart';
import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExplicadoresSection extends StatefulWidget {
  const ExplicadoresSection({super.key});

  @override
  State<ExplicadoresSection> createState() => _ExplicadoresSectionState();
}

class _ExplicadoresSectionState extends State<ExplicadoresSection> {
  static const double _cardsSpacing = 79;

  final TutorsBrowseService _tutorsBrowseService = TutorsBrowseService();
  late final Future<List<TutorBrowseItemDto>> _featuredTutorsFuture =
      _loadFeaturedTutors();

  Future<List<TutorBrowseItemDto>> _loadFeaturedTutors() async {
    final result = await _tutorsBrowseService.browse(page: 1, pageSize: 4);
    return result.items.take(4).toList(growable: false);
  }

  static const List<String> _buttonBackgrounds = <String>[
    HomeAssets.buttonBgRed,
    HomeAssets.buttonBgBlue,
    HomeAssets.buttonBgOrange,
    HomeAssets.buttonBgGreen,
  ];

  static const List<Color> _subjectColors = <Color>[
    Color(0xFF8DCAE7),
    Color(0xFFFAA31B),
    Color(0xFF45AB61),
    Color(0xFFF15C64),
  ];

  static const List<Color> _tagBackgrounds = <Color>[
    Color(0xFFE3EFFC),
    Color(0xFFFFEDE3),
    Color(0xFFE3F0E6),
    Color(0xFFFFE5E6),
  ];

  static const List<Color> _tagForegrounds = <Color>[
    Color(0xFF8DCAE7),
    Color(0xFFFAA31B),
    Color(0xFF45AB61),
    Color(0xFFED1C24),
  ];

  String _priceText(TutorBrowseItemDto tutor) {
    if (tutor.minPrice <= 0) return 'Preço sob\nconsulta';
    final formatted = tutor.minPrice == tutor.minPrice.roundToDouble()
        ? tutor.minPrice.round().toString()
        : tutor.minPrice.toStringAsFixed(0);
    return 'A partir de\n€$formatted/hora';
  }

  String _experienceText(TutorBrowseItemDto tutor) {
    final years = tutor.yearsExperience;
    if (years == null || years <= 0) return 'Experiência não indicada';
    return years == 1 ? '1 ano de experiência' : '$years anos de experiência';
  }

  List<String> _levelsFor(TutorBrowseItemDto tutor) {
    final levels = tutor.educationLevels
        .map((level) => level.trim().toUpperCase())
        .where((level) => level.isNotEmpty)
        .toList(growable: false);
    if (levels.isNotEmpty) return levels.take(2).toList(growable: false);
    return tutor.tags
        .map((tag) => tag.trim().toUpperCase())
        .where((tag) => tag.isNotEmpty)
        .take(2)
        .toList(growable: false);
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

  void _openTutorProfile(BuildContext context, TutorBrowseItemDto tutor) {
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
        tags: tutor.educationLevels.isNotEmpty
            ? tutor.educationLevels
            : tutor.tags,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 960,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            right: 0,
            child: SizedBox(
              height: 259,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Conhece os Nossos \n Explicadores Especialistas',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      height: 0.95,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Aprende com profissionais verificados e com anos de \n experiência de ensino',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFAA31B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 61,
            top: 274,
            child: SizedBox(
              width: 1320,
              child: FutureBuilder<List<TutorBrowseItemDto>>(
                future: _featuredTutorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 535,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 535,
                      child: Center(
                        child: Text(
                          'Não foi possível carregar os explicadores.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ),
                    );
                  }

                  final tutors = snapshot.data ?? const <TutorBrowseItemDto>[];
                  if (tutors.isEmpty) {
                    return const SizedBox(
                      height: 535,
                      child: Center(
                        child: Text(
                          'Ainda não existem explicadores disponíveis.',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ),
                    );
                  }

                  return Wrap(
                    spacing: _cardsSpacing,
                    runSpacing: 29,
                    children: [
                      for (var index = 0; index < tutors.length; index++)
                        _TeacherCardLarge(
                          photoUrl: _resolvedPhotoUrl(tutors[index].photo),
                          name: tutors[index].name.toUpperCase(),
                          subject:
                              (tutors[index].primarySubject.trim().isNotEmpty
                              ? tutors[index].primarySubject
                              : (tutors[index].tags.isNotEmpty
                                    ? tutors[index].tags.first
                                    : 'Explicador')),
                          subjectColor:
                              _subjectColors[index % _subjectColors.length],
                          location: tutors[index].subtitle.isNotEmpty
                              ? tutors[index].subtitle
                              : 'Online',
                          experience: _experienceText(tutors[index]),
                          price: _priceText(tutors[index]),
                          buttonBg:
                              _buttonBackgrounds[index %
                                  _buttonBackgrounds.length],
                          tags: _levelsFor(tutors[index])
                              .asMap()
                              .entries
                              .map(
                                (entry) => _Tag(
                                  text: entry.value,
                                  bg:
                                      _tagBackgrounds[(index + entry.key) %
                                          _tagBackgrounds.length],
                                  fg:
                                      _tagForegrounds[(index + entry.key) %
                                          _tagForegrounds.length],
                                ),
                              )
                              .toList(growable: false),
                          onPrimaryAction: () =>
                              _openTutorProfile(context, tutors[index]),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
          Positioned(
            left: 608,
            top: 841,
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF15C64),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.explicadores),
                child: const Text(
                  'Ver Todos os Explicadores',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeacherCardLarge extends StatelessWidget {
  const _TeacherCardLarge({
    this.photoUrl,
    required this.name,
    required this.subject,
    required this.subjectColor,
    required this.location,
    required this.experience,
    required this.price,
    required this.buttonBg,
    required this.tags,
    required this.onPrimaryAction,
  });

  final String? photoUrl;
  final String name;
  final String subject;
  final Color subjectColor;
  final String location;
  final String experience;
  final String price;
  final String buttonBg;
  final List<_Tag> tags;
  final VoidCallback onPrimaryAction;

  static const _cardWidth = 270.0;
  static const _cardHeight = 535.0;
  static const _imageHeight = 259.0;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);

    if (parts.isEmpty) return 'P';
    if (parts.length == 1) {
      final first = parts.first;
      return first.length >= 2 ? first.substring(0, 2) : first.substring(0, 1);
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}';
  }

  Widget _buildInitialsAvatar() {
    return Container(
      width: _cardWidth,
      height: _imageHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFC9039), Color(0xFFF15C64)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: const TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _cardWidth,
      height: _cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: photoUrl?.trim().isNotEmpty == true
                ? Image.network(
                    photoUrl!.trim(),
                    width: _cardWidth,
                    height: _imageHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildInitialsAvatar(),
                  )
                : _buildInitialsAvatar(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: subjectColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TeacherInfoRow(
                    iconAsset: HomeAssets.iconMapPin,
                    text: location,
                  ),
                  const SizedBox(height: 6),
                  _TeacherInfoRow(
                    iconAsset: HomeAssets.iconAward,
                    text: experience,
                  ),
                  const SizedBox(height: 12),
                  Row(children: tags),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          price,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF696969),
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 107,
                        height: 44,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: onPrimaryAction,
                          child: Stack(
                            children: [
                              SvgPicture.asset(
                                buttonBg,
                                width: 107,
                                height: 44,
                                fit: BoxFit.fill,
                              ),
                              const Center(
                                child: Text(
                                  'Marcar\nAgora',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _TeacherInfoRow extends StatelessWidget {
  const _TeacherInfoRow({required this.iconAsset, required this.text});

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Row(
        children: [
          SvgPicture.asset(iconAsset, width: 18, height: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0x80000000),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
