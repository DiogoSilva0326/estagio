import '../models/newsletter_campaign.dart';

const List<NewsletterCampaign> newsletterMockCampaigns = [
  NewsletterCampaign(
    id: 'mock-1',
    title: 'Campanha Boas-vindas Abril',
    subject: 'Descobre as novidades da AulaExtra',
    segment: 'new_registrations',
    status: NewsletterCampaignStatus.sent,
    totalRecipients: 1240,
    sentCount: 1240,
    openRate: 48.2,
    clickRate: 12.7,
  ),
  NewsletterCampaign(
    id: 'mock-2',
    title: 'Reativação de alunos inativos',
    subject: 'Volta a marcar sessões com desconto',
    segment: 'inactive_students_30d',
    status: NewsletterCampaignStatus.scheduled,
    totalRecipients: 860,
    sentCount: 860,
    openRate: 0,
    clickRate: 0,
  ),
  NewsletterCampaign(
    id: 'mock-3',
    title: 'Resumo mensal para explicadores',
    subject: 'Os números do teu mês na plataforma',
    segment: 'active_professors',
    status: NewsletterCampaignStatus.draft,
    sentCount: 0,
    openRate: 0,
    clickRate: 0,
  ),
];
