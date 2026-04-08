class TutorBrowseItemDto {
  const TutorBrowseItemDto({
    required this.idProfessor,
    required this.name,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.description,
    required this.lessonsCount,
    required this.minPrice,
    required this.tags,
  });

  final String idProfessor;
  final String name;
  final String subtitle;
  final double rating;
  final int reviewCount;
  final String description;
  final int lessonsCount;
  final double minPrice;
  final List<String> tags;

  static String _str(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v == null) return '';
    return v.toString();
  }

  static num _num(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is num) return v;
    return num.tryParse(v?.toString() ?? '') ?? 0;
  }

  static int _int(Map<String, dynamic> json, String key) => _num(json, key).toInt();
  static double _double(Map<String, dynamic> json, String key) => _num(json, key).toDouble();

  factory TutorBrowseItemDto.fromJson(Map<String, dynamic> json) {
    // Backend serializes PascalCase by default; accept both.
    final id = _str(json, 'idProfessor');
    final id2 = id.isNotEmpty ? id : _str(json, 'IdProfessor');

    final name = _str(json, 'name');
    final name2 = name.isNotEmpty ? name : _str(json, 'Name');

    final subtitle = _str(json, 'subtitle');
    final subtitle2 = subtitle.isNotEmpty ? subtitle : _str(json, 'Subtitle');

    final desc = _str(json, 'description');
    final desc2 = desc.isNotEmpty ? desc : _str(json, 'Description');

    final tagsRaw = json['tags'] ?? json['Tags'];
    final tags = (tagsRaw is List)
        ? tagsRaw.map((e) => e?.toString() ?? '').where((s) => s.trim().isNotEmpty).toList(growable: false)
        : const <String>[];

    return TutorBrowseItemDto(
      idProfessor: id2,
      name: name2,
      subtitle: subtitle2,
      rating: _double(json, 'rating') != 0 ? _double(json, 'rating') : _double(json, 'Rating'),
      reviewCount: _int(json, 'reviewCount') != 0 ? _int(json, 'reviewCount') : _int(json, 'ReviewCount'),
      description: desc2,
      lessonsCount: _int(json, 'lessonsCount') != 0 ? _int(json, 'lessonsCount') : _int(json, 'LessonsCount'),
      minPrice: _double(json, 'minPrice') != 0 ? _double(json, 'minPrice') : _double(json, 'MinPrice'),
      tags: tags,
    );
  }
}
