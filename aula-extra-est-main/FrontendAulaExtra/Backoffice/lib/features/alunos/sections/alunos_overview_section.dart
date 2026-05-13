import 'package:flutter/material.dart';

import '../models/aluno_item.dart';
import '../services/backoffice_students_service.dart';
import '../widgets/alunos_notice_card.dart';
import 'alunos_header_section.dart';
import 'alunos_table_section.dart';

class AlunosOverviewSection extends StatefulWidget {
  const AlunosOverviewSection({super.key});

  @override
  State<AlunosOverviewSection> createState() => _AlunosOverviewSectionState();
}

class _AlunosOverviewSectionState extends State<AlunosOverviewSection> {
  late Future<BackofficeStudentsViewData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<BackofficeStudentsViewData> _load() {
    return BackofficeStudentsService().fetch();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BackofficeStudentsViewData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ??
            const BackofficeStudentsViewData(items: <AlunoItem>[]);

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AlunosHeaderSection(),
            if (data.warningMessage != null) ...[
              const SizedBox(height: 24),
              AlunosNoticeCard(
                message: data.warningMessage!,
                onRetry: _reload,
              ),
            ],
            const SizedBox(height: 37.273),
            AlunosTableSection(items: data.items),
          ],
        );
      },
    );
  }
}
