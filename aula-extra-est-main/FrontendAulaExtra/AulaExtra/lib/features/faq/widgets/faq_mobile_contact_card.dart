import 'package:aula_extra/features/faq/constants/faq_constants.dart';
import 'package:aula_extra/features/faq/constants/faq_copy.dart';
import 'package:aula_extra/features/faq/widgets/faq_gradient_circle_icon.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class FaqMobileContactCard extends StatelessWidget {
  const FaqMobileContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FaqColors.orangeSoft, width: 1.5),
        gradient: FaqGradients.contactBackground,
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Column(
        children: [
          const FaqGradientCircleIcon(
            size: 64,
            iconSize: 30,
            icon: Icons.mail_outline,
          ),
          const SizedBox(height: 16),
          const Text(
            FaqCopy.contactTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: FaqColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            FaqCopy.contactBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: FaqColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: FaqGradients.orangeVertical,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.contactos),
                icon: const Icon(
                  Icons.send_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  FaqCopy.contactPrimaryCta,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: FaqColors.borderDefault,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                FaqCopy.contactSecondaryCta,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: FaqColors.textButtonSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
