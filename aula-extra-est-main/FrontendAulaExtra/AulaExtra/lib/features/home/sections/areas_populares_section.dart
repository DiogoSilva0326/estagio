import 'package:aula_extra/features/home/assets/home_assets.dart';
import 'package:flutter/material.dart';

class AreasPopularesSection extends StatelessWidget {
  const AreasPopularesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 855,
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text('Áreas Populares', style: TextStyle(fontSize: 64, fontWeight: FontWeight.w500, color: Colors.black)),
          const SizedBox(height: 10),
          const Text(
            'Escolhe entre uma vasta gama de áreas lecionadas\npor explicadores especialistas',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, height: 1.2, fontWeight: FontWeight.w500, color: Color(0xFFFAA31B)),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: 1319,
            child: Wrap(
              spacing: 33,
              runSpacing: 29,
              children: const [
                _AreaCard(width: 298, title: 'MATEMÁTICA', subtitle: '201 explicadores', iconAsset: HomeAssets.areaMatematica),
                _AreaCard(width: 300, title: 'CIÊNCIAS', subtitle: '98 explicadores', iconAsset: HomeAssets.areaCiencias),
                _AreaCard(width: 299, title: 'LÍNGUAS', subtitle: '506 explicadores', iconAsset: HomeAssets.areaLinguas),
                _AreaCard(width: 295, title: 'LITERATURA', subtitle: '88 explicadores', iconAsset: HomeAssets.areaLiteratura),
                _AreaCard(width: 298, title: 'PROGRAMAÇÃO', subtitle: '304 explicadores', iconAsset: HomeAssets.areaProgramacao),
                _AreaCard(width: 300, title: 'GEOGRAFIA', subtitle: '105 explicadores', iconAsset: HomeAssets.areaGeografia),
                _AreaCard(width: 299, title: 'MÚSICA', subtitle: '45 explicadores', iconAsset: HomeAssets.areaMusica),
                _AreaCard(width: 295, title: 'ARTES', subtitle: '67 explicadores', iconAsset: HomeAssets.areaArtes),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF15C64),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 30),
              ),
              onPressed: () {},
              child: const Text('Ver Todas as Áreas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
}

class _AreaCard extends StatelessWidget {
  const _AreaCard({required this.width, required this.title, required this.subtitle, required this.iconAsset});

  final double width;
  final String title;
  final String subtitle;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 4, spreadRadius: 2)],
      ),
      child: Stack(
        children: [
          Positioned(left: 34, top: 121, child: _AreaText(title: title, subtitle: subtitle)),
          Positioned(left: 34, top: 32, child: Image.asset(iconAsset, width: 64, height: 63)),
        ],
      ),
    );
  }
}

class _AreaText extends StatelessWidget {
  const _AreaText({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 224,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Color(0x80000000)),
          ),
        ],
      ),
    );
  }
}
