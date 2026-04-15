import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:aula_extra/core/navigation/become_teacher_navigation.dart';
import 'package:aula_extra/features/explicadores/pages/explicadores_screen.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 780,
      width: double.infinity,
      child: Stack(
        children: const [
          Positioned(left: 30, top: 73, child: _HeroLeft()),
          Positioned(left: 657, top: 86, child: _HeroRight()),
        ],
      ),
    );
  }
}

class _HeroLeft extends StatefulWidget {
  const _HeroLeft();

  @override
  State<_HeroLeft> createState() => _HeroLeftState();
}

class _HeroLeftState extends State<_HeroLeft> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    Navigator.of(context).pushNamed(
      Routes.explicadores,
      arguments: ExplicadoresScreenArgs(initialQuery: query),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 598,
      height: 590,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: 549,
              child: Text(
                'Encontra o melhor apoio para ti.',
                style: TextStyle(fontSize: 64, height: 0.9375, fontWeight: FontWeight.w500, color: Colors.black),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            top: 160,
            child: SizedBox(
              width: 524,
              child: Text(
                'Conecta-te com explicadores especialistas para aulas\nonline personalizadas. Domina qualquer disciplina ao\nteu proprio ritmo com orientação individual.',
                style: TextStyle(fontSize: 20, height: 1.2, fontWeight: FontWeight.w500, color: Color(0xFFFAA31B)),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 412,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SearchBar(
                  controller: _searchController,
                  onSubmitted: (_) => _submitSearch(),
                ),
                const SizedBox(width: 22),
                SizedBox(
                  width: 208,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF15C64),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _submitSearch,
                    child: const Text('Encontrar Explicador', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 0,
            top: 516,
            child: _HeroStats(),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 298,
      height: 55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFDFEFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE6E9EA)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Image.asset(HomeAssets.searchIcon, width: 14, height: 15, fit: BoxFit.contain),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: onSubmitted,
                  decoration: const InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: 'Procurar disciplinas...',
                    hintStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFFBCBDBB)),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0A0A0A),
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

class _HeroStats extends StatelessWidget {
  const _HeroStats();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 598,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _StatItem(value: '5.000+', label: 'Explicadores Especialistas', color: Color(0xFF3B94EF)),
          _StatItem(value: '50.000+', label: 'Alunos Satisfeitos', color: Color(0xFFFC9039)),
          _StatItem(value: '100+', label: 'Disciplinas', color: Color(0xFF45AB61)),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, color: color)),
          const SizedBox(height: 6),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Color(0xFF939AA4))),
        ],
      ),
    );
  }
}

class _HeroRight extends StatelessWidget {
  const _HeroRight();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 724,
      height: 556,
      child: Stack(
        children: const [
          Positioned(
            left: 4,
            top: 0,
            child: _TeacherCardSmall(
              width: 238,
              height: 363,
              imageAsset: HomeAssets.teacherFrame7,
              name: 'JOÃO',
              subject: 'Matemática',
              labelTop: 257,
              starLeft: 93,
              starTop: 234,
            ),
          ),
          Positioned(left: 259, top: 0, child: _VerifiedCard()),
          Positioned(
            left: 499,
            top: 0,
            child: _TeacherCardSmall(
              width: 225,
              height: 225,
              imageAsset: HomeAssets.teacherFrame8,
              name: 'ANDRÉ',
              subject: 'Física',
              labelTop: 131,
              starLeft: 90,
              starTop: 108,
            ),
          ),
          Positioned(left: 4, top: 379, child: _BlueLearningCard()),
          Positioned(
            left: 258,
            top: 284,
            child: _TeacherCardSmall(
              width: 226,
              height: 272,
              imageAsset: HomeAssets.teacherFrame12,
              name: 'ANDREIA',
              subject: 'Inglês',
              labelTop: 190,
              starLeft: 93,
              starTop: 167,
            ),
          ),
          Positioned(left: 499, top: 241, child: _FlexibleHoursCard()),
        ],
      ),
    );
  }
}

class _TeacherCardSmall extends StatelessWidget {
  const _TeacherCardSmall({
    required this.width,
    required this.height,
    required this.imageAsset,
    required this.name,
    required this.subject,
    required this.labelTop,
    required this.starLeft,
    required this.starTop,
  });

  final double width;
  final double height;
  final String imageAsset;
  final String name;
  final String subject;
  final double labelTop;
  final double starLeft;
  final double starTop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(imageAsset, width: width, height: height, fit: BoxFit.cover),
          ),
          Positioned(
            left: 0,
            top: labelTop,
            child: Container(
              width: 122,
              height: 47,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
              ),
              padding: const EdgeInsets.only(left: 14, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, height: 1, fontWeight: FontWeight.w500, color: Colors.black),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, height: 1, fontWeight: FontWeight.w400, color: Color(0x80000000)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: starLeft,
            top: starTop,
            child: _StarToggle(),
          ),
        ],
      ),
    );
  }
}

class _StarToggle extends StatelessWidget {
  const _StarToggle();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: Color(0xFFF15C64), shape: BoxShape.circle),
          child: Center(
            child: SvgPicture.asset(
              HomeAssets.star,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _VerifiedCard extends StatelessWidget {
  const _VerifiedCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 225,
      height: 270,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0x8FFB7B02),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            const Positioned(
              left: 14,
              top: 24,
              child: SizedBox(
                width: 194,
                child: Text(
                  'EXPLICADORES VERIFICADOS',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
            const Positioned(
              left: 14,
              top: 92,
              child: SizedBox(
                width: 196,
                child: Text(
                  'Todos os explicadores são verificados e especialistas nas suas disciplinas.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 210,
              child: SizedBox(
                width: 225,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC9039),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => navigateToBecomeTeacherFlow(context),
                  child: const Text('Tornar-me um Explicador', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlueLearningCard extends StatelessWidget {
  const _BlueLearningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 177,
      decoration: BoxDecoration(color: const Color(0x9965A7D7), borderRadius: BorderRadius.circular(20)),
      child: const Padding(
        padding: EdgeInsets.only(left: 15, top: 24, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'APRENDIZAGEM\nPERSONALIZADA',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white, height: 1.1),
            ),
            SizedBox(height: 14),
            Text(
              'Sessões individuais adaptadas ao teu estilo de aprendizagem e objetivos.',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlexibleHoursCard extends StatelessWidget {
  const _FlexibleHoursCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 225,
      height: 315,
      child: DecoratedBox(
        decoration: BoxDecoration(color: const Color(0xC7F15C64), borderRadius: BorderRadius.circular(20)),
        child: Stack(
          children: [
            const Positioned(
              left: 15,
              top: 28,
              child: SizedBox(
                width: 196,
                child: Text('HORÁRIOS FLEXÍVEIS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
            const Positioned(
              left: 15,
              top: 90,
              child: SizedBox(
                width: 186,
                child: Text(
                  'Aprende ao teu próprio ritmo e marca sessões que se ajustam à tua agenda.',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 255,
              child: SizedBox(
                width: 225,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF15C64),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () => Navigator.of(context).pushNamed(Routes.explicadores),
                  child: const Text('Marcar uma Sessão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
