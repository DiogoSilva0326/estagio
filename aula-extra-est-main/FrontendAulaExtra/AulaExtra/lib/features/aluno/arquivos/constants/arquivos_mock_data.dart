import 'package:flutter/material.dart';

/// Modelo de linha para a lista de “ficheiros recentes” no ecrã de Arquivos.
///
/// Onde é usado:
/// - Em `lib/features/aluno/arquivos/` para renderizar cada row (nome, tipo,
///   explicador, data, tamanho e ícone).
class ArquivoRecenteRowData {
  const ArquivoRecenteRowData({
    required this.fileName,
    required this.fileType,
    required this.tutor,
    required this.date,
    required this.sizeLabel,
    required this.icon,
  });

  final String fileName;
  final String fileType;
  final String tutor;
  final String date;
  final String sizeLabel;
  final IconData icon;
}

class ArquivosMockData {
  const ArquivosMockData._();

  /// Lista fake de ficheiros recentes para preencher a UI (protótipo/dev).
  static const recentFiles = <ArquivoRecenteRowData>[
    ArquivoRecenteRowData(
      fileName: 'Exercícios_Álgebra.pdf',
      fileType: 'PDF',
      tutor: 'João Silva',
      date: '25 Jan 2026',
      sizeLabel: '2.3 MB',
      icon: Icons.picture_as_pdf_rounded,
    ),
    ArquivoRecenteRowData(
      fileName: 'Relatório_Física.docx',
      fileType: 'DOCX',
      tutor: 'Maria Santos',
      date: '24 Jan 2026',
      sizeLabel: '1.8 MB',
      icon: Icons.description_rounded,
    ),
    ArquivoRecenteRowData(
      fileName: 'Apresentação_Inglês.pptx',
      fileType: 'PPTX',
      tutor: 'Pedro Costa',
      date: '23 Jan 2026',
      sizeLabel: '5.1 MB',
      icon: Icons.slideshow_rounded,
    ),
    ArquivoRecenteRowData(
      fileName: 'Notas_Geometria.pdf',
      fileType: 'PDF',
      tutor: 'João Silva',
      date: '22 Jan 2026',
      sizeLabel: '890 KB',
      icon: Icons.picture_as_pdf_rounded,
    ),
  ];
}
