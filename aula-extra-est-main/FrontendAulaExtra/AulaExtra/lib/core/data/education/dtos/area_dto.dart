class AreaDto {
  AreaDto({
    required this.idArea,
    required this.nome,
    this.descricao,
  });

  final String idArea;
  final String nome;
  final String? descricao;

  factory AreaDto.fromJson(Map<String, dynamic> json) {
    final id = (json['idArea'] ?? json['IdArea'] ?? json['id_area'])?.toString() ?? '';
    final nome = (json['nome'] ?? json['Nome'])?.toString() ?? '';
    final descricao = (json['descricao'] ?? json['Descricao'])?.toString();

    return AreaDto(
      idArea: id,
      nome: nome,
      descricao: descricao,
    );
  }
}
