import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../constants/newsletter_mock_data.dart';
import '../models/newsletter_campaign.dart';
import '../sections/newsletter_overview_section.dart';
import '../widgets/newsletter_campaign_dialog.dart';

class NewsletterPage extends StatefulWidget {
  const NewsletterPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<NewsletterPage> createState() => _NewsletterPageState();
}

class _NewsletterPageState extends State<NewsletterPage> {
  late final List<NewsletterCampaign> _items;

  @override
  void initState() {
    super.initState();
    _items = List<NewsletterCampaign>.from(newsletterMockCampaigns);
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.newsletter,
      title: 'Newsletter',
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
                  maxWidth: NewsletterPage._contentMaxWidth,
                ),
                child: NewsletterOverviewSection(
                  items: _items,
                  onCreate: _openCreateDialog,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<NewsletterCampaignDialogResult>(
      context: context,
      barrierColor: const Color(0x73000000),
      builder: (_) => const NewsletterCampaignDialog(),
    );

    if (result == null) {
      return;
    }

    final isDraft = result.action == NewsletterCampaignDialogAction.draft;
    final newItem = NewsletterCampaign(
      title: result.internalName,
      subject: result.emailSubject,
      audience: result.audience,
      scheduledFor: isDraft ? 'Rascunho' : 'Hoje · agora',
      status: isDraft
          ? NewsletterCampaignStatus.draft
          : NewsletterCampaignStatus.sent,
      sentCount: _estimateSentCount(result.audience),
      openRate: isDraft ? 0 : 0,
      clickRate: isDraft ? 0 : 0,
    );

    setState(() {
      _items.insert(0, newItem);
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            isDraft
                ? 'Newsletter guardada em rascunho.'
                : 'Campanha enviada e adicionada à lista.',
          ),
        ),
      );
  }

  int _estimateSentCount(String audience) {
    switch (audience) {
      case 'Novos registos':
        return 1240;
      case 'Alunos inativos há 30 dias':
        return 860;
      case 'Explicadores ativos':
        return 420;
      case 'Leads do formulário principal':
        return 310;
      default:
        return 0;
    }
  }
}
