import 'package:flutter/material.dart';

import '../../../design/widgets/backoffice_scaffold.dart';
import '../../../routes/app_routes.dart';
import '../models/newsletter_campaign.dart';
import '../models/newsletter_subscriber.dart';
import '../sections/newsletter_overview_section.dart';
import '../services/backoffice_newsletter_service.dart';
import '../widgets/newsletter_campaign_dialog.dart';

class NewsletterPage extends StatefulWidget {
  const NewsletterPage({super.key});

  static const double _contentMaxWidth = 1028.513;

  @override
  State<NewsletterPage> createState() => _NewsletterPageState();
}

class _NewsletterPageState extends State<NewsletterPage> {
  final BackofficeNewsletterService _service = BackofficeNewsletterService();

  List<NewsletterCampaign> _items = const <NewsletterCampaign>[];
  List<NewsletterSubscriber> _subscribers = const <NewsletterSubscriber>[];
  int _subscriberCount = 0;
  String? _warningMessage;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return BackofficeScaffold(
      currentRoute: AppRoutes.newsletter,
      title: 'Newsletter',
      showTopBar: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
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
                        subscribers: _subscribers,
                        subscriberCount: _subscriberCount,
                        warningMessage: _warningMessage,
                        creating: _submitting,
                        onCreate: _submitting ? null : _openCreateDialog,
                        onOpenCampaign: _openCampaignDetails,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final data = await _service.fetch();
    if (!mounted) {
      return;
    }

    setState(() {
      _items = data.items;
      _subscribers = data.subscribers;
      _subscriberCount = data.subscriberCount;
      _warningMessage = data.warningMessage;
      _loading = false;
    });
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

    await _saveCampaignFromDialog(result);
  }

  Future<void> _openCampaignDetails(NewsletterCampaign item) async {
    try {
      final campaign = await _service.fetchCampaignById(item.id);
      if (!mounted) {
        return;
      }

      if (campaign.status == NewsletterCampaignStatus.draft) {
        final result = await showDialog<NewsletterCampaignDialogResult>(
          context: context,
          barrierColor: const Color(0x73000000),
          builder: (_) => NewsletterCampaignDialog(
            initialInternalName: campaign.title,
            initialEmailSubject: campaign.subject,
            initialAudience: campaign.audience,
            initialEmailBody: campaign.htmlBody ?? campaign.plainBody ?? '',
            title: 'Editar Rascunho',
            subtitle:
                'Atualize o rascunho e, se quiser, envie-o diretamente daqui.',
          ),
        );

        if (result == null) {
          return;
        }

        await _saveCampaignFromDialog(result, campaignId: campaign.id);
        return;
      }

      await showDialog<void>(
        context: context,
        barrierColor: const Color(0x73000000),
        builder: (_) => NewsletterCampaignDialog(
          initialInternalName: campaign.title,
          initialEmailSubject: campaign.subject,
          initialAudience: campaign.audience,
          initialEmailBody: campaign.htmlBody ?? campaign.plainBody ?? '',
          readOnly: true,
          title: 'Visualizar Campanha',
          subtitle:
              'Campanha já enviada. Pode consultar o conteúdo e os detalhes do envio.',
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Não foi possível abrir a campanha: $error')),
        );
    }
  }

  Future<void> _saveCampaignFromDialog(
    NewsletterCampaignDialogResult result, {
    String? campaignId,
  }) async {
    final draft = NewsletterCampaignDraft(
      title: result.internalName,
      subject: result.emailSubject,
      segment: _segmentToApiValue(result.audience),
      htmlBody: result.emailBody,
    );

    setState(() {
      _submitting = true;
    });

    try {
      final saved = campaignId == null
          ? await _service.createCampaign(draft)
          : await _service.updateCampaign(campaignId, draft);

      var successMessage = campaignId == null
          ? 'Newsletter guardada em rascunho.'
          : 'Rascunho atualizado com sucesso.';
      if (result.action == NewsletterCampaignDialogAction.send) {
        final sendResult = await _service.sendCampaign(saved.id);
        successMessage =
            'Campanha enviada: ${sendResult['sent'] ?? 0} enviados, ${sendResult['failed'] ?? 0} falhas.';
      }

      await _load();
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Não foi possível guardar a campanha: $error')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String _segmentToApiValue(String audience) {
    switch (audience) {
      case 'Todos os subscritores':
        return 'all_subscribed';
      case 'Novos registos':
        return 'new_registrations';
      case 'Alunos inativos há 30 dias':
        return 'inactive_students_30d';
      case 'Explicadores ativos':
        return 'active_professors';
      case 'Leads do formulário principal':
        return 'main_form_leads';
      default:
        return 'all_subscribed';
    }
  }
}