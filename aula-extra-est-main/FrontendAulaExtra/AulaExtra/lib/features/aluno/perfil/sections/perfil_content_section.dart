import 'package:aula_extra/core/components/header/app_header.dart';
import 'package:aula_extra/features/aluno/core/widgets/aluno_menu_nav.dart';
import 'package:aula_extra/core/data/education/dtos/ciclo_estudo_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/users/users_api.dart';
import 'package:aula_extra/core/data/users/dtos/user_profile_dto.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/aluno/perfil/constants/perfil_constants.dart';
import 'package:aula_extra/features/aluno/perfil/widgets/perfil_action_card.dart';
import 'package:aula_extra/features/aluno/perfil/widgets/perfil_interest_chip.dart';
import 'package:aula_extra/features/aluno/perfil/widgets/perfil_labeled_field.dart';
import 'package:aula_extra/features/aluno/perfil/widgets/perfil_pill_option.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PerfilContentSection extends StatefulWidget {
  const PerfilContentSection({super.key});

  @override
  State<PerfilContentSection> createState() => _PerfilContentSectionState();
}

class _PerfilContentSectionState extends State<PerfilContentSection> {
  final EducationService _education = EducationService();
  final UsersService _users = UsersService();

  late final TextEditingController _usernameController;
  late final TextEditingController _primeiroNomeController;
  late final TextEditingController _ultimoNomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _biografiaController;
  late final TextEditingController _avatarUrlController;

  bool _loadingProfile = true;
  String? _profileError;

  bool _loadingCiclos = true;
  String? _ciclosError;
  List<CicloEstudoDto> _ciclos = const [];

  String _nivelEnsino = '';
  String _website = '';
  String? _profileImageUrl;
  bool _savingProfileImage = false;

  static const int _interessesPageSize = 10;
  int _interessesPagesShown = 1;

  bool _loadingDisciplinas = true;
  String? _disciplinasError;
  List<DisciplinaDto> _myDisciplinas = const [];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _primeiroNomeController = TextEditingController();
    _ultimoNomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _biografiaController = TextEditingController();
    _avatarUrlController = TextEditingController();

    _loadProfile();
    _loadCiclos();
    _loadMyDisciplinas();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _primeiroNomeController.dispose();
    _ultimoNomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _biografiaController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  void _syncProvider(UserProfileDto me) {
    final displayName = (me.displayName ?? '').trim();
    final username = (me.username ?? '').trim();
    final email = (me.email ?? '').trim();

    context.read<UserProvider>().setAccount(
      (context.read<UserProvider>().account ?? const UserAccount()).copyWith(
        fullName: displayName.isEmpty ? null : displayName,
        username: username.isEmpty ? null : username,
        email: email.isEmpty ? null : email,
        mobileNumber: (me.mobileNumber ?? me.phoneNumber)?.trim(),
        profileImageUrl: me.profileImageUrl?.trim().isEmpty == true
            ? null
            : me.profileImageUrl?.trim(),
      ),
    );
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loadingProfile = true;
      _profileError = null;
    });

    try {
      final me = await _users.getMe();
      if (!mounted) return;

      final displayName = (me.displayName ?? '').trim();
      final parts = displayName
          .split(RegExp(r'\s+'))
          .where((p) => p.trim().isNotEmpty)
          .toList(growable: false);
      final firstName = parts.isEmpty ? '' : parts.first;
      final lastName = parts.length <= 1 ? '' : parts.sublist(1).join(' ');

      setState(() {
        _usernameController.text = (me.username ?? '').trim();
        _primeiroNomeController.text = firstName;
        _ultimoNomeController.text = lastName;
        _emailController.text = (me.email ?? '').trim();
        _telefoneController.text = (me.mobileNumber ?? me.phoneNumber ?? '')
            .trim();
        _biografiaController.text = (me.biography ?? '').trim();
        _nivelEnsino = (me.educationLevel ?? '').trim();
        _website = (me.website ?? '').trim();
        _profileImageUrl = me.profileImageUrl?.trim().isEmpty == true
            ? null
            : me.profileImageUrl?.trim();
        _loadingProfile = false;
      });
      _syncProvider(me);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingProfile = false;
        _profileError = e.toString();
      });
    }
  }

  Future<void> _loadCiclos() async {
    setState(() {
      _loadingCiclos = true;
      _ciclosError = null;
    });

    try {
      final ciclos = await _education.getCiclosEstudo();
      if (!mounted) return;
      setState(() {
        _ciclos = ciclos;
        _loadingCiclos = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCiclos = false;
        _ciclosError = e.toString();
      });
    }
  }

  Future<void> _loadMyDisciplinas() async {
    setState(() {
      _loadingDisciplinas = true;
      _disciplinasError = null;
    });

    try {
      final mine = await _education.getMyDisciplinas();
      if (!mounted) return;
      setState(() {
        _myDisciplinas = mine;
        _interessesPagesShown = 1;
        _loadingDisciplinas = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingDisciplinas = false;
        _disciplinasError = e.toString();
      });
    }
  }

  Future<void> _removeDisciplina(DisciplinaDto disciplina) async {
    setState(() {
      _loadingDisciplinas = true;
      _disciplinasError = null;
    });

    try {
      final updated = await _education.removeMyDisciplina(
        idDisciplina: disciplina.idDisciplina,
      );
      if (!mounted) return;
      setState(() {
        _myDisciplinas = updated;
        _interessesPagesShown = 1;
        _loadingDisciplinas = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingDisciplinas = false;
        _disciplinasError = e.toString();
      });
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      setState(() => _savingProfileImage = true);
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: false,
      );

      final file = result?.files.single;
      final bytes = file?.bytes;
      if (file == null || bytes == null || bytes.isEmpty) {
        return;
      }

      final uploaded = await _users.uploadMyProfileImage(
        bytes: bytes,
        fileName: file.name,
      );

      if (!mounted) return;
      setState(() {
        _profileImageUrl = uploaded.profileImageUrl?.trim();
      });
      _syncProvider(uploaded);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem de perfil atualizada.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _savingProfileImage = false);
      }
    }
  }

  Future<void> _applyAvatarUrl() async {
    final imageUrl = _avatarUrlController.text.trim();
    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indique uma URL de avatar.')),
      );
      return;
    }

    try {
      setState(() => _savingProfileImage = true);
      final uploaded = await _users.setMyProfileImageFromUrl(imageUrl);
      if (!mounted) return;
      setState(() {
        _profileImageUrl = uploaded.profileImageUrl?.trim();
      });
      _syncProvider(uploaded);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar aplicado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _savingProfileImage = false);
      }
    }
  }

  Future<void> _removeProfileImage() async {
    try {
      setState(() => _savingProfileImage = true);
      await _users.deleteMyProfileImage();
      if (!mounted) return;
      setState(() {
        _profileImageUrl = null;
      });
      context.read<UserProvider>().setAccount(
        (context.read<UserProvider>().account ?? const UserAccount()).copyWith(
          profileImageUrl: '',
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagem de perfil removida.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _savingProfileImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile =
        MediaQuery.sizeOf(context).width <= AppHeader.mobileBreakpoint;

    final content = _loadingProfile
        ? const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        : _profileError != null
        ? Row(
            children: [
              Expanded(
                child: Text(
                  _profileError!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _loadProfile,
                child: const Text('Tentar novamente'),
              ),
            ],
          )
        : _PerfilFormCard(
            isMobile: isMobile,
            profileImageUrl: _profileImageUrl,
            avatarUrlController: _avatarUrlController,
            imageBusy: _savingProfileImage,
            onPickProfileImage: _pickProfileImage,
            onApplyAvatarUrl: _applyAvatarUrl,
            onRemoveProfileImage: _removeProfileImage,
            usernameController: _usernameController,
            primeiroNomeController: _primeiroNomeController,
            ultimoNomeController: _ultimoNomeController,
            emailController: _emailController,
            telefoneController: _telefoneController,
            biografiaController: _biografiaController,
            nivelEnsino: _nivelEnsino,
            onNivelEnsinoChanged: (value) =>
                setState(() => _nivelEnsino = value),
            ciclosLoading: _loadingCiclos,
            ciclosError: _ciclosError,
            ciclos: _ciclos,
            onReloadCiclos: _loadCiclos,
            disciplinasLoading: _loadingDisciplinas,
            disciplinasError: _disciplinasError,
            disciplinas: _myDisciplinas,
            interessesPageSize: _interessesPageSize,
            interessesPagesShown: _interessesPagesShown,
            onInteressesVerMais: () =>
                setState(() => _interessesPagesShown += 1),
            onReloadDisciplinas: _loadMyDisciplinas,
            onRemoveDisciplina: _removeDisciplina,
            onSalvar: () async {
              try {
                final username = _usernameController.text.trim();
                if (username.isEmpty) {
                  throw const UsersException('Username é obrigatório');
                }

                final computedDisplayName =
                    '${_primeiroNomeController.text.trim()} ${_ultimoNomeController.text.trim()}'
                        .trim();
                await _users.updateMe(
                  username: username,
                  displayName: computedDisplayName,
                  educationLevel: _nivelEnsino,
                  biography: _biografiaController.text,
                  mobileNumber: _telefoneController.text,
                  phoneNumber: _telefoneController.text,
                  website: _website,
                );
                await _loadProfile();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil guardado')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
          );

    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: PerfilConstants.mobileHorizontalPadding,
          vertical: PerfilConstants.mobileVerticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Perfil', style: PerfilConstants.mobileTitleStyle),
            const SizedBox(height: 8),
            const Text(
              'Gerencie as suas informações pessoais.',
              style: PerfilConstants.mobileSubtitleStyle,
            ),
            const SizedBox(height: PerfilConstants.mobileSectionSpacing),
            content,
            const SizedBox(height: PerfilConstants.mobileSectionSpacing),
            PerfilActionCard(
              isMobile: true,
              title: 'Alterar Senha',
              buttonLabel: 'Alterar Senha',
              onPressed: () {},
            ),
            const SizedBox(height: 14),
            PerfilActionCard(
              isMobile: true,
              title: 'Excluir Conta',
              buttonLabel: 'Excluir Conta',
              onPressed: () {},
              buttonBorderColor: const Color(0xFFFFC9C9),
              buttonTextColor: const Color(0xFFE7000B),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PerfilConstants.horizontalPadding,
        vertical: PerfilConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(selectedIndex: 7),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Perfil', style: PerfilConstants.titleStyle),
                const SizedBox(height: 11.124),
                const Text(
                  'Gerencie suas informações pessoais',
                  style: PerfilConstants.subtitleStyle,
                ),
                const SizedBox(height: PerfilConstants.cardGap),
                content,
                const SizedBox(height: PerfilConstants.cardGap),
                Row(
                  children: [
                    Expanded(
                      child: PerfilActionCard(
                        title: 'Alterar Senha',
                        buttonLabel: 'Alterar Senha',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 33.371),
                    Expanded(
                      child: PerfilActionCard(
                        title: 'Excluir Conta',
                        buttonLabel: 'Excluir Conta',
                        onPressed: () {},
                        buttonBorderColor: const Color(0xFFFFC9C9),
                        buttonTextColor: const Color(0xFFE7000B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerfilFormCard extends StatelessWidget {
  const _PerfilFormCard({
    this.isMobile = false,
    required this.profileImageUrl,
    required this.avatarUrlController,
    required this.imageBusy,
    required this.onPickProfileImage,
    required this.onApplyAvatarUrl,
    required this.onRemoveProfileImage,
    required this.usernameController,
    required this.primeiroNomeController,
    required this.ultimoNomeController,
    required this.emailController,
    required this.telefoneController,
    required this.biografiaController,
    required this.nivelEnsino,
    required this.onNivelEnsinoChanged,
    required this.ciclosLoading,
    required this.ciclosError,
    required this.ciclos,
    required this.onReloadCiclos,
    required this.disciplinasLoading,
    required this.disciplinasError,
    required this.disciplinas,
    required this.interessesPageSize,
    required this.interessesPagesShown,
    required this.onInteressesVerMais,
    required this.onReloadDisciplinas,
    required this.onRemoveDisciplina,
    required this.onSalvar,
  });

  final bool isMobile;

  final String? profileImageUrl;
  final TextEditingController avatarUrlController;
  final bool imageBusy;
  final VoidCallback onPickProfileImage;
  final VoidCallback onApplyAvatarUrl;
  final VoidCallback onRemoveProfileImage;

  final TextEditingController usernameController;
  final TextEditingController primeiroNomeController;
  final TextEditingController ultimoNomeController;
  final TextEditingController emailController;
  final TextEditingController telefoneController;
  final TextEditingController biografiaController;

  final String nivelEnsino;
  final ValueChanged<String> onNivelEnsinoChanged;

  final bool ciclosLoading;
  final String? ciclosError;
  final List<CicloEstudoDto> ciclos;
  final VoidCallback onReloadCiclos;

  final bool disciplinasLoading;
  final String? disciplinasError;
  final List<DisciplinaDto> disciplinas;

  final int interessesPageSize;
  final int interessesPagesShown;
  final VoidCallback onInteressesVerMais;
  final VoidCallback onReloadDisciplinas;
  final ValueChanged<DisciplinaDto> onRemoveDisciplina;

  final VoidCallback onSalvar;

  @override
  Widget build(BuildContext context) {
    final visibleInteressesCount = (interessesPageSize * interessesPagesShown)
        .clamp(0, disciplinas.length);
    final visibleInteresses = disciplinas
        .take(visibleInteressesCount)
        .toList(growable: false);
    final hasMoreInteresses = disciplinas.length > visibleInteressesCount;

    final displayName =
        '${primeiroNomeController.text.trim()} ${ultimoNomeController.text.trim()}'
            .trim();
    final headerName = displayName.isEmpty ? '—' : displayName;
    final headerEmail = emailController.text.trim().isEmpty
        ? '—'
        : emailController.text.trim();
    final headerInitials = _getInitials(
      displayName.isEmpty ? usernameController.text : displayName,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : PerfilConstants.horizontalCardPadding,
        isMobile ? 22 : PerfilConstants.verticalCardPadding,
        isMobile ? 18 : PerfilConstants.horizontalCardPadding,
        isMobile ? 18 : 1.39,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          isMobile
              ? PerfilConstants.mobileCardRadius
              : PerfilConstants.cardRadius,
        ),
        border: Border.all(
          color: isMobile
              ? PerfilConstants.mobileCardBorderColor
              : PerfilConstants.cardBorderColor,
          width: 1.39,
        ),
        boxShadow: isMobile
            ? PerfilConstants.mobileShadow
            : PerfilConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PerfilHeader(
            isMobile: isMobile,
            initials: headerInitials,
            name: headerName,
            email: headerEmail,
            imageUrl: profileImageUrl,
            onEditTap: imageBusy ? null : onPickProfileImage,
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileCardGap
                : PerfilConstants.cardGap,
          ),
          Text(
            'Foto de Perfil',
            style: isMobile
                ? PerfilConstants.mobileSectionHeadingStyle
                : PerfilConstants.sectionHeadingStyle,
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileSmallGap
                : PerfilConstants.smallGap,
          ),
          Text(
            'Pode carregar uma foto sua ou usar um avatar por URL. A imagem fica guardada no Cloudflare.',
            style: isMobile
                ? PerfilConstants.mobileBodyStyle
                : const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A5565),
                    height: 24 / 16,
                  ),
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileSmallGap
                : PerfilConstants.smallGap,
          ),
          if (isMobile)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: imageBusy ? null : onPickProfileImage,
                    icon: imageBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_outlined),
                    label: const Text('Carregar imagem'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: imageBusy ? null : onRemoveProfileImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remover'),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: imageBusy ? null : onPickProfileImage,
                    icon: imageBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.upload_outlined),
                    label: const Text('Carregar imagem'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: imageBusy ? null : onRemoveProfileImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remover'),
                  ),
                ),
              ],
            ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileFieldGap
                : PerfilConstants.fieldGap,
          ),
          PerfilLabeledField(
            isMobile: isMobile,
            label: 'Avatar por URL',
            controller: avatarUrlController,
            keyboardType: TextInputType.url,
            hintText: 'https://.../avatar.png',
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileSmallGap
                : PerfilConstants.smallGap,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: imageBusy ? null : onApplyAvatarUrl,
              icon: const Icon(Icons.public),
              label: const Text('Usar avatar da internet'),
            ),
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileCardGap
                : PerfilConstants.cardGap,
          ),
          PerfilLabeledField(
            isMobile: isMobile,
            label: 'Username',
            controller: usernameController,
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileFieldGap
                : PerfilConstants.fieldGap,
          ),
          if (isMobile)
            Column(
              children: [
                PerfilLabeledField(
                  isMobile: true,
                  label: 'Primeiro nome',
                  controller: primeiroNomeController,
                ),
                const SizedBox(height: PerfilConstants.mobileFieldGap),
                PerfilLabeledField(
                  isMobile: true,
                  label: 'Último nome',
                  controller: ultimoNomeController,
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: PerfilLabeledField(
                    label: 'Primeiro nome',
                    controller: primeiroNomeController,
                  ),
                ),
                const SizedBox(width: 16.685),
                Expanded(
                  child: PerfilLabeledField(
                    label: 'Último nome',
                    controller: ultimoNomeController,
                  ),
                ),
              ],
            ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileFieldGap
                : PerfilConstants.fieldGap,
          ),
          PerfilLabeledField(
            isMobile: isMobile,
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileFieldGap
                : PerfilConstants.fieldGap,
          ),
          PerfilLabeledField(
            isMobile: isMobile,
            label: 'Telefone',
            controller: telefoneController,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileFieldGap
                : PerfilConstants.fieldGap,
          ),
          Text(
            'Nível de Ensino',
            style: isMobile
                ? PerfilConstants.mobileLabelStyle
                : PerfilConstants.labelStyle,
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileSmallGap
                : PerfilConstants.smallGap,
          ),
          if (ciclosLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (ciclosError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ciclosError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onReloadCiclos,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: isMobile
                  ? PerfilConstants.mobilePillHeight
                  : PerfilConstants.pillHeight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final c in ciclos) ...[
                      PerfilPillOption(
                        isMobile: isMobile,
                        label: c.nome,
                        selected: nivelEnsino == c.nome,
                        width: isMobile ? null : 190,
                        onTap: () => onNivelEnsinoChanged(c.nome),
                      ),
                      SizedBox(width: isMobile ? 10 : 16.685),
                    ],
                  ],
                ),
              ),
            ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileFieldGap
                : PerfilConstants.fieldGap,
          ),
          PerfilLabeledField(
            isMobile: isMobile,
            label: 'Biografia',
            controller: biografiaController,
            maxLines: 5,
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileFieldGap
                : PerfilConstants.fieldGap,
          ),
          Text(
            'Disciplinas de Interesse',
            style: isMobile
                ? PerfilConstants.mobileLabelStyle
                : PerfilConstants.labelStyle,
          ),
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileSmallGap
                : PerfilConstants.smallGap,
          ),
          if (disciplinasLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (disciplinasError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      disciplinasError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: onReloadDisciplinas,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: isMobile ? 8 : 11.124,
              runSpacing: isMobile ? 8 : 11.124,
              children: [
                for (final d in visibleInteresses)
                  PerfilInterestChip(
                    isMobile: isMobile,
                    label: d.nome,
                    onRemove: () => onRemoveDisciplina(d),
                  ),
              ],
            ),
          if (!disciplinasLoading &&
              disciplinasError == null &&
              hasMoreInteresses) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onInteressesVerMais,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: PerfilConstants.orange,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : 28,
                    vertical: isMobile ? 12 : 16,
                  ),
                  minimumSize: Size(0, isMobile ? 44 : 56),
                  foregroundColor: PerfilConstants.orange,
                  textStyle: TextStyle(
                    fontSize: isMobile ? 14 : 20,
                    height: isMobile ? 20 / 14 : 28 / 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Ver mais'),
              ),
            ),
          ],
          SizedBox(
            height: isMobile
                ? PerfilConstants.mobileFieldGap
                : PerfilConstants.fieldGap,
          ),
          InkWell(
            onTap: onSalvar,
            borderRadius: BorderRadius.circular(
              isMobile
                  ? PerfilConstants.mobileFieldRadius
                  : PerfilConstants.fieldRadius,
            ),
            child: Container(
              height: isMobile ? 44 : 66.742,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  isMobile
                      ? PerfilConstants.mobileFieldRadius
                      : PerfilConstants.fieldRadius,
                ),
                gradient: PerfilConstants.gradientOrange,
              ),
              alignment: Alignment.center,
              child: Text(
                'Salvar Perfil',
                style: isMobile
                    ? PerfilConstants.mobileButtonTextStyle
                    : PerfilConstants.buttonTextStyle,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 0 : 28),
        ],
      ),
    );
  }
}

class _PerfilHeader extends StatelessWidget {
  const _PerfilHeader({
    this.isMobile = false,
    required this.initials,
    required this.name,
    required this.email,
    this.imageUrl,
    this.onEditTap,
  });

  final String initials;
  final String name;
  final String email;
  final String? imageUrl;
  final VoidCallback? onEditTap;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isMobile ? 176 : 266.966,
      width: double.infinity,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: isMobile ? 117.341 : 177.978,
              height: isMobile ? 117.341 : 177.978,
              child: Stack(
                children: [
                  Container(
                    width: isMobile ? 117.341 : 177.978,
                    height: isMobile ? 117.341 : 177.978,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: PerfilConstants.gradientOrange,
                    ),
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null && imageUrl!.trim().isNotEmpty
                        ? Image.network(
                            imageUrl!.trim(),
                            fit: BoxFit.cover,
                            width: isMobile ? 117.341 : 177.978,
                            height: isMobile ? 117.341 : 177.978,
                            errorBuilder: (context, error, stackTrace) => Text(
                              initials,
                              style: TextStyle(
                                fontSize: isMobile ? 32 : 50.056,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: isMobile ? 38 / 32 : 55.618 / 50.056,
                              ),
                            ),
                          )
                        : Text(
                            initials,
                            style: TextStyle(
                              fontSize: isMobile ? 32 : 50.056,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: isMobile ? 38 / 32 : 55.618 / 50.056,
                            ),
                          ),
                  ),
                  Positioned(
                    left: isMobile ? 80.67 : 122.36,
                    top: isMobile ? 80.67 : 122.36,
                    child: InkWell(
                      onTap: onEditTap,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: isMobile ? 36.669 : 55.618,
                        height: isMobile ? 36.669 : 55.618,
                        padding: const EdgeInsets.all(2.781),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PerfilConstants.cardBorderColor,
                            width: 2.781,
                          ),
                          boxShadow: PerfilConstants.floatingShadow,
                        ),
                        child: const Center(
                          child: Icon(Icons.edit, color: Color(0xFF364153)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 27.809,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101828),
                      height: isMobile ? 26 / 18 : 38.933 / 27.809,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 19.466,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4A5565),
                      height: isMobile ? 18 / 13 : 27.809 / 19.466,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _getInitials(String input) {
  final cleaned = input.trim();
  if (cleaned.isEmpty) return '—';

  final parts = cleaned
      .split(RegExp(r'\s+'))
      .where((p) => p.trim().isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return '—';
  if (parts.length == 1) {
    final w = parts.first;
    return w.length >= 2
        ? w.substring(0, 2).toUpperCase()
        : w.substring(0, 1).toUpperCase();
  }
  final a = parts.first;
  final b = parts.last;
  final ia = a.isEmpty ? '' : a.substring(0, 1);
  final ib = b.isEmpty ? '' : b.substring(0, 1);
  final res = (ia + ib).trim();
  return res.isEmpty ? '—' : res.toUpperCase();
}
