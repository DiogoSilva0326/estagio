enum InstitutionalPageStatus {
  published,
  draft;

  String get label {
    switch (this) {
      case InstitutionalPageStatus.published:
        return 'Publicada';
      case InstitutionalPageStatus.draft:
        return 'Rascunho';
    }
  }

  String get uppercaseLabel {
    switch (this) {
      case InstitutionalPageStatus.published:
        return 'PUBLICADA';
      case InstitutionalPageStatus.draft:
        return 'RASCUNHO';
    }
  }
}

class InstitutionalPageItem {
  const InstitutionalPageItem({
    required this.id,
    required this.title,
    required this.slug,
    required this.updatedAtLabel,
    required this.status,
  });

  final String id;
  final String title;
  final String slug;
  final String updatedAtLabel;
  final InstitutionalPageStatus status;

  InstitutionalPageItem copyWith({
    String? id,
    String? title,
    String? slug,
    String? updatedAtLabel,
    InstitutionalPageStatus? status,
  }) {
    return InstitutionalPageItem(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      updatedAtLabel: updatedAtLabel ?? this.updatedAtLabel,
      status: status ?? this.status,
    );
  }
}
