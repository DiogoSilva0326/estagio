import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:aula_extra/features/faq/widgets/faq_buttons.dart';
import 'package:aula_extra/features/faq/widgets/faq_gradient_circle_icon.dart';
import 'package:aula_extra/features/faq/widgets/faq_gradient_pill_bar.dart';
import 'package:flutter/material.dart';

class FaqHeroBlock extends StatelessWidget {
  const FaqHeroBlock({
    super.key,
    required this.searchController,
    required this.onSearchPressed,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchPressed;

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
      child: Padding(
        padding: EdgeInsets.only(
          left: 148.025,
          right: 148.025,
          top: 81.669,
          bottom: 81.669,
        ),
        child: _HeroInner(
          searchController: searchController,
          onSearchPressed: onSearchPressed,
        ),
      ),
    );
  }
}

class _HeroInner extends StatelessWidget {
  const _HeroInner({
    required this.searchController,
    required this.onSearchPressed,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    // Fix para overflow: em vez de forçar uma altura fixa, definimos apenas um
    // minHeight para manter o layout e permitir crescer se houver arredondamentos.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 403.24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const FaqGradientCircleIcon(
              size: 102.086,
              iconSize: 51.043,
              icon: Icons.help_outline,
            ),
            const SizedBox(height: 30.626),
            const Text(
              FaqCopy.heroTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 61.252,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: FaqColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20.417),
            const FaqGradientPillBar(width: 163.338, height: 5.104),
            const SizedBox(height: 30.626),
            const Text(
              FaqCopy.heroSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.969,
                height: 1.55,
                fontWeight: FontWeight.w400,
                color: FaqColors.textSecondary,
              ),
            ),
            const SizedBox(height: 40.834),
            _SearchRow(
              searchController: searchController,
              onSearchPressed: onSearchPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.searchController,
    required this.onSearchPressed,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 857.524,
      height: 76.565,
      child: Row(
        children: [
          Expanded(
            child: _SearchField(
              controller: searchController,
              onSubmitted: (_) => onSearchPressed(),
            ),
          ),
          const SizedBox(width: 20.417),
          FaqGradientButton(
            width: 159.928,
            height: 76.565,
            label: FaqCopy.searchButtonLabel,
            onTap: onSearchPressed,
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

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
                controller: controller,
                onSubmitted: onSubmitted,
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
