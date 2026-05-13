import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/plano_item.dart';

class PlanoCard extends StatelessWidget {
  const PlanoCard({required this.item, required this.onEdit, super.key});

  final PlanoItem item;
  final VoidCallback onEdit;

  static const String _fontFamily = 'Helvetica Neue';

  bool get _isCustomPlan => item.name == 'Pack Personalizado';
  String get _creditsValue => item.priceLabel.replaceAll('€', '').trim();
  String get _actionLabel => _isCustomPlan ? 'Comprar agora' : 'Editar';
  List<String> get _descriptionLines => item.description
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 373.313,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DashboardSurfaceCard(
            padding: const EdgeInsets.fromLTRB(13.62, 34.06, 13.62, 25.89),
            borderRadius: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 71.529,
                      height: 71.529,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFFFC9039),
                          width: 2.72,
                        ),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(10.22),
                      child: SvgPicture.asset(
                        'assets/icons/plans_custom_icon.svg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 13.62),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 9.54),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                color: Color(0xFF1D2838),
                                fontSize: 19.88,
                                fontFamily: _fontFamily,
                                fontWeight: FontWeight.w700,
                                height: 1.20,
                                letterSpacing: 0.26,
                              ),
                            ),
                            if (item.subtitle.trim().isNotEmpty) ...[
                              const SizedBox(height: 2.72),
                              Text(
                                item.subtitle,
                                style: const TextStyle(
                                  color: Color(0xFF354152),
                                  fontSize: 16.34,
                                  fontFamily: _fontFamily,
                                  fontWeight: FontWeight.w400,
                                  height: 1.43,
                                  letterSpacing: -0.18,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.44),
                Row(
                  children: [
                    Text(
                      _creditsValue,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFC9039),
                        fontSize: 20.94,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w700,
                        height: 1.20,
                        letterSpacing: 0.28,
                      ),
                    ),
                    const Text(
                      ' €',
                      style: TextStyle(
                        color: Color(0xFFFC9039),
                        fontSize: 20.94,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w700,
                        height: 1.20,
                        letterSpacing: 0.28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.17),
                Stack(
                  children: [
                    Container(
                      height: 4.77,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFA3A3A3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Container(
                      height: 4.77,
                      width: _isCustomPlan ? 28.61 : 56.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFC5C5C),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 19.76),
                if (_isCustomPlan)
                  Row(
                    children: [
                      const Text(
                        'Pack Personalizado:',
                        style: TextStyle(
                          color: Color(0xFF1D2838),
                          fontSize: 12.40,
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.w700,
                          height: 1.20,
                          letterSpacing: 0.16,
                        ),
                      ),
                      const SizedBox(width: 7.49),
                      _PriceInputBox(creditsValue: _creditsValue),
                    ],
                  )
                else
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final line in _descriptionLines)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2.2),
                            child: Text(
                              line,
                              style: const TextStyle(
                                color: Color(0xFF354152),
                                fontSize: 11.2,
                                fontFamily: _fontFamily,
                                fontWeight: FontWeight.w400,
                                height: 1.43,
                                letterSpacing: -0.14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                const Spacer(),
                const Divider(height: 1, color: Color(0xFFD1D5DC)),
                const SizedBox(height: 16.34),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.priceLabel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFC9039),
                          fontSize: 34.21,
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.w700,
                          height: 1.20,
                          letterSpacing: 0.45,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.22),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF15C64), Color(0xFFFC9039)],
                        ),
                        borderRadius: BorderRadius.circular(6.81),
                      ),
                      child: SizedBox(
                        height: 36.786,
                        child: ElevatedButton(
                          onPressed: onEdit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.81),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 11.58,
                            ),
                          ),
                          child: Text(
                            _actionLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.91,
                              fontFamily: _fontFamily,
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                              letterSpacing: -0.27,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: -0.5,
            right: 0,
            child: Container(
              constraints: const BoxConstraints(minWidth: 120.58),
              height: 34.061,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF15C64), Color(0xFFFC9039)],
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Text(
                item.badgeLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.18,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w700,
                  height: 1.43,
                  letterSpacing: -0.13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceInputBox extends StatelessWidget {
  const _PriceInputBox({required this.creditsValue});

  final String creditsValue;

  static const String _fontFamily = 'Helvetica Neue';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39.51,
      height: 25.89,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD1D5DC)),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: creditsValue,
              style: const TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 12.11,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w400,
                height: 1.50,
                letterSpacing: -0.24,
              ),
            ),
            const TextSpan(
              text: '€',
              style: TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 12.11,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w400,
                height: 1.50,
                letterSpacing: -0.24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
