class AreaDto {
  AreaDto({
    required this.idArea,
    required this.nome,
    this.descricao,
    this.professorCount = 0,
  });

  final String idArea;
  final String nome;
  final String? descricao;
  final int professorCount;

  factory AreaDto.fromJson(Map<String, dynamic> json) {
    final id =
        (json['idArea'] ?? json['IdArea'] ?? json['id_area'])?.toString() ?? '';
    final nome = (json['nome'] ?? json['Nome'])?.toString() ?? '';
    final descricao = (json['descricao'] ?? json['Descricao'])?.toString();
    final professorCountRaw =
        json['professorCount'] ??
        json['ProfessorCount'] ??
        json['professor_count'];
    final professorCount = professorCountRaw is num
        ? professorCountRaw.toInt()
        : int.tryParse(professorCountRaw?.toString() ?? '') ?? 0;

    return AreaDto(
      idArea: id,
      nome: nome,
      descricao: descricao,
      professorCount: professorCount,
    );
  }
}
