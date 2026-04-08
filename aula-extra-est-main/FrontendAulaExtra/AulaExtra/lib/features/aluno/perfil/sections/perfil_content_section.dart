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
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PerfilConstants.horizontalPadding,
        vertical: PerfilConstants.verticalPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AlunoMenuNav(selectedIndex: 8),
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
                if (_loadingProfile)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_profileError != null)
                  Row(
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
                else
                  _PerfilFormCard(
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
                  ),
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
      padding: const EdgeInsets.fromLTRB(
        PerfilConstants.horizontalCardPadding,
        PerfilConstants.verticalCardPadding,
        PerfilConstants.horizontalCardPadding,
        1.39,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PerfilConstants.cardRadius),
        border: Border.all(color: PerfilConstants.cardBorderColor, width: 1.39),
        boxShadow: PerfilConstants.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PerfilHeader(
            initials: headerInitials,
            name: headerName,
            email: headerEmail,
            imageUrl: profileImageUrl,
            onEditTap: imageBusy ? null : onPickProfileImage,
          ),
          const SizedBox(height: PerfilConstants.cardGap),
          Text('Foto de Perfil', style: PerfilConstants.sectionHeadingStyle),
          const SizedBox(height: PerfilConstants.smallGap),
          const Text(
            'Pode carregar uma foto sua ou usar um avatar por URL. A imagem fica guardada no Cloudflare.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF4A5565),
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: PerfilConstants.smallGap),
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
          const SizedBox(height: PerfilConstants.fieldGap),
          PerfilLabeledField(
            label: 'Avatar por URL',
            controller: avatarUrlController,
            keyboardType: TextInputType.url,
            hintText: 'https://.../avatar.png',
          ),
          const SizedBox(height: PerfilConstants.smallGap),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: imageBusy ? null : onApplyAvatarUrl,
              icon: const Icon(Icons.public),
              label: const Text('Usar avatar da internet'),
            ),
          ),
          const SizedBox(height: PerfilConstants.cardGap),
          PerfilLabeledField(label: 'Username', controller: usernameController),
          const SizedBox(height: PerfilConstants.fieldGap),
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
          const SizedBox(height: PerfilConstants.fieldGap),
          PerfilLabeledField(
            label: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
          ),
          const SizedBox(height: PerfilConstants.fieldGap),
          PerfilLabeledField(
            label: 'Telefone',
            controller: telefoneController,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: PerfilConstants.fieldGap),
          Text('Nível de Ensino', style: PerfilConstants.labelStyle),
          const SizedBox(height: PerfilConstants.smallGap),
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
              height: PerfilConstants.pillHeight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final c in ciclos) ...[
                      PerfilPillOption(
                        label: c.nome,
                        selected: nivelEnsino == c.nome,
                        width: 190,
                        onTap: () => onNivelEnsinoChanged(c.nome),
                      ),
                      const SizedBox(width: 16.685),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: PerfilConstants.fieldGap),
          PerfilLabeledField(
            label: 'Biografia',
            controller: biografiaController,
            maxLines: 5,
          ),
          const SizedBox(height: PerfilConstants.fieldGap),
          Text('Disciplinas de Interesse', style: PerfilConstants.labelStyle),
          const SizedBox(height: PerfilConstants.smallGap),
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
              spacing: 11.124,
              runSpacing: 11.124,
              children: [
                for (final d in visibleInteresses)
                  PerfilInterestChip(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  minimumSize: const Size(0, 56),
                  foregroundColor: PerfilConstants.orange,
                  textStyle: const TextStyle(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: const Text('Ver mais'),
              ),
            ),
          ],
          const SizedBox(height: PerfilConstants.fieldGap),
          InkWell(
            onTap: onSalvar,
            borderRadius: BorderRadius.circular(PerfilConstants.fieldRadius),
            child: Container(
              height: 66.742,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  PerfilConstants.fieldRadius,
                ),
                gradient: PerfilConstants.gradientOrange,
              ),
              alignment: Alignment.center,
              child: const Text(
                'Salvar Perfil',
                style: PerfilConstants.buttonTextStyle,
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class _PerfilHeader extends StatelessWidget {
  const _PerfilHeader({
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 266.966,
      width: double.infinity,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: 177.978,
              height: 177.978,
              child: Stack(
                children: [
                  Container(
                    width: 177.978,
                    height: 177.978,
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
                            width: 177.978,
                            height: 177.978,
                            errorBuilder: (context, error, stackTrace) => Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 50.056,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 55.618 / 50.056,
                              ),
                            ),
                          )
                        : Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 50.056,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              height: 55.618 / 50.056,
                            ),
                          ),
                  ),
                  Positioned(
                    left: 122.36,
                    top: 122.36,
                    child: InkWell(
                      onTap: onEditTap,
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 55.618,
                        height: 55.618,
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
                          child: Icon(
                            Icons.edit,
                            size: 27.809,
                            color: Color(0xFF364153),
                          ),
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
                    style: const TextStyle(
                      fontSize: 27.809,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF101828),
                      height: 38.933 / 27.809,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 19.466,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4A5565),
                      height: 27.809 / 19.466,
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
