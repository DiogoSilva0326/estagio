import 'backoffice_nav_item.dart';

class BackofficeNavSection {
  const BackofficeNavSection({required this.title, required this.items});

  final String title;
  final List<BackofficeNavItem> items;
}
