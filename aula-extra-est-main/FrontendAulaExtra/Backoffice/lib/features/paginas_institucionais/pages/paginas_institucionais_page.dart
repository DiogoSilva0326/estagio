import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../constants/paginas_institucionais_mock_data.dart';
import '../models/institutional_page_item.dart';
import '../sections/paginas_institucionais_overview_section.dart';

class PaginasInstitucionaisPage extends StatefulWidget {
  const PaginasInstitucionaisPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<PaginasInstitucionaisPage> createState() =>
      _PaginasInstitucionaisPageState();
}

class _PaginasInstitucionaisPageState extends State<PaginasInstitucionaisPage> {
  late final List<InstitutionalPageItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List<InstitutionalPageItem>.from(paginasInstitucionaisMockData);
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.paginasInstitucionais,
      title: 'Páginas Institucionais',
      showTopBar: false,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;
          final verticalPadding = constraints.maxWidth < 900 ? 24.0 : 55.91;

          return Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: PaginasInstitucionaisPage._contentMaxWidth,
                ),
                child: PaginasInstitucionaisOverviewSection(
                  items: _items,
                  onCreate: _createPage,
                  onEdit: _editPage,
                  onPreview: _previewPage,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _createPage() {
    final nextIndex = _items.length + 1;
    final newItem = InstitutionalPageItem(
      id: 'CMS-${nextIndex.toString().padLeft(3, '0')}',
      title: 'Nova Página ${nextIndex.toString().padLeft(2, '0')}',
      slug: '/nova-pagina-${nextIndex.toString().padLeft(2, '0')}',
      updatedAtLabel: 'Hoje',
      status: InstitutionalPageStatus.draft,
    );

    setState(() {
      _items.insert(0, newItem);
    });

    _showMessage('Página criada em rascunho.');
  }

  void _editPage(InstitutionalPageItem item) {
    _showMessage('Abrir editor para `${item.title}`.');
  }

  void _previewPage(InstitutionalPageItem item) {
    _showMessage('Pré-visualização de `${item.slug}` disponível em breve.');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
