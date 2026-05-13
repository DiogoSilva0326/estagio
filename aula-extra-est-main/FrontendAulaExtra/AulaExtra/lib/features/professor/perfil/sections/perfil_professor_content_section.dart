import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/education/education_service.dart';
import 'package:aula_extra/core/data/http/api_config.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_certificate_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_profile_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_stats_dto.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_language_dto.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/data/users/dtos/user_profile_dto.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/config/teaching_roles_config.dart';
import 'package:aula_extra/design/typography/app_typography.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/perfil/constants/perfil_professor_colors.dart';
import 'package:aula_extra/features/professor/perfil/constants/perfil_professor_layout.dart';
import 'package:aula_extra/features/professor/perfil/widgets/full_bleed_scaled_section.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:native_web_embeds/native_web_embeds.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const List<String> _languageLevels = <String>[
  'Nativo',
  'Avançado',
  'Intermédio',
  'Básico',
];

class PerfilProfessorContentSection extends StatefulWidget {
  const PerfilProfessorContentSection({super.key, this.isMobile = false});

  final bool isMobile;

  @override
  State<PerfilProfessorContentSection> createState() =>
      _PerfilProfessorContentSectionState();
}

class _PerfilProfessorContentSectionState
    extends State<PerfilProfessorContentSection> {
  final UsersService _users = UsersService();
  final ProfessorsService _professors = ProfessorsService();
  final EducationService _education = EducationService();

  late final TextEditingController _displayNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _nifController;
  late final TextEditingController _websiteController;
  late final TextEditingController _currentSchoolController;
  late final TextEditingController _yearsExperienceController;
  late final TextEditingController _biographyController;
  late final TextEditingController _presentationVideoUrlController;

  final ScrollController _scrollController = ScrollController();

  bool _loading = true;
  bool _saving = false;
  bool _savingProfileImage = false;
  bool _documentsBusy = false;
  String? _error;
  String? _profileImageUrl;
  DateTime? _memberSince;
  ProfessorStatsDto? _stats;

  List<DisciplinaDto> _disciplinasCatalog = <DisciplinaDto>[];
  List<DisciplinaDto> _disciplinasLecionadas = <DisciplinaDto>[];
  List<ProfessorLanguageDto> _languagesCatalog = <ProfessorLanguageDto>[];
  List<ProfessorLanguageDto> _languagesFalados = <ProfessorLanguageDto>[];
  List<ProfessorCertificateDto> _certificates = <ProfessorCertificateDto>[];

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _nifController = TextEditingController();
    _websiteController = TextEditingController();
    _currentSchoolController = TextEditingController();
    _yearsExperienceController = TextEditingController();
    _biographyController = TextEditingController();
    _presentationVideoUrlController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nifController.dispose();
    _websiteController.dispose();
    _currentSchoolController.dispose();
    _yearsExperienceController.dispose();
    _biographyController.dispose();
    _presentationVideoUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait<dynamic>([
        _users.getMe(),
        _professors.getMyProfessor(),
        _professors.getMyStats(),
        _education.getCatalog(),
        _professors.getMyDisciplinas(),
        _professors.getLanguagesCatalog(),
        _professors.getMyLanguages(),
        _professors.getMyCertificates(),
      ]);

      if (!mounted) return;

      final user = results[0] as UserProfileDto;
      final professor = results[1] as ProfessorProfileDto?;
      final stats = results[2] as ProfessorStatsDto;
      final catalog = results[3] as List<DisciplinaDto>;
      final mine = results[4] as List<DisciplinaDto>;
      final languagesCatalog = results[5] as List<ProfessorLanguageDto>;
      final myLanguages = results[6] as List<ProfessorLanguageDto>;
      final myCertificates = results[7] as List<ProfessorCertificateDto>;

      _displayNameController.text = (user.displayName ?? '').trim();
      _usernameController.text = (user.username ?? '').trim();
      _emailController.text = (user.email ?? '').trim();
      _phoneController.text = (user.mobileNumber ?? user.phoneNumber ?? '')
          .trim();
      _nifController.text = (user.nif ?? '').trim();
      _websiteController.text = (user.website ?? '').trim();
      _currentSchoolController.text = (professor?.currentSchool ?? '').trim();
      _yearsExperienceController.text =
          professor?.yearsExperience?.toString() ?? '';
      _biographyController.text = (professor?.biography ?? user.biography ?? '')
          .trim();
      _presentationVideoUrlController.text =
          (professor?.presentationVideoUrl ?? '').trim();
      _profileImageUrl =
          (user.profileImageUrl ?? professor?.photo)?.trim().isEmpty == true
          ? null
          : (user.profileImageUrl ?? professor?.photo)?.trim();

      _memberSince = user.creationDate;
      _stats = stats;

      _syncProvider(user);

      setState(() {
        _disciplinasCatalog = catalog;
        _disciplinasLecionadas = mine;
        _languagesCatalog = languagesCatalog;
        _languagesFalados = myLanguages;
        _certificates = myCertificates;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _addDisciplina(String idDisciplina) {
    final existing = _disciplinasLecionadas.any(
      (d) => d.idDisciplina == idDisciplina,
    );
    if (existing) return;

    final found = _disciplinasCatalog.where(
      (d) => d.idDisciplina == idDisciplina,
    );
    final disciplina = found.isEmpty ? null : found.first;
    if (disciplina == null) return;

    setState(() {
      _disciplinasLecionadas = <DisciplinaDto>[
        ..._disciplinasLecionadas,
        disciplina,
      ]..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    });
  }

  void _removeDisciplina(String idDisciplina) {
    setState(() {
      _disciplinasLecionadas = _disciplinasLecionadas
          .where((d) => d.idDisciplina != idDisciplina)
          .toList(growable: false);
    });
  }

  void _addLanguage(String idLanguage) {
    final existing = _languagesFalados.any(
      (item) => item.idLanguage == idLanguage,
    );
    if (existing) return;

    final found = _languagesCatalog.where(
      (item) => item.idLanguage == idLanguage,
    );
    final language = found.isEmpty ? null : found.first;
    if (language == null) return;

    setState(() {
      _languagesFalados = <ProfessorLanguageDto>[
        ..._languagesFalados,
        language.copyWith(
          proficiencyLevel: language.proficiencyLevel ?? 'Intermédio',
        ),
      ]..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    });
  }

  void _removeLanguage(String idLanguage) {
    setState(() {
      _languagesFalados = _languagesFalados
          .where((item) => item.idLanguage != idLanguage)
          .toList(growable: false);
    });
  }

  void _updateLanguageLevel(String idLanguage, String proficiencyLevel) {
    setState(() {
      _languagesFalados = _languagesFalados
          .map(
            (item) => item.idLanguage == idLanguage
                ? item.copyWith(proficiencyLevel: proficiencyLevel)
                : item,
          )
          .toList(growable: false);
    });
  }

  void _syncProvider(UserProfileDto me) {
    context.read<UserProvider>().setAccount(
      (context.read<UserProvider>().account ?? const UserAccount()).copyWith(
        fullName: (me.displayName ?? '').trim().isEmpty
            ? null
            : (me.displayName ?? '').trim(),
        username: (me.username ?? '').trim().isEmpty
            ? null
            : (me.username ?? '').trim(),
        email: (me.email ?? '').trim().isEmpty ? null : (me.email ?? '').trim(),
        mobileNumber: (me.mobileNumber ?? me.phoneNumber)?.trim(),
        nif: me.nif?.trim(),
        profileImageUrl: me.profileImageUrl?.trim().isEmpty == true
            ? null
            : me.profileImageUrl?.trim(),
      ),
    );
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

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Username é obrigatório.')));
      return;
    }

    final yearsExperienceText = _yearsExperienceController.text.trim();
    final yearsExperience = yearsExperienceText.isEmpty
        ? null
        : int.tryParse(yearsExperienceText);
    if (yearsExperienceText.isNotEmpty && yearsExperience == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Os anos de experiência devem ser numéricos.'),
        ),
      );
      return;
    }

    try {
      setState(() => _saving = true);

      final updatedUser = await _users.updateMe(
        username: username,
        displayName: _displayNameController.text,
        educationLevel: '',
        biography: _biographyController.text,
        mobileNumber: _phoneController.text,
        phoneNumber: _phoneController.text,
        website: _websiteController.text,
      );

      await _professors.upsertMyProfessor(
        username: username,
        mobileNumber: _phoneController.text,
        nif: _nifController.text,
        currentSchool: _currentSchoolController.text,
        yearsExperience: yearsExperience,
        presentationVideoUrl: _presentationVideoUrlController.text,
        photo: _profileImageUrl,
        biography: _biographyController.text,
      );

      await _professors.setMyDisciplinas(
        ids: _disciplinasLecionadas.map((d) => d.idDisciplina).toList(),
      );

      await _professors.setMyLanguages(items: _languagesFalados);

      _syncProvider(updatedUser);
      await _loadProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil guardado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _refreshCertificates() async {
    final items = await _professors.getMyCertificates();
    if (!mounted) return;
    setState(() {
      _certificates = items;
    });
  }

  Future<void> _addCertificate() async {
    final draft = await _showCertificateDialog();
    if (draft == null) return;

    try {
      setState(() => _documentsBusy = true);
      await _professors.createMyCertificate(
        name: draft.name,
        description: draft.description,
        bytes: draft.fileBytes!,
        fileName: draft.fileName!,
      );
      await _refreshCertificates();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento adicionado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _documentsBusy = false);
      }
    }
  }

  Future<void> _editCertificate(ProfessorCertificateDto certificate) async {
    final draft = await _showCertificateDialog(initial: certificate);
    if (draft == null) return;

    try {
      setState(() => _documentsBusy = true);
      await _professors.updateMyCertificate(
        idCertificate: certificate.idCertificate,
        name: draft.name,
        description: draft.description,
        fileUrl: certificate.fileUrl,
        bytes: draft.fileBytes,
        fileName: draft.fileName,
      );
      await _refreshCertificates();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento atualizado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _documentsBusy = false);
      }
    }
  }

  Future<void> _deleteCertificate(ProfessorCertificateDto certificate) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remover documento'),
          content: Text(
            'Queres remover "${certificate.name?.trim().isNotEmpty == true ? certificate.name!.trim() : 'este documento'}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      setState(() => _documentsBusy = true);
      await _professors.deleteMyCertificate(certificate.idCertificate);
      await _refreshCertificates();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento removido com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _documentsBusy = false);
      }
    }
  }

  Future<void> _downloadCertificate(ProfessorCertificateDto certificate) async {
    final uri = _buildCertificateDownloadUri(certificate.fileUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este documento não tem ficheiro disponível.'),
        ),
      );
      return;
    }

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o documento.')),
      );
    }
  }

  Uri? _buildCertificateDownloadUri(String? storedValue) {
    final normalized = storedValue?.trim() ?? '';
    if (normalized.isEmpty) return null;

    final absoluteUri = Uri.tryParse(normalized);
    if (absoluteUri != null && absoluteUri.hasScheme) {
      return absoluteUri;
    }

    final fileName = normalized
        .replaceAll('\\', '/')
        .split('/')
        .where((segment) => segment.trim().isNotEmpty)
        .lastOrNull;
    if (fileName == null || fileName.isEmpty) return null;

    final baseUri = Uri.parse(ApiConfig.baseUrl);
    return baseUri.replace(
      pathSegments: <String>[
        ...baseUri.pathSegments.where((segment) => segment.isNotEmpty),
        'uploads',
        'professor-documents',
        fileName,
      ],
    );
  }

  Future<_CertificateDraft?> _showCertificateDialog({
    ProfessorCertificateDto? initial,
  }) async {
    final nameController = TextEditingController(text: initial?.name ?? '');
    final descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    PlatformFile? selectedFile;
    String? localError;

    final result = await showDialog<_CertificateDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickFile() async {
              final fileResult = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: const <String>[
                  'pdf',
                  'png',
                  'jpg',
                  'jpeg',
                  'doc',
                  'docx',
                ],
                withData: true,
                allowMultiple: false,
              );

              final file = fileResult?.files.single;
              if (file == null) return;

              setDialogState(() {
                selectedFile = file;
                localError = null;
              });
            }

            return AlertDialog(
              title: Text(
                initial == null ? 'Adicionar documento' : 'Editar documento',
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'A que se refere o documento',
                        hintText: 'Ex.: Certificado de Inglês C1',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        hintText: 'Detalhes adicionais sobre este documento',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: pickFile,
                          icon: const Icon(Icons.upload_file_outlined),
                          label: Text(
                            initial == null
                                ? 'Escolher ficheiro'
                                : 'Substituir ficheiro',
                          ),
                        ),
                        if (selectedFile != null)
                          Text(
                            selectedFile!.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          )
                        else if (initial?.fileUrl?.trim().isNotEmpty == true)
                          const Text('Mantém o ficheiro atual'),
                      ],
                    ),
                    if (localError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        localError!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final hasExistingFile =
                        initial?.fileUrl?.trim().isNotEmpty == true;

                    if (name.isEmpty) {
                      setDialogState(() {
                        localError = 'Indica a que se refere o documento.';
                      });
                      return;
                    }

                    if (selectedFile == null && !hasExistingFile) {
                      setDialogState(() {
                        localError = 'Seleciona um ficheiro para o documento.';
                      });
                      return;
                    }

                    final bytes = selectedFile?.bytes;
                    if (selectedFile != null &&
                        (bytes == null || bytes.isEmpty)) {
                      setDialogState(() {
                        localError =
                            'Não foi possível ler o ficheiro selecionado.';
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop(
                      _CertificateDraft(
                        name: name,
                        description: descriptionController.text.trim(),
                        fileBytes: bytes,
                        fileName: selectedFile?.name,
                      ),
                    );
                  },
                  child: Text(initial == null ? 'Adicionar' : 'Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    descriptionController.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);

    final titleStyle = TextStyle(
      color: PerfilProfessorColors.title,
      fontSize: widget.isMobile
          ? PerfilProfessorLayout.mobileTitleFontSize
          : PerfilProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height:
          (widget.isMobile
              ? PerfilProfessorLayout.mobileTitleLineHeight
              : PerfilProfessorLayout.titleLineHeight) /
          (widget.isMobile
              ? PerfilProfessorLayout.mobileTitleFontSize
              : PerfilProfessorLayout.titleFontSize),
    );

    if (widget.isMobile) {
      return Container(
        width: double.infinity,
        color: PerfilProfessorColors.background,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(
            PerfilProfessorLayout.mobilePageHorizontalPadding,
            PerfilProfessorLayout.mobilePageTopPadding,
            PerfilProfessorLayout.mobilePageHorizontalPadding,
            PerfilProfessorLayout.mobilePageBottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Meu Perfil', style: titleStyle),
              const SizedBox(height: 16),
              _SaveProfileButton(
                isSaving: _saving,
                onTap: _saving ? null : _saveProfile,
                isMobile: true,
                config: config, 
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_error != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: _loadProfile,
                        child: const Text('Tentar novamente'),
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _LeftProfileCard(
                      profileImageUrl: _profileImageUrl,
                      presentationVideoController:
                          _presentationVideoUrlController,
                      memberSince: _memberSince,
                      stats: _stats,
                      imageBusy: _savingProfileImage,
                      onPickProfileImage: _pickProfileImage,
                      onRemoveProfileImage: _removeProfileImage,
                      isMobile: true,
                      config: config, 
                    ),
                    const SizedBox(height: PerfilProfessorLayout.mobileCardsGap),
                    _RightInfoCard(
                      displayNameController: _displayNameController,
                      usernameController: _usernameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      nifController: _nifController,
                      websiteController: _websiteController,
                      currentSchoolController: _currentSchoolController,
                      yearsExperienceController: _yearsExperienceController,
                      biographyController: _biographyController,
                      disciplinasCatalog: _disciplinasCatalog,
                      disciplinasLecionadas: _disciplinasLecionadas,
                      languagesCatalog: _languagesCatalog,
                      languagesFalados: _languagesFalados,
                      certificates: _certificates,
                      documentsBusy: _documentsBusy,
                      onAddDisciplina: _addDisciplina,
                      onRemoveDisciplina: _removeDisciplina,
                      onAddLanguage: _addLanguage,
                      onRemoveLanguage: _removeLanguage,
                      onUpdateLanguageLevel: _updateLanguageLevel,
                      onAddCertificate: _addCertificate,
                      onEditCertificate: _editCertificate,
                      onDeleteCertificate: _deleteCertificate,
                      onDownloadCertificate: _downloadCertificate,
                      isMobile: true,
                      config: config, 
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: PerfilProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: PerfilProfessorLayout.pageLeftPadding,
            right: PerfilProfessorLayout.pageRightPadding,
            top: PerfilProfessorLayout.pageTopPadding,
            bottom: PerfilProfessorLayout.pageBottomPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(selectedIndex: 10),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PerfilProfessorLayout.contentPadding,
                      PerfilProfessorLayout.contentPadding,
                      PerfilProfessorLayout.contentPadding,
                      40, 
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: PerfilProfessorLayout.titleLineHeight,
                              child: Text('Meu Perfil', style: titleStyle),
                            ),
                            const Spacer(),
                            _SaveProfileButton(
                              isSaving: _saving,
                              onTap: _saving ? null : _saveProfile,
                              config: config, 
                            ),
                          ],
                        ),
                        const SizedBox(height: 29.229),
                        if (_loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (_error != null)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _error!,
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
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _LeftProfileCard(
                                  profileImageUrl: _profileImageUrl,
                                  presentationVideoController:
                                      _presentationVideoUrlController,
                                  memberSince: _memberSince,
                                  stats: _stats,
                                  imageBusy: _savingProfileImage,
                                  onPickProfileImage: _pickProfileImage,
                                  onRemoveProfileImage: _removeProfileImage,
                                  isMobile: false,
                                  config: config, 
                                ),
                                const SizedBox(
                                  width: PerfilProfessorLayout.cardsGap,
                                ),
                                Expanded(
                                  child: _RightInfoCard(
                                    displayNameController: _displayNameController,
                                    usernameController: _usernameController,
                                    emailController: _emailController,
                                    phoneController: _phoneController,
                                    nifController: _nifController,
                                    websiteController: _websiteController,
                                    currentSchoolController:
                                        _currentSchoolController,
                                    yearsExperienceController:
                                        _yearsExperienceController,
                                    biographyController: _biographyController,
                                    disciplinasCatalog: _disciplinasCatalog,
                                    disciplinasLecionadas: _disciplinasLecionadas,
                                    languagesCatalog: _languagesCatalog,
                                    languagesFalados: _languagesFalados,
                                    certificates: _certificates,
                                    documentsBusy: _documentsBusy,
                                    onAddDisciplina: _addDisciplina,
                                    onRemoveDisciplina: _removeDisciplina,
                                    onAddLanguage: _addLanguage,
                                    onRemoveLanguage: _removeLanguage,
                                    onUpdateLanguageLevel: _updateLanguageLevel,
                                    onAddCertificate: _addCertificate,
                                    onEditCertificate: _editCertificate,
                                    onDeleteCertificate: _deleteCertificate,
                                    onDownloadCertificate: _downloadCertificate,
                                    isMobile: false,
                                    config: config,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
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

class _SaveProfileButton extends StatelessWidget {
  const _SaveProfileButton({
    required this.isSaving,
    required this.onTap,
    required this.config,
    this.isMobile = false,
  });

  final bool isSaving;
  final VoidCallback? onTap;
  final bool isMobile;
  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    final isOrange = config.roleName == 'Explicador';

    return SizedBox(
      width: isMobile ? double.infinity : null,
      height: isMobile
          ? PerfilProfessorLayout.mobileSaveButtonHeight
          : PerfilProfessorLayout.saveButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PerfilProfessorLayout.saveButtonRadius,
          ),
          color: isOrange ? null : config.primaryColor,
          gradient: isOrange 
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  PerfilProfessorColors.primaryGradientTop,
                  PerfilProfessorColors.primaryGradientBottom,
                ],
              )
            : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            PerfilProfessorLayout.saveButtonRadius,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 14.614),
            child: Row(
              mainAxisSize: isMobile ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSaving)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: PerfilProfessorLayout.saveButtonIconSize,
                  ),
                const SizedBox(width: 10),
                Text(
                  isSaving ? 'A guardar...' : 'Salvar Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: PerfilProfessorLayout.saveButtonFontSize,
                    fontWeight: FontWeight.w600,
                    height:
                        PerfilProfessorLayout.saveButtonLineHeight /
                        PerfilProfessorLayout.saveButtonFontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.width,
    required this.child,
    this.isMobile = false,
  });

  final double width;
  final Widget child;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PerfilProfessorLayout.cardRadius),
          border: Border.all(
            color: PerfilProfessorColors.cardBorder,
            width: PerfilProfessorLayout.cardBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 7.307,
              offset: const Offset(0, 4.871),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.871,
              offset: const Offset(0, 2.436),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile
                ? PerfilProfessorLayout.mobileCardPadding
                : PerfilProfessorLayout.cardPadding,
            isMobile
                ? PerfilProfessorLayout.mobileCardPadding
                : PerfilProfessorLayout.cardPadding,
            isMobile
                ? PerfilProfessorLayout.mobileCardPadding
                : PerfilProfessorLayout.cardPadding,
            0,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LeftProfileCard extends StatelessWidget {
  const _LeftProfileCard({
    required this.profileImageUrl,
    required this.presentationVideoController,
    required this.memberSince,
    required this.stats,
    required this.imageBusy,
    required this.onPickProfileImage,
    required this.onRemoveProfileImage,
    required this.config,
    this.isMobile = false,
  });

  final String? profileImageUrl;
  final TextEditingController presentationVideoController;
  final DateTime? memberSince;
  final ProfessorStatsDto? stats;
  final bool imageBusy;
  final VoidCallback onPickProfileImage;
  final VoidCallback onRemoveProfileImage;
  final TeachingRoleConfig config;
  final bool isMobile;

  String _formatDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year}';
  }

  String _formatRating(ProfessorStatsDto? s) {
    if (s == null) return '—';
    if (s.reviewCount <= 0) return '—';
    final fixed = s.avgRating.toStringAsFixed(1);
    return '$fixed ⭐';
  }

  String _formatLessons(ProfessorStatsDto? s) {
    if (s == null) return '—';
    return s.lessonsCount.toString();
  }

  Future<void> _openPresentationVideo(BuildContext context) async {
    final url = presentationVideoController.text.trim();
    if (url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o vídeo.')),
      );
    }
  }

  String? _extractYoutubeVideoId(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty) return null;

    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    final host = uri.host.toLowerCase();
    if (host.contains('youtu.be')) {
      final id = uri.pathSegments.isEmpty ? '' : uri.pathSegments.first;
      return id.isEmpty ? null : id;
    }

    if (host.contains('youtube.com')) {
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.trim().isNotEmpty) return videoId.trim();

      if (uri.pathSegments.length >= 2 &&
          (uri.pathSegments.first == 'embed' ||
              uri.pathSegments.first == 'shorts')) {
        final id = uri.pathSegments[1].trim();
        return id.isEmpty ? null : id;
      }
    }

    return null;
  }

  String? _buildYoutubeEmbedUrl(String rawUrl) {
    final videoId = _extractYoutubeVideoId(rawUrl);
    if (videoId == null) return null;
    return 'https://www.youtube.com/embed/$videoId?rel=0&modestbranding=1';
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;

    return _CardShell(
      width: isMobile ? double.infinity : PerfilProfessorLayout.leftCardWidth,
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Foto de Perfil', isMobile: isMobile),
          const SizedBox(height: 19.486),
          Align(
            alignment: Alignment.center,
            child: _AvatarBlock(
              imageUrl: profileImageUrl,
              busy: imageBusy,
              onPickProfileImage: onPickProfileImage,
              isMobile: isMobile,
              config: config,
            ),
          ),
          const SizedBox(height: 30.447),
          if (profileImageUrl != null && profileImageUrl!.isNotEmpty)
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: imageBusy ? null : onRemoveProfileImage,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remover foto'),
              ),
            ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: PerfilProfessorColors.cardBorder,
                  width: PerfilProfessorLayout.cardBorderWidth,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 30.447),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estatísticas',
                    style: TextStyle(
                      color: PerfilProfessorColors.title,
                      fontSize: 19.486,
                      fontWeight: FontWeight.w500,
                      height: 29.229 / 19.486,
                    ),
                  ),
                  const SizedBox(height: 14.614),
                  _InfoRow(
                    label: config.perfil.totalSessionsLabel, 
                    value: _formatLessons(stats),
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 14.614),
                  _InfoRow(
                    label: 'Avaliação',
                    value: _formatRating(stats),
                    isMobile: isMobile,
                    valueStyle: const TextStyle(
                      color: PerfilProfessorColors.warningStarText,
                      fontSize: 19.49,
                      fontFamily: AppTypography.fontFamily,
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                  ),
                  const SizedBox(height: 14.614),
                  _InfoRow(
                    label: 'Membro desde',
                    value: memberSince == null
                        ? '—'
                        : _formatDate(memberSince!),
                    isMobile: isMobile,
                  ),
                  const SizedBox(height: 30.447),
                  _LabeledField(
                    label: 'Vídeo de apresentação',
                    controller: presentationVideoController,
                    hintText: 'https://...',
                    height: 42,
                    isMobile: isMobile,
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: presentationVideoController,
                    builder: (context, value, _) {
                      final rawUrl = value.text.trim();
                      if (rawUrl.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final embedUrl = _buildYoutubeEmbedUrl(rawUrl);

                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (embedUrl != null && isCurrentRoute)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  color: Colors.black,
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: NativeIframe(
                                      src: embedUrl,
                                      fill: true,
                                      backgroundColor: Colors.black,
                                    ),
                                  ),
                                ),
                              )
                            else if (embedUrl != null)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: Text(
                                        'O vídeo fica temporariamente oculto enquanto um popup está aberto.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            else
                              const Text(
                                'Para mostrar o vídeo no perfil, use um link válido do YouTube.',
                                style: TextStyle(
                                  color: PerfilProfessorColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _openPresentationVideo(context),
                                icon: const Icon(Icons.open_in_new),
                                label: Text(
                                  embedUrl != null
                                      ? 'Abrir no YouTube'
                                      : 'Abrir vídeo',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30.447),
        ],
      ),
    );
  }
}

class _AvatarBlock extends StatelessWidget {
  const _AvatarBlock({
    required this.imageUrl,
    required this.busy,
    required this.onPickProfileImage,
    required this.config,
    this.isMobile = false,
  });

  final String? imageUrl;
  final bool busy;
  final VoidCallback onPickProfileImage;
  final TeachingRoleConfig config;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final avatarSize = isMobile
        ? PerfilProfessorLayout.mobileAvatarSize
        : PerfilProfessorLayout.avatarSize;
    final avatarActionSize = isMobile
        ? PerfilProfessorLayout.mobileAvatarActionSize
        : PerfilProfessorLayout.avatarActionSize;

    final isOrange = config.roleName == 'Explicador';

    return SizedBox(
      height: isMobile ? 172 : 199.729,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOrange ? null : config.primaryColor,
                  gradient: isOrange 
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            PerfilProfessorColors.primaryGradientTop,
                            PerfilProfessorColors.primaryGradientBottom,
                          ],
                        )
                      : null,
                ),
                child: ClipOval(
                  child: imageUrl != null && imageUrl!.isNotEmpty
                      ? Image.network(
                          imageUrl!,
                          width: avatarSize,
                          height: avatarSize,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const _AvatarFallback(),
                        )
                      : const _AvatarFallback(),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: const Offset(4, 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PerfilProfessorColors.cardBorder,
                        width: 2.436,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 18.268,
                          offset: const Offset(0, 12.179),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 7.307,
                          offset: const Offset(0, 4.871),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: busy ? null : onPickProfileImage,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: avatarActionSize,
                        height: avatarActionSize,
                        child: busy
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.photo_camera_outlined,
                                size:
                                    PerfilProfessorLayout.avatarActionIconSize,
                                color: PerfilProfessorColors.text,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15.486),
          const Text(
            'Clique no ícone para alterar a foto',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PerfilProfessorColors.muted,
              fontSize: 17.05,
              fontWeight: FontWeight.w400,
              height: 29.357 / 22.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'P',
        style: TextStyle(
          color: Colors.white,
          fontSize: PerfilProfessorLayout.avatarTextFontSize,
          fontWeight: FontWeight.w700,
          height:
              PerfilProfessorLayout.avatarTextLineHeight /
              PerfilProfessorLayout.avatarTextFontSize,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
    this.isMobile = false,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PerfilProfessorColors.muted,
            fontSize: PerfilProfessorLayout.statLabelFontSize,
            fontWeight: FontWeight.w400,
            height:
                PerfilProfessorLayout.statLabelLineHeight /
                PerfilProfessorLayout.statLabelFontSize,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style:
              valueStyle ??
              const TextStyle(
                color: PerfilProfessorColors.title,
                fontSize: PerfilProfessorLayout.statValueFontSize,
                fontWeight: FontWeight.w500,
                height:
                    PerfilProfessorLayout.statValueLineHeight /
                    PerfilProfessorLayout.statValueFontSize,
              ),
        ),
      ],
    );
  }
}

class _RightInfoCard extends StatelessWidget {
  const _RightInfoCard({
    required this.displayNameController,
    required this.usernameController,
    required this.emailController,
    required this.phoneController,
    required this.nifController,
    required this.websiteController,
    required this.currentSchoolController,
    required this.yearsExperienceController,
    required this.biographyController,
    required this.disciplinasCatalog,
    required this.disciplinasLecionadas,
    required this.languagesCatalog,
    required this.languagesFalados,
    required this.certificates,
    required this.documentsBusy,
    required this.onAddDisciplina,
    required this.onRemoveDisciplina,
    required this.onAddLanguage,
    required this.onRemoveLanguage,
    required this.onUpdateLanguageLevel,
    required this.onAddCertificate,
    required this.onEditCertificate,
    required this.onDeleteCertificate,
    required this.onDownloadCertificate,
    required this.config,
    this.isMobile = false,
  });

  final TextEditingController displayNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController nifController;
  final TextEditingController websiteController;
  final TextEditingController currentSchoolController;
  final TextEditingController yearsExperienceController;
  final TextEditingController biographyController;

  final List<DisciplinaDto> disciplinasCatalog;
  final List<DisciplinaDto> disciplinasLecionadas;
  final List<ProfessorLanguageDto> languagesCatalog;
  final List<ProfessorLanguageDto> languagesFalados;
  final List<ProfessorCertificateDto> certificates;
  final bool documentsBusy;
  final ValueChanged<String> onAddDisciplina;
  final ValueChanged<String> onRemoveDisciplina;
  final ValueChanged<String> onAddLanguage;
  final ValueChanged<String> onRemoveLanguage;
  final void Function(String idLanguage, String proficiencyLevel)
  onUpdateLanguageLevel;
  final VoidCallback onAddCertificate;
  final ValueChanged<ProfessorCertificateDto> onEditCertificate;
  final ValueChanged<ProfessorCertificateDto> onDeleteCertificate;
  final ValueChanged<ProfessorCertificateDto> onDownloadCertificate;
  final bool isMobile;
  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    final fieldGap = isMobile ? 16.0 : 24.357;
    final pairGap = isMobile ? 16.0 : 19.486;

    Widget buildFieldPair(Widget left, Widget right) {
      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            left,
            SizedBox(height: fieldGap),
            right,
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: left),
          SizedBox(width: pairGap),
          Expanded(child: right),
        ],
      );
    }

    Widget buildSectionHeader(String title, Widget trailing) {
      if (isMobile) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(title, isMobile: true),
            const SizedBox(height: 12),
            Align(alignment: Alignment.centerLeft, child: trailing),
          ],
        );
      }

      return Row(children: [_SectionTitle(title), const Spacer(), trailing]);
    }

    final selectedIds = disciplinasLecionadas
        .map((d) => d.idDisciplina)
        .toSet();
    final available = disciplinasCatalog
        .where((d) => !selectedIds.contains(d.idDisciplina))
        .toList(growable: false);
    final selectedLanguageIds = languagesFalados
        .map((item) => item.idLanguage)
        .toSet();
    final availableLanguages = languagesCatalog
        .where((item) => !selectedLanguageIds.contains(item.idLanguage))
        .toList(growable: false);

    return _CardShell(
      width: isMobile ? double.infinity : PerfilProfessorLayout.rightCardWidth,
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('Informações Pessoais', isMobile: isMobile),
          const SizedBox(height: 29.229),
          buildFieldPair(
            _LabeledField(
              label: 'Nome Completo',
              controller: displayNameController,
              isMobile: isMobile,
            ),
            _LabeledField(
              label: 'Email',
              controller: emailController,
              readOnly: true,
              isMobile: isMobile,
            ),
          ),
          SizedBox(height: fieldGap),
          buildFieldPair(
            _LabeledField(
              label: 'Username',
              controller: usernameController,
              isMobile: isMobile,
            ),
            _LabeledField(
              label: 'Telefone',
              controller: phoneController,
              keyboardType: TextInputType.phone,
              isMobile: isMobile,
            ),
          ),
          SizedBox(height: fieldGap),
          buildFieldPair(
            _LabeledField(
              label: 'NIF',
              controller: nifController,
              keyboardType: TextInputType.number,
              isMobile: isMobile,
            ),
            _LabeledField(
              label: 'Website / Página de Perfil',
              controller: websiteController,
              hintText: 'https://...',
              isMobile: isMobile,
            ),
          ),
          SizedBox(height: fieldGap),
          buildFieldPair(
            _LabeledField(
              label: 'Escola Atual / Clínica',
              controller: currentSchoolController,
              isMobile: isMobile,
            ),
            _LabeledField(
              label: 'Anos de Experiência',
              controller: yearsExperienceController,
              keyboardType: TextInputType.number,
              isMobile: isMobile,
            ),
          ),
          SizedBox(height: fieldGap),
          _LabeledField(
            label: 'Biografia',
            controller: biographyController,
            maxLines: 5,
            height: 120,
            isMobile: isMobile,
          ),
          SizedBox(height: fieldGap),
          buildSectionHeader(
            config.perfil.subjectsSectionTitle, 
            _AddDisciplinaMenuButton(
              enabled: available.isNotEmpty,
              items: available,
              onSelected: onAddDisciplina,
              isMobile: isMobile,
              config: config, 
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final d in disciplinasLecionadas)
                _DisciplinaChip(
                  label: d.nome,
                  onRemove: () => onRemoveDisciplina(d.idDisciplina),
                  isMobile: isMobile,
                  config: config,
                ),
            ],
          ),
          SizedBox(height: fieldGap),
          buildSectionHeader(
            'Idiomas que Falo',
            _AddLanguageMenuButton(
              enabled: availableLanguages.isNotEmpty,
              items: availableLanguages,
              onSelected: onAddLanguage,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final language in languagesFalados)
                _LanguageChip(
                  item: language,
                  levels: _languageLevels,
                  onRemove: () => onRemoveLanguage(language.idLanguage),
                  onLevelChanged: (value) =>
                      onUpdateLanguageLevel(language.idLanguage, value),
                  isMobile: isMobile,
                ),
            ],
          ),
          SizedBox(height: fieldGap),
          buildSectionHeader(
            'Documentos e Certificados',
            OutlinedButton.icon(
              onPressed: documentsBusy ? null : onAddCertificate,
              icon: documentsBusy
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_circle_outline),
              label: const Text('Adicionar documento'),
            ),
          ),
          const SizedBox(height: 12),
          if (certificates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PerfilProfessorColors.cardBorder),
              ),
              child: const Text(
                'Ainda não adicionaste documentos ao teu perfil.',
                style: TextStyle(
                  color: PerfilProfessorColors.muted,
                  fontSize: 14,
                ),
              ),
            )
          else
            Column(
              children: [
                for (final certificate in certificates) ...[
                  _CertificateCard(
                    certificate: certificate,
                    busy: documentsBusy,
                    onEdit: () => onEditCertificate(certificate),
                    onDelete: () => onDeleteCertificate(certificate),
                    onDownload: () => onDownloadCertificate(certificate),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          const SizedBox(height: 30.447),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.certificate,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
    required this.onDownload,
  });

  final ProfessorCertificateDto certificate;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDownload;

  String _formatDate(DateTime? value) {
    if (value == null) return '—';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    final title = certificate.name?.trim().isNotEmpty == true
        ? certificate.name!.trim()
        : 'Documento sem título';
    final description = certificate.description?.trim();
    final hasFile = certificate.fileUrl?.trim().isNotEmpty == true;
    final statusColor = certificate.isVerified
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFFEF3C7);
    final statusTextColor = certificate.isVerified
        ? const Color(0xFF166534)
        : const Color(0xFF92400E);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PerfilProfessorColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                color: PerfilProfessorColors.title,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: PerfilProfessorColors.title,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  certificate.isVerified ? 'Verificado' : 'Pendente',
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                color: PerfilProfessorColors.muted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Atualizado em ${_formatDate(certificate.updatedAt ?? certificate.createdAt)}',
            style: const TextStyle(
              color: PerfilProfessorColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: busy ? null : onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
              FilledButton.tonalIcon(
                onPressed: busy || !hasFile ? null : onDownload,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Download'),
              ),
              TextButton.icon(
                onPressed: busy ? null : onDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remover'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddLanguageMenuButton extends StatelessWidget {
  const _AddLanguageMenuButton({
    required this.enabled,
    required this.items,
    required this.onSelected,
    this.isMobile = false,
  });

  final bool enabled;
  final List<ProfessorLanguageDto> items;
  final ValueChanged<String> onSelected;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PerfilProfessorLayout.inputRadius),
        border: Border.all(
          color: PerfilProfessorColors.cardBorder,
          width: PerfilProfessorLayout.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language_rounded,
              size: 18,
              color: enabled
                  ? PerfilProfessorColors.title
                  : PerfilProfessorColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              'Adicionar Idioma',
              style: TextStyle(
                color: enabled
                    ? PerfilProfessorColors.title
                    : PerfilProfessorColors.muted,
                fontSize: 14.614,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    if (!enabled) return Opacity(opacity: 0.6, child: child);

    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: 'Adicionar idioma',
      onSelected: onSelected,
      itemBuilder: (context) {
        return items
            .map(
              (item) => PopupMenuItem<String>(
                value: item.idLanguage,
                child: Text(item.nome),
              ),
            )
            .toList(growable: false);
      },
      child: child,
    );
  }
}

class _AddDisciplinaMenuButton extends StatelessWidget {
  const _AddDisciplinaMenuButton({
    required this.enabled,
    required this.items,
    required this.onSelected,
    required this.config,
    this.isMobile = false,
  });

  final bool enabled;
  final List<DisciplinaDto> items;
  final ValueChanged<String> onSelected;
  final bool isMobile;
  final TeachingRoleConfig config;

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(PerfilProfessorLayout.inputRadius),
        border: Border.all(
          color: PerfilProfessorColors.cardBorder,
          width: PerfilProfessorLayout.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 18,
              color: enabled
                  ? PerfilProfessorColors.title
                  : PerfilProfessorColors.muted,
            ),
            const SizedBox(width: 6),
            Text(
              config.perfil.addSubjectButtonLabel,
              style: TextStyle(
                color: enabled
                    ? PerfilProfessorColors.title
                    : PerfilProfessorColors.muted,
                fontSize: 14.614,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    if (!enabled) return Opacity(opacity: 0.6, child: child);

    return PopupMenuButton<String>(
      enabled: enabled,
      tooltip: config.perfil.addSubjectButtonLabel,
      onSelected: onSelected,
      itemBuilder: (context) {
        return items
            .map(
              (d) => PopupMenuItem<String>(
                value: d.idDisciplina,
                child: Text(d.nome),
              ),
            )
            .toList(growable: false);
      },
      child: child,
    );
  }
}

class _DisciplinaChip extends StatelessWidget {
  const _DisciplinaChip({
    required this.label,
    required this.onRemove,
    required this.config,
    this.isMobile = false,
  });

  final String label;
  final VoidCallback onRemove;
  final TeachingRoleConfig config;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: config.primaryColor,
        borderRadius: BorderRadius.circular(PerfilProfessorLayout.badgeRadius),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isMobile ? 13 : PerfilProfessorLayout.badgeFontSize,
              fontWeight: FontWeight.w500,
              height:
                  PerfilProfessorLayout.badgeLineHeight /
                  (isMobile ? 13 : PerfilProfessorLayout.badgeFontSize),
              fontFamily: AppTypography.fontFamily,
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.item,
    required this.levels,
    required this.onRemove,
    required this.onLevelChanged,
    this.isMobile = false,
  });

  final ProfessorLanguageDto item;
  final List<String> levels;
  final VoidCallback onRemove;
  final ValueChanged<String> onLevelChanged;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final selectedLevel = levels.contains(item.proficiencyLevel)
        ? item.proficiencyLevel!
        : levels.first;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(PerfilProfessorLayout.badgeRadius),
        border: Border.all(color: PerfilProfessorColors.cardBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.nome,
            style: TextStyle(
              color: PerfilProfessorColors.title,
              fontSize: isMobile ? 13 : PerfilProfessorLayout.badgeFontSize,
              fontWeight: FontWeight.w500,
              fontFamily: AppTypography.fontFamily,
            ),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLevel,
              isDense: true,
              style: const TextStyle(
                color: PerfilProfessorColors.title,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              items: levels
                  .map(
                    (level) => DropdownMenuItem<String>(
                      value: level,
                      child: Text(level),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) return;
                onLevelChanged(value);
              },
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 16,
              color: PerfilProfessorColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.isMobile = false});

  final String text;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: PerfilProfessorColors.title,
        fontSize: isMobile
            ? PerfilProfessorLayout.mobileSectionTitleFontSize
            : PerfilProfessorLayout.sectionTitleFontSize,
        fontWeight: FontWeight.w500,
        height:
            (isMobile
                ? PerfilProfessorLayout.mobileSectionTitleLineHeight
                : PerfilProfessorLayout.sectionTitleLineHeight) /
            (isMobile
                ? PerfilProfessorLayout.mobileSectionTitleFontSize
                : PerfilProfessorLayout.sectionTitleFontSize),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.height,
    this.readOnly = false,
    this.keyboardType,
    this.isMobile = false,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final double? height;
  final bool readOnly;
  final TextInputType? keyboardType;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: PerfilProfessorColors.title,
          fontSize: isMobile
              ? PerfilProfessorLayout.mobileInputFontSize
              : PerfilProfessorLayout.inputFontSize,
          fontWeight: FontWeight.w400,
          height:
              (isMobile
                  ? PerfilProfessorLayout.mobileInputLineHeight
                  : PerfilProfessorLayout.inputLineHeight) /
              (isMobile
                  ? PerfilProfessorLayout.mobileInputFontSize
                  : PerfilProfessorLayout.inputFontSize),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(
            PerfilProfessorLayout.inputRadius,
          ),
        ),
        filled: true,
        fillColor: PerfilProfessorColors.inputFill,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 14 : 14.614,
          vertical: isMobile ? 12 : 10.961,
        ),
      ),
      style: TextStyle(
        color: PerfilProfessorColors.title,
        fontSize: isMobile
            ? PerfilProfessorLayout.mobileInputFontSize
            : PerfilProfessorLayout.inputFontSize,
        fontWeight: FontWeight.w400,
        height:
            (isMobile
                ? PerfilProfessorLayout.mobileInputLineHeight
                : PerfilProfessorLayout.inputLineHeight) /
            (isMobile
                ? PerfilProfessorLayout.mobileInputFontSize
                : PerfilProfessorLayout.inputFontSize),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF0A0A0A),
            fontSize: isMobile
                ? PerfilProfessorLayout.mobileLabelFontSize
                : PerfilProfessorLayout.labelFontSize,
            fontWeight: FontWeight.w500,
            height:
                (isMobile
                    ? PerfilProfessorLayout.mobileLabelLineHeight
                    : PerfilProfessorLayout.labelLineHeight) /
                (isMobile
                    ? PerfilProfessorLayout.mobileLabelFontSize
                    : PerfilProfessorLayout.labelFontSize),
          ),
        ),
        const SizedBox(height: 4.871),
        if (height == null)
          SizedBox(
            height: isMobile ? 48 : PerfilProfessorLayout.inputHeight,
            child: field,
          )
        else
          SizedBox(height: height, child: field),
      ],
    );
  }
}

class _CertificateDraft {
  const _CertificateDraft({
    required this.name,
    required this.description,
    this.fileBytes,
    this.fileName,
  });

  final String name;
  final String description;
  final List<int>? fileBytes;
  final String? fileName;
}