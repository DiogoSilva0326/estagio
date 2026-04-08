import 'package:aula_extra/core/data/tutors/dtos/tutor_browse_item_dto.dart';

class TutorBrowseResponseDto {
  const TutorBrowseResponseDto({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.items,
  });

  final int page;
  final int pageSize;
  final int total;
  final List<TutorBrowseItemDto> items;

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  factory TutorBrowseResponseDto.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] ?? json['Items']);
    final items = (rawItems is List)
        ? rawItems.whereType<Map<String, dynamic>>().map(TutorBrowseItemDto.fromJson).toList(growable: false)
        : const <TutorBrowseItemDto>[];

    return TutorBrowseResponseDto(
      page: _int(json['page'] ?? json['Page']),
      pageSize: _int(json['pageSize'] ?? json['PageSize']),
      total: _int(json['total'] ?? json['Total']),
      items: items,
    );
  }
}
