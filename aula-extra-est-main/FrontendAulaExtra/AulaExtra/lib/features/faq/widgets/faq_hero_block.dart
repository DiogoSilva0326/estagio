import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:aula_extra/features/faq/widgets/faq_buttons.dart';
import 'package:aula_extra/features/faq/widgets/faq_gradient_circle_icon.dart';
import 'package:aula_extra/features/faq/widgets/faq_gradient_pill_bar.dart';
import 'package:flutter/material.dart';

class FaqHeroBlock extends StatelessWidget {
  const FaqHeroBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: FaqGradients.heroBackground,
        border: Border(
          bottom: BorderSide(color: FaqColors.borderLight, width: FaqDimens.borderThin),
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.only(
          left: 148.025,
          right: 148.025,
          top: 81.669,
          bottom: 81.669,
        ),
        child: _HeroInner(),
      ),
    );
  }
}

class _HeroInner extends StatelessWidget {
  const _HeroInner();

  @override
  Widget build(BuildContext context) {
    // Fix para overflow: em vez de forçar uma altura fixa, definimos apenas um
    // minHeight para manter o layout e permitir crescer se houver arredondamentos.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 403.24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            FaqGradientCircleIcon(
              size: 102.086,
              iconSize: 51.043,
              icon: Icons.help_outline,
            ),
            SizedBox(height: 30.626),
            Text(
              FaqCopy.heroTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 61.252,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: FaqColors.textPrimary,
              ),
            ),
            SizedBox(height: 20.417),
            FaqGradientPillBar(width: 163.338, height: 5.104),
            SizedBox(height: 30.626),
            Text(
              FaqCopy.heroSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.969,
                height: 1.55,
                fontWeight: FontWeight.w400,
                color: FaqColors.textSecondary,
              ),
            ),
            SizedBox(height: 40.834),
            _SearchRow(),
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 857.524,
      height: 76.565,
      child: Row(
        children: const [
          Expanded(child: _SearchField()),
          SizedBox(width: 20.417),
          FaqGradientButton(
            width: 159.928,
            height: 76.565,
            label: FaqCopy.searchButtonLabel,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField();

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76.565,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: FaqColors.borderDefault, width: FaqDimens.borderThick),
        borderRadius: BorderRadius.circular(FaqDimens.radiusCard),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 3.828,
            offset: Offset(0, 1.276),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.417, right: 20.417),
        child: Row(
          children: [
            const SizedBox(
              width: 25.522,
              height: 25.522,
              child: Icon(Icons.search, size: 25.522, color: FaqColors.textMuted),
            ),
            const SizedBox(width: 15.313),
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(
                  fontSize: 20.417,
                  height: 1.2,
                  color: FaqColors.textPrimary,
                  fontWeight: FontWeight.w400,
                ),
                cursorColor: FaqColors.textPrimary,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: FaqCopy.searchPlaceholder,
                  hintStyle: TextStyle(
                    fontSize: 20.417,
                    height: 1.2,
                    color: Color.fromRGBO(16, 24, 40, 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
