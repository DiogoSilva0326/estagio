class DisciplinaDto {
  DisciplinaDto({
    required this.idDisciplina,
    this.idArea,
    required this.nome,
    this.descricao,
  });

  final String idDisciplina;
  final String? idArea;
  final String nome;
  final String? descricao;

  factory DisciplinaDto.fromJson(Map<String, dynamic> json) {
    final id = (json['idDisciplina'] ?? json['IdDisciplina'] ?? json['id_disciplina'] ?? json['idDisciplina'])?.toString() ?? '';
    final idArea = (json['idArea'] ?? json['IdArea'] ?? json['id_area'])?.toString();
    final nome = (json['nome'] ?? json['Nome'])?.toString() ?? '';
    final descricao = (json['descricao'] ?? json['Descricao'])?.toString();

    return DisciplinaDto(
      idDisciplina: id,
      idArea: (idArea == null || idArea.trim().isEmpty) ? null : idArea,
      nome: nome,
      descricao: descricao,
    );
  }
}
