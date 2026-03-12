import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:aula_extra/features/faq/widgets/faq_buttons.dart';
import 'package:aula_extra/features/faq/widgets/faq_gradient_circle_icon.dart';
import 'package:flutter/material.dart';

class FaqContactCard extends StatelessWidget {
  const FaqContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(FaqDimens.radiusCard),
        border: Border.all(color: FaqColors.orangeSoft, width: FaqDimens.borderThick),
        gradient: FaqGradients.contactBackground,
      ),
      child: const Padding(
        padding: EdgeInsets.only(
          left: 193.964,
          right: 193.964,
          top: 43.387,
          bottom: 43.387,
        ),
        child: _ContactInner(),
      ),
    );
  }
}

class _ContactInner extends StatelessWidget {
  const _ContactInner();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 321.571),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaqGradientCircleIcon(
            size: 81.669,
            iconSize: 40.834,
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 20.417),
          const Text(
            FaqCopy.contactTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30.626,
              height: 1.33,
              fontWeight: FontWeight.w700,
              color: FaqColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10.209),
          const SizedBox(
            width: 857.524,
            child: Text(
              FaqCopy.contactBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.417,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: FaqColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 30.626),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaqGradientIconButton(
                width: 242.195,
                height: 76.565,
                label: FaqCopy.contactPrimaryCta,
                icon: Icons.send_outlined,
              ),
              SizedBox(width: 15.313),
              FaqOutlinedButton(
                width: 197.951,
                height: 76.565,
                label: FaqCopy.contactSecondaryCta,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
