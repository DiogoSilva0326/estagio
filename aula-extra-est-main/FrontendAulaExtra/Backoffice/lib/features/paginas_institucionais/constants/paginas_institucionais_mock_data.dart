import '../models/institutional_page_item.dart';

const paginasInstitucionaisMockData = <InstitutionalPageItem>[
  InstitutionalPageItem(
    id: 'CMS-001',
    title: 'Como Funciona',
    slug: '/como-funciona',
    updatedAtLabel: '10 Abr 2026',
    status: InstitutionalPageStatus.published,
  ),
  InstitutionalPageItem(
    id: 'CMS-002',
    title: 'Termos de Serviço',
    slug: '/termos-servico',
    updatedAtLabel: '05 Mar 2026',
    status: InstitutionalPageStatus.published,
  ),
  InstitutionalPageItem(
    id: 'CMS-003',
    title: 'Política de Privacidade',
    slug: '/privacidade',
    updatedAtLabel: '05 Mar 2026',
    status: InstitutionalPageStatus.published,
  ),
  InstitutionalPageItem(
    id: 'CMS-004',
    title: 'Para Explicadores',
    slug: '/para-explicadores',
    updatedAtLabel: '12 Abr 2026',
    status: InstitutionalPageStatus.draft,
  ),
];
