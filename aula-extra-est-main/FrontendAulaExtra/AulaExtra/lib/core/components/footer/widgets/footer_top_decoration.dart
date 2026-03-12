import 'package:aula_extra/core/components/footer/assets/footer_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class FooterTopDecoration extends StatelessWidget {
  const FooterTopDecoration({
    super.key,
    required this.scale,
  });

  final double scale;
  double s(double v) => v * scale;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mantemos a tua lógica de 11 divisões para gerar o itemWidth
        final itemWidth = constraints.maxWidth / 11;

        return SizedBox(
          width: constraints.maxWidth,
          // Definimos uma altura fixa baseada na escala para garantir que não corta o topo
          height: s(40), 
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                // O segredo está aqui: bottom: 0 "cola" o Row à linha do footer
                // Se ainda vires um micro-espaço, podes usar -0.5 ou -1
                bottom: 0,
                left: -itemWidth / 2,
                right: -itemWidth / 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(12, (_) {
                    return SizedBox(
                      width: itemWidth,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: s(8)),
                        child: SvgPicture.asset(
                          FooterAssets.topGroup,
                          // BoxFit.fitHeight garante que ele use a altura disponível 
                          // sem ultrapassar o topo do container
                          fit: BoxFit.contain,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}