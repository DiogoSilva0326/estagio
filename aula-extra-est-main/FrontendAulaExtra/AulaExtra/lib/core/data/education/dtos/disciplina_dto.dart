class DisciplinaDto {
  DisciplinaDto({
    required this.idDisciplina,
    this.idArea,
    this.areaNome,
    required this.nome,
    this.descricao,
    this.idCicloEstudo,
    this.cicloEstudos,
    this.activeStudentsCount = 0,
    this.isActive = true,
    this.updatedAt,
  });

  final String idDisciplina;
  final String? idArea;
  final String? areaNome;
  final String nome;
  final String? descricao;
  final String? idCicloEstudo;
  final String? cicloEstudos;
  final int activeStudentsCount;
  final bool isActive;
  final DateTime? updatedAt;

  String get areaLabel {
    final value = areaNome?.trim();
    if (value == null || value.isEmpty) return 'Área não definida';
    return value;
  }

  String get cicloEstudosLabel {
    final value = cicloEstudos?.trim();
    if (value == null || value.isEmpty) return 'Ciclo de estudos não definido';
    return value;
  }

  factory DisciplinaDto.fromJson(Map<String, dynamic> json) {
    final id =
        (json['idDisciplina'] ??
                json['IdDisciplina'] ??
                json['id_disciplina'] ??
                json['idDisciplina'])
            ?.toString() ??
        '';
    final idArea = (json['idArea'] ?? json['IdArea'] ?? json['id_area'])
        ?.toString();
    final areaNome = (json['areaNome'] ?? json['AreaNome'] ?? json['area_nome'])
        ?.toString();
    final nome = (json['nome'] ?? json['Nome'])?.toString() ?? '';
    final descricao = (json['descricao'] ?? json['Descricao'])?.toString();
    final idCicloEstudo =
        (json['idCicloEstudo'] ??
                json['IdCicloEstudo'] ??
                json['id_ciclo_estudo'])
            ?.toString();
    final cicloEstudos =
        (json['cicloEstudos'] ?? json['CicloEstudos'] ?? json['ciclo_estudos'])
            ?.toString();
    final activeStudentsCount =
        int.tryParse(
          (json['activeStudentsCount'] ??
                  json['ActiveStudentsCount'] ??
                  json['active_students_count'] ??
                  0)
              .toString(),
        ) ??
        0;
    final isActiveRaw =
        json['isActive'] ?? json['IsActive'] ?? json['is_active'];
    final updatedAtRaw =
        json['updatedAt'] ?? json['UpdatedAt'] ?? json['updated_at'];

    return DisciplinaDto(
      idDisciplina: id,
      idArea: (idArea == null || idArea.trim().isEmpty) ? null : idArea,
      areaNome: (areaNome == null || areaNome.trim().isEmpty) ? null : areaNome,
      nome: nome,
      descricao: descricao,
      idCicloEstudo: (idCicloEstudo == null || idCicloEstudo.trim().isEmpty)
          ? null
          : idCicloEstudo,
      cicloEstudos: (cicloEstudos == null || cicloEstudos.trim().isEmpty)
          ? null
          : cicloEstudos,
      activeStudentsCount: activeStudentsCount,
      isActive: isActiveRaw is bool
          ? isActiveRaw
          : isActiveRaw?.toString().toLowerCase() != 'false',
      updatedAt: updatedAtRaw == null
          ? null
          : DateTime.tryParse(updatedAtRaw.toString()),
    );
  }
}
