class ProfessorAdDto {
  const ProfessorAdDto({
    required this.idProfessorAd,
    required this.idProfessor,
    required this.idCourse,
    this.idDisciplina,
    this.disciplinaNome,
    this.idCicloEstudo,
    this.cicloEstudos,
    this.idTutoringType,
    this.tutoringTypeName,
    required this.courseName,
    this.description,
    this.levelOfEducation,
    this.sessionPrice,
    this.photoUrl,
    this.status = 'published',
  });

  final String idProfessorAd;
  final String idProfessor;
  final String idCourse;
  final String? idDisciplina;
  final String? disciplinaNome;
  final String? idCicloEstudo;
  final String? cicloEstudos;
  final String? idTutoringType;
  final String? tutoringTypeName;
  final String courseName;
  final String? description;
  final String? levelOfEducation;
  final double? sessionPrice;
  final String? photoUrl;
  final String status;

  factory ProfessorAdDto.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic value) {
      if (value == null) return null;
      return double.tryParse(value.toString());
    }

    String? asString(dynamic value) {
      final text = value?.toString();
      if (text == null || text.trim().isEmpty) return null;
      return text.trim();
    }

    return ProfessorAdDto(
      idProfessorAd:
          (json['idProfessorAd'] ??
                  json['IdProfessorAd'] ??
                  json['id_professor_ad'])
              ?.toString() ??
          '',
      idProfessor:
          (json['idProfessor'] ?? json['IdProfessor'] ?? json['id_professor'])
              ?.toString() ??
          '',
      idCourse: (json['idCourse'] ?? json['IdCourse'] ?? json['id_course'])
              ?.toString() ??
          '',
      idDisciplina: asString(
        json['idDisciplina'] ?? json['IdDisciplina'] ?? json['id_disciplina'],
      ),
      disciplinaNome: asString(
        json['disciplinaNome'] ??
            json['DisciplinaNome'] ??
            json['disciplina_nome'],
      ),
      idCicloEstudo: asString(
        json['idCicloEstudo'] ??
            json['IdCicloEstudo'] ??
            json['id_ciclo_estudo'],
      ),
      cicloEstudos: asString(
        json['cicloEstudos'] ??
            json['CicloEstudos'] ??
            json['ciclo_estudos'],
      ),
      idTutoringType: asString(
        json['idTutoringType'] ??
            json['IdTutoringType'] ??
            json['id_tutoring_type'],
      ),
      tutoringTypeName: asString(
        json['tutoringTypeName'] ??
            json['TutoringTypeName'] ??
            json['tutoring_type_name'],
      ),
      courseName: (json['courseName'] ?? json['CourseName'] ?? json['course_name'])
              ?.toString() ??
          '',
      description: asString(json['description'] ?? json['Description']),
      levelOfEducation: asString(
        json['levelOfEducation'] ??
            json['LevelOfEducation'] ??
            json['level_of_education'],
      ),
      sessionPrice: asDouble(
        json['sessionPrice'] ?? json['SessionPrice'] ?? json['session_price'],
      ),
      photoUrl: asString(json['photoUrl'] ?? json['PhotoUrl'] ?? json['photo_url']),
      status: asString(json['status'] ?? json['Status']) ?? 'published',
    );
  }
}
