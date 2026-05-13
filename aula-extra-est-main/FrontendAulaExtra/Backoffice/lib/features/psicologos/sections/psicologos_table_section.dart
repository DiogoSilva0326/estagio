import 'package:flutter/material.dart';

import '../../explicadores/models/explicador_item.dart';
import '../../explicadores/widgets/professional_directory_table_card.dart';

class PsicologosTableSection extends StatelessWidget {
  const PsicologosTableSection({
    required this.items,
    required this.statusFilter,
    required this.areaFilter,
    required this.verificationFilter,
    required this.areaOptions,
    required this.onStatusChanged,
    required this.onAreaChanged,
    required this.onVerificationChanged,
    required this.onReviewUpdated,
    super.key,
  });

  final List<ExplicadorItem> items;
  final String statusFilter;
  final String areaFilter;
  final String verificationFilter;
  final List<String> areaOptions;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onAreaChanged;
  final ValueChanged<String> onVerificationChanged;
  final VoidCallback onReviewUpdated;

  @override
  Widget build(BuildContext context) {
    return ProfessionalDirectoryTableCard(
      filters: <ProfessionalDirectoryFilter>[
        ProfessionalDirectoryFilter(
          label: 'ESTADO: $statusFilter',
          width: 174.14,
          options: const <String>['TODOS', 'ATIVO', 'INATIVO'],
          selectedValue: statusFilter,
          onSelected: onStatusChanged,
        ),
        ProfessionalDirectoryFilter(
          label: 'ESPECIALIDADE: $areaFilter',
          width: 212,
          options: areaOptions,
          selectedValue: areaFilter,
          onSelected: onAreaChanged,
        ),
        ProfessionalDirectoryFilter(
          label: 'VERIFICAÇÃO: $verificationFilter',
          width: 207.92,
          options: const <String>['TODOS', 'VERIFICADO', 'NÃO VERIFICADO'],
          selectedValue: verificationFilter,
          onSelected: onVerificationChanged,
        ),
      ],
      secondaryHeaderLabel: 'ESPECIALIDADE\nPRINCIPAL',
      items: items,
      entityLabel: 'psicólogo',
      reviewDialogEntityLabel: 'psicólogo',
      entityTitle: 'Psicólogo',
      emptyMessage: 'Não existem psicólogos para mostrar.',
      showVerifiedColumn: true,
      onReviewUpdated: onReviewUpdated,
    );
  }
}
