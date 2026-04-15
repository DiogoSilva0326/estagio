class ContactFormCategoryDto {
  ContactFormCategoryDto({
    required this.idContactFormCategory,
    required this.name,
    this.description,
  });

  final String idContactFormCategory;
  final String name;
  final String? description;

  factory ContactFormCategoryDto.fromJson(Map<String, dynamic> json) {
    return ContactFormCategoryDto(
      idContactFormCategory:
          (json['idContactFormCategory'] ??
                  json['IdContactFormCategory'] ??
                  json['id_contact_form_category'])
              ?.toString() ??
          '',
      name: (json['name'] ?? json['Name'])?.toString() ?? '',
      description: (json['description'] ?? json['Description'])?.toString(),
    );
  }
}
