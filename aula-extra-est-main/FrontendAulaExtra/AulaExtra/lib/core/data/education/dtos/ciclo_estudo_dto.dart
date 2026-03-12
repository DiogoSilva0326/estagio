class CicloEstudoDto {
  const CicloEstudoDto({
    required this.idCicloEstudo,
    required this.nome,
  });

  final String idCicloEstudo;
  final String nome;

  factory CicloEstudoDto.fromJson(Map<String, dynamic> json) {
    final id = json['idCicloEstudo'];
    final nome = json['nome'];

    return CicloEstudoDto(
      idCicloEstudo: id is String ? id : '',
      nome: nome is String ? nome : '',
    );
  }
}
