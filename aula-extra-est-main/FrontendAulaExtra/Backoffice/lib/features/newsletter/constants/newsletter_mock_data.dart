import '../models/newsletter_campaign.dart';

const List<NewsletterCampaign> newsletterMockCampaigns = [
  NewsletterCampaign(
    title: 'Campanha Boas-vindas Abril',
    subject: 'Descobre as novidades da AulaExtra',
    audience: 'Novos registos',
    scheduledFor: 'Hoje · 18:30',
    status: NewsletterCampaignStatus.sent,
    sentCount: 1240,
    openRate: 48.2,
    clickRate: 12.7,
  ),
  NewsletterCampaign(
    title: 'Reativação de alunos inativos',
    subject: 'Volta a marcar sessões com desconto',
    audience: 'Alunos inativos há 30 dias',
    scheduledFor: 'Amanhã · 09:00',
    status: NewsletterCampaignStatus.scheduled,
    sentCount: 860,
    openRate: 0,
    clickRate: 0,
  ),
  NewsletterCampaign(
    title: 'Resumo mensal para explicadores',
    subject: 'Os números do teu mês na plataforma',
    audience: 'Explicadores ativos',
    scheduledFor: 'Rascunho',
    status: NewsletterCampaignStatus.draft,
    sentCount: 0,
    openRate: 0,
    clickRate: 0,
  ),
];
