import 'package:flutter/material.dart';

import '../../../design/theme/app_colors.dart';
import '../../dashboard/widgets/dashboard_section_header.dart';
import '../../dashboard/widgets/dashboard_status_badge.dart';
import '../../dashboard/widgets/dashboard_surface_card.dart';
import '../models/newsletter_campaign.dart';

class NewsletterCampaignsSection extends StatelessWidget {
  const NewsletterCampaignsSection({
    required this.items,
    required this.onOpenCampaign,
    super.key,
  });

  final List<NewsletterCampaign> items;
  final ValueChanged<NewsletterCampaign> onOpenCampaign;

  @override
  Widget build(BuildContext context) {
    return DashboardSurfaceCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardSectionHeader(
            title: 'Campanhas recentes',
            subtitle: 'Resumo das newsletters criadas e respetivo desempenho.',
          ),
          const SizedBox(height: 24),
          if (items.isEmpty)
            const Text(
              'Ainda não existem campanhas sincronizadas para mostrar.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 860) {
                  return Column(
                    children: [
                      for (var index = 0; index < items.length; index++) ...[
                        _CampaignMobileCard(
                          item: items[index],
                          onTap: () => onOpenCampaign(items[index]),
                        ),
                        if (index != items.length - 1) const SizedBox(height: 16),
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    const _CampaignTableHeader(),
                    const SizedBox(height: 8),
                    for (var index = 0; index < items.length; index++) ...[
                      _CampaignTableRow(
                        item: items[index],
                        onTap: () => onOpenCampaign(items[index]),
                      ),
                      if (index != items.length - 1)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CampaignTableHeader extends StatelessWidget {
  const _CampaignTableHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: _HeaderLabel('Campanha')),
          Expanded(flex: 2, child: _HeaderLabel('Audiência')),
          Expanded(flex: 2, child: _HeaderLabel('Agendamento')),
          Expanded(flex: 2, child: _HeaderLabel('Desempenho')),
          Expanded(child: _HeaderLabel('Estado')),
        ],
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  const _HeaderLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _CampaignTableRow extends StatelessWidget {
  const _CampaignTableRow({required this.item, required this.onTap});

  final NewsletterCampaign item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subject,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  item.audience,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  item.scheduledFor,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  item.performanceLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: DashboardStatusBadge(
                    label: item.status.label,
                    color: item.status.textColor,
                    backgroundColor: item.status.backgroundColor,
                    showDot: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CampaignMobileCard extends StatelessWidget {
  const _CampaignMobileCard({required this.item, required this.onTap});

  final NewsletterCampaign item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subject,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  DashboardStatusBadge(
                    label: item.status.label,
                    color: item.status.textColor,
                    backgroundColor: item.status.backgroundColor,
                    showDot: true,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Audiência: ${item.audience}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Agendamento: ${item.scheduledFor}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.performanceLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
