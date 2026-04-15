import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_colors.dart';
import 'package:aula_extra/features/professor/pagamentos/constants/pagamentos_professor_layout.dart';
import 'package:flutter/material.dart';

class PagamentosWithdrawButton extends StatelessWidget {
  const PagamentosWithdrawButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: PagamentosProfessorLayout.withdrawButtonWidth,
      height: PagamentosProfessorLayout.withdrawButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PagamentosProfessorLayout.withdrawButtonRadius,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PagamentosProfessorColors.withdrawGradientTop,
              PagamentosProfessorColors.withdrawGradientBottom,
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            PagamentosProfessorLayout.withdrawButtonRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 14.38, right: 14.38),
            child: Row(
              children: const [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: PagamentosProfessorLayout.withdrawIconSize,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Solicitar Saque',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: PagamentosProfessorLayout.tableTextFontSize,
                      fontWeight: FontWeight.w500,
                      height:
                          PagamentosProfessorLayout.tableTextLineHeight /
                          PagamentosProfessorLayout.tableTextFontSize,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
