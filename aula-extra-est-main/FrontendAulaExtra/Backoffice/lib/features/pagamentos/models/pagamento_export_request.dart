enum PagamentoExportScope {
  selecionadas,
  todas,
  professor,
  aluno,
  periodo,
}

class PagamentoExportRequest {
  const PagamentoExportRequest({
    required this.scope,
    this.professor,
    this.aluno,
    this.month,
    this.year,
  });

  final PagamentoExportScope scope;
  final String? professor;
  final String? aluno;
  final int? month;
  final int? year;
}