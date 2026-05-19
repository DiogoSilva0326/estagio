import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/data/session/jwt_utils.dart';
import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/professors/dtos/professor_certificate_dto.dart';
import 'package:aula_extra/core/data/professors/professors_api.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/core/data/users/dtos/user_profile_dto.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/features/become_teacher/assets/become_teacher_assets.dart';
import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BecomeTeacherCard extends StatefulWidget {
  const BecomeTeacherCard({
    super.key,
    required this.onLoginTap,
    this.width,
    this.compact = false,
  });

  final VoidCallback onLoginTap;
  final double? width;
  final bool compact;

  @override
  State<BecomeTeacherCard> createState() => _BecomeTeacherCardState();
}

class _CertificateControllers {
  _CertificateControllers()
    : name = TextEditingController(),
      url = TextEditingController();

  final TextEditingController name;
  final TextEditingController url;

  void dispose() {
    name.dispose();
    url.dispose();
  }
}

class _BecomeTeacherCardState extends State<BecomeTeacherCard> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  bool _didStartPrefill = false;

  final _usersService = UsersService();
  final _professorsService = ProfessorsService();
  final _tokenStorage = TokenStorage();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _usernameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _nifController = TextEditingController();
  final _currentSchoolController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  final _vatController = TextEditingController();
  final _ibanController = TextEditingController();
  final _ibanDocumentUrlController = TextEditingController();
  final _psychologistProofDocumentUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _presentationController = TextEditingController();

  bool _supportProfessor = true;
  bool _supportTutor = false;
  bool _supportPsychologist = false;
  Set<String> _lockedSupportTypes = <String>{};
  PlatformFile? _profilePhotoFile;
  PlatformFile? _ibanDocumentFile;
  PlatformFile? _psychologistProofFile;

  final List<_CertificateControllers> _certificates = [
    _CertificateControllers(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillKnownData();
    });
  }

  void _setIfEmpty(TextEditingController controller, String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) return;
    if (controller.text.trim().isNotEmpty) return;
    controller.text = normalized;
  }

  String? _deriveDisplayName(UserProfileDto me) {
    final displayName = me.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    return null;
  }

  void _syncProvider(UserProfileDto me) {
    final provider = context.read<UserProvider>();
    provider.setAccount(
      (provider.account ?? const UserAccount()).copyWith(
        fullName: _deriveDisplayName(me) ?? provider.account?.fullName,
        email: me.email?.trim(),
        username: me.username?.trim(),
        mobileNumber: (me.mobileNumber ?? me.phoneNumber)?.trim(),
        nif: me.nif?.trim(),
        profileImageUrl: me.profileImageUrl?.trim(),
      ),
    );
  }

  Future<void> _prefillKnownData() async {
    if (_didStartPrefill || !mounted) return;
    _didStartPrefill = true;

    final user = context.read<UserProvider>();
    final account = user.account;

    if (account != null) {
      _setIfEmpty(_fullNameController, account.fullName);
      _setIfEmpty(_emailController, account.email);
      _setIfEmpty(_usernameController, account.username);
      _setIfEmpty(_mobileController, account.mobileNumber);
      _setIfEmpty(_nifController, account.nif);
    }

    if (!user.isLoggedIn) {
      if (mounted) setState(() {});
      return;
    }

    try {
      final token = await _tokenStorage.loadToken();
      if (token != null && token.trim().isNotEmpty) {
        _applyLockedSupportTypes(JwtUtils.extractRoles(token));
      }
    } catch (_) {}

    try {
      final me = await _usersService.getMe();
      if (!mounted) return;

      _syncProvider(me);
      _setIfEmpty(_fullNameController, _deriveDisplayName(me));
      _setIfEmpty(_emailController, me.email);
      _setIfEmpty(_usernameController, me.username);
      _setIfEmpty(_mobileController, me.mobileNumber ?? me.phoneNumber);
      _setIfEmpty(_nifController, me.nif);
      _setIfEmpty(_presentationController, me.biography);
    } catch (_) {}

    try {
      final professor = await _professorsService.getMyProfessor();
      if (!mounted || professor == null) {
        if (mounted) setState(() {});
        return;
      }

      _setIfEmpty(_currentSchoolController, professor.currentSchool);
      _setIfEmpty(
        _yearsExperienceController,
        professor.yearsExperience?.toString(),
      );
      _setIfEmpty(_vatController, professor.vat);
      _setIfEmpty(_ibanController, professor.iban);
      _setIfEmpty(_ibanDocumentUrlController, professor.ibanDocumentUrl);
      _setIfEmpty(_videoUrlController, professor.presentationVideoUrl);
      _setIfEmpty(_presentationController, professor.biography);
      _applyLockedSupportTypes(professor.supportTypes);
    } catch (_) {}

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _usernameController.dispose();
    _mobileController.dispose();
    _nifController.dispose();
    _currentSchoolController.dispose();
    _yearsExperienceController.dispose();
    _vatController.dispose();
    _ibanController.dispose();
    _ibanDocumentUrlController.dispose();
    _psychologistProofDocumentUrlController.dispose();
    _videoUrlController.dispose();
    _presentationController.dispose();
    for (final c in _certificates) {
      c.dispose();
    }
    super.dispose();
  }

  bool _looksLikeUrl(String v) {
    final s = v.trim();
    if (s.isEmpty) return true;

    final uri = Uri.tryParse(s);
    if (uri == null) return false;

    if (uri.hasScheme) {
      return uri.scheme == 'http' || uri.scheme == 'https';
    }

    // Allow common inputs without scheme (e.g. www.example.com).
    return s.contains('.') && !s.contains(' ');
  }

  String _normalizeSupportType(String value) => value.trim().toLowerCase();

  bool _isSupportTypeLocked(String supportType) {
    return _lockedSupportTypes.contains(_normalizeSupportType(supportType));
  }

  void _applyLockedSupportTypes(Iterable<String> supportTypes) {
    _lockedSupportTypes = <String>{
      ..._lockedSupportTypes,
      ...supportTypes
          .map(_normalizeSupportType)
          .where((item) => item.isNotEmpty),
    };

    if (_isSupportTypeLocked('professor')) {
      _supportProfessor = false;
    }
    if (_isSupportTypeLocked('tutor')) {
      _supportTutor = false;
    }
    if (_isSupportTypeLocked('psicologo')) {
      _supportPsychologist = false;
    }
  }

  String get _lockedSupportTypesMessage {
    final labels = <String>[
      if (_isSupportTypeLocked('professor')) 'Professor',
      if (_isSupportTypeLocked('tutor')) 'Tutor',
      if (_isSupportTypeLocked('psicologo')) 'Psicólogo',
    ];

    if (labels.isEmpty) return '';
    return 'Já tens ou já pediste: ${labels.join(', ')}. Só podes candidatar-te aos tipos de apoio restantes.';
  }

  bool get _hasAtLeastOneCertificate {
    return _certificates.any(
      (c) => c.name.text.trim().isNotEmpty || c.url.text.trim().isNotEmpty,
    );
  }

  bool get _canSubmit {
    final user = context.read<UserProvider>();
    if (!user.isLoggedIn) return false;

    if (_usernameController.text.trim().isEmpty) return false;
    if (_mobileController.text.trim().isEmpty) return false;
    if (_nifController.text.trim().isEmpty) return false;
    if (_presentationController.text.trim().isEmpty) return false;
    if (_profilePhotoFile?.bytes == null || _profilePhotoFile!.bytes!.isEmpty) {
      return false;
    }
    if (!_supportProfessor && !_supportTutor && !_supportPsychologist) {
      return false;
    }
    if ((_supportProfessor && _isSupportTypeLocked('professor')) ||
        (_supportTutor && _isSupportTypeLocked('tutor')) ||
        (_supportPsychologist && _isSupportTypeLocked('psicologo'))) {
      return false;
    }

    final psychologistProofUrl =
      _psychologistProofDocumentUrlController.text.trim();
    final hasPsychologistProofFile = _psychologistProofFile?.bytes != null;
    if (_supportPsychologist &&
      psychologistProofUrl.isEmpty &&
      !hasPsychologistProofFile) {
      return false;
    }

    final ye = _yearsExperienceController.text.trim();
    if (ye.isNotEmpty && int.tryParse(ye) == null) return false;

    // Optional URLs, but if provided should look like a URL.
    if (!_looksLikeUrl(_videoUrlController.text)) return false;
    if (_ibanDocumentUrlController.text.trim().isNotEmpty &&
        !_looksLikeUrl(_ibanDocumentUrlController.text)) {
      return false;
    }
    if (psychologistProofUrl.isNotEmpty &&
        !_looksLikeUrl(_psychologistProofDocumentUrlController.text)) {
      return false;
    }
    for (final c in _certificates) {
      if ((c.url.text.trim().isNotEmpty) && !_looksLikeUrl(c.url.text)) {
        return false;
      }
    }

    // Certificates are optional, but support multiple.
    if (!_hasAtLeastOneCertificate) {
      return true;
    }

    // If user added certificate fields, require both name+url per filled row.
    for (final c in _certificates) {
      final name = c.name.text.trim();
      final url = c.url.text.trim();
      if (name.isEmpty && url.isEmpty) continue;
      if (name.isEmpty || url.isEmpty) return false;
    }

    return true;
  }

  Future<void> _pickPsychologistProofFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (!mounted) return;

    if (result == null || result.files.isEmpty) return;
    setState(() {
      _psychologistProofFile = result.files.single;
    });
  }

  Future<void> _pickProfilePhotoFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (!mounted) return;

    if (result == null || result.files.isEmpty) return;
    setState(() {
      _profilePhotoFile = result.files.single;
    });
  }

  Future<void> _pickIbanDocumentFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (!mounted) return;

    if (result == null || result.files.isEmpty) return;
    setState(() {
      _ibanDocumentFile = result.files.single;
    });
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    if (_isSubmitting) return;

    final user = context.read<UserProvider>();
    if (!user.isLoggedIn) {
      widget.onLoginTap();
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      if (_profilePhotoFile == null || _profilePhotoFile!.bytes == null) {
        throw Exception('A foto de perfil deve ser submetida como ficheiro.');
      }

      final yearsExperienceRaw = _yearsExperienceController.text.trim();
      final yearsExperience = yearsExperienceRaw.isEmpty
          ? null
          : int.tryParse(yearsExperienceRaw);

      final certificates = <UpsertProfessorCertificateInput>[];
      for (final c in _certificates) {
        final name = c.name.text.trim();
        final url = c.url.text.trim();
        if (name.isEmpty || url.isEmpty) continue;
        certificates.add(
          UpsertProfessorCertificateInput(name: name, fileUrl: url),
        );
      }

      final psychologistProofUrl = _psychologistProofDocumentUrlController.text
          .trim();
      final hasPsychologistProofFile = _psychologistProofFile?.bytes != null;

      if (_supportPsychologist &&
          psychologistProofUrl.isNotEmpty &&
          !hasPsychologistProofFile) {
        certificates.add(
          UpsertProfessorCertificateInput(
            name: 'Comprovativo Psicólogo',
            description: 'Documento para candidatura a psicólogo.',
            fileUrl: psychologistProofUrl,
          ),
        );
      }

      final service = ProfessorsService();
      final uploadedProfile = await _usersService.uploadMyProfileImage(
        bytes: _profilePhotoFile!.bytes!,
        fileName: _profilePhotoFile!.name,
      );

      var ibanDocumentUrlForUpsert = _ibanDocumentUrlController.text;
      final supportTypes = <String>[
        if (_supportProfessor) 'professor',
        if (_supportTutor) 'tutor',
        if (_supportPsychologist) 'psicologo',
      ];
      final session = await service.upsertMyProfessor(
        username: _usernameController.text,
        mobileNumber: _mobileController.text,
        nif: _nifController.text,
        supportTypes: supportTypes,
        currentSchool: _currentSchoolController.text,
        yearsExperience: yearsExperience,
        presentationVideoUrl: _videoUrlController.text,
        photo: uploadedProfile.profileImageUrl,
        biography: _presentationController.text,
        vat: _vatController.text,
        iban: _ibanController.text,
        ibanDocumentUrl: ibanDocumentUrlForUpsert,
        certificates: certificates.isEmpty ? null : certificates,
      );

      if (_ibanDocumentFile?.bytes != null && _ibanDocumentFile!.bytes!.isNotEmpty) {
        final existingCertificates = await service.getMyCertificates();
        ProfessorCertificateDto? existingIbanCertificate;
        for (final item in existingCertificates) {
          final name = (item.name ?? '').toLowerCase();
          final description = (item.description ?? '').toLowerCase();
          final isIbanDoc = name.contains('iban') ||
              description.contains('iban') ||
              description.contains('faturação');
          if (isIbanDoc) {
            existingIbanCertificate = item;
            break;
          }
        }

        ProfessorCertificateDto ibanCertificate;
        if (existingIbanCertificate == null) {
          ibanCertificate = await service.createMyCertificate(
            name: 'Documento IBAN',
            description: 'Comprovativo IBAN para pagamentos.',
            bytes: _ibanDocumentFile!.bytes!,
            fileName: _ibanDocumentFile!.name,
          );
        } else {
          ibanCertificate = await service.updateMyCertificate(
            idCertificate: existingIbanCertificate.idCertificate,
            name: 'Documento IBAN',
            description: 'Comprovativo IBAN para pagamentos.',
            fileUrl: existingIbanCertificate.fileUrl,
            bytes: _ibanDocumentFile!.bytes,
            fileName: _ibanDocumentFile!.name,
          );
        }

        if ((ibanCertificate.fileUrl ?? '').trim().isNotEmpty) {
          ibanDocumentUrlForUpsert = ibanCertificate.fileUrl!.trim();
          await service.upsertMyProfessor(
            username: _usernameController.text,
            mobileNumber: _mobileController.text,
            nif: _nifController.text,
            supportTypes: supportTypes,
            currentSchool: _currentSchoolController.text,
            yearsExperience: yearsExperience,
            presentationVideoUrl: _videoUrlController.text,
            photo: uploadedProfile.profileImageUrl,
            biography: _presentationController.text,
            vat: _vatController.text,
            iban: _ibanController.text,
            ibanDocumentUrl: ibanDocumentUrlForUpsert,
            certificates: certificates.isEmpty ? null : certificates,
          );
        }
      }

      if (_supportPsychologist && hasPsychologistProofFile) {
        final selectedFile = _psychologistProofFile!;
        final bytes = selectedFile.bytes;
        if (bytes == null || bytes.isEmpty) {
          throw Exception(
            'Não foi possível ler o ficheiro do comprovativo de psicólogo.',
          );
        }

        final existingCertificates = await service.getMyCertificates();
        ProfessorCertificateDto? existingPsychologistCertificate;
        for (final item in existingCertificates) {
          final name = (item.name ?? '').toLowerCase();
          final description = (item.description ?? '').toLowerCase();
          final isPsychologistProof = name.contains('psicolog') ||
              name.contains('cedula') ||
              description.contains('psicolog') ||
              description.contains('ordem dos psicologos') ||
              description.contains('ordem dos psicólogos');
          if (isPsychologistProof) {
            existingPsychologistCertificate = item;
            break;
          }
        }

        if (existingPsychologistCertificate == null) {
          await service.createMyCertificate(
            name: 'Comprovativo Psicólogo',
            description: 'Documento para candidatura a psicólogo.',
            bytes: bytes,
            fileName: selectedFile.name,
          );
        } else {
          await service.updateMyCertificate(
            idCertificate: existingPsychologistCertificate.idCertificate,
            name: 'Comprovativo Psicólogo',
            description: 'Documento para candidatura a psicólogo.',
            fileUrl: existingPsychologistCertificate.fileUrl,
            bytes: bytes,
            fileName: selectedFile.name,
          );
        }
      }

      AuthService.applySessionToProvider(user, session);

      final isTeacher = session.appRole == Role.teacher;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isTeacher
                ? 'Perfil de apoio atualizado.'
                : 'Candidatura submetida. Aguarda validação no backoffice.',
          ),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        isTeacher ? Routes.professorMeusAlunos : Routes.perfilAluno,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: widget.compact
          ? const EdgeInsets.only(top: 14)
          : BecomeTeacherLayout.sectionTitlePadding,
      child: Text(
        text,
        style: TextStyle(
          fontSize: widget.compact
              ? 13
              : BecomeTeacherLayout.sectionTitleFontSize,
          fontWeight: FontWeight.w700,
          color: RegisterColors.textPrimary,
        ),
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required Widget prefix,
    Widget? suffix,
    TextInputType? keyboardType,
    bool obscureText = false,
    bool enabled = true,
    int maxLines = 1,
  }) {
    final field = TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: BecomeTeacherLayout.subtitleFontSize,
          fontWeight: FontWeight.w400,
          color: BecomeTeacherColors.hintText,
          letterSpacing: BecomeTeacherLayout.subtitleLetterSpacing,
        ),
        prefixIcon: Padding(
          padding: BecomeTeacherLayout.prefixPadding,
          child: prefix,
        ),
        prefixIconConstraints: BecomeTeacherLayout.prefixConstraints,
        suffixIcon: suffix,
        contentPadding: BecomeTeacherLayout.inputContentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BecomeTeacherLayout.inputRadius),
          borderSide: const BorderSide(
            color: RegisterColors.stroke,
            width: BecomeTeacherLayout.inputBorderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BecomeTeacherLayout.inputRadius),
          borderSide: const BorderSide(
            color: RegisterColors.stroke,
            width: BecomeTeacherLayout.inputBorderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BecomeTeacherLayout.inputRadius),
          borderSide: const BorderSide(
            color: RegisterColors.stroke,
            width: BecomeTeacherLayout.inputBorderWidth,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BecomeTeacherLayout.inputRadius),
          borderSide: const BorderSide(
            color: RegisterColors.stroke,
            width: BecomeTeacherLayout.inputBorderWidth,
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: BecomeTeacherLayout.fieldLabelFontSize,
            fontWeight: FontWeight.w700,
            color: BecomeTeacherColors.fieldLabel,
            height:
                BecomeTeacherLayout.fieldLabelLineHeight /
                BecomeTeacherLayout.fieldLabelFontSize,
            letterSpacing: BecomeTeacherLayout.fieldLabelLetterSpacing,
          ),
        ),
        const SizedBox(height: BecomeTeacherLayout.labelFieldGap),
        maxLines == 1
            ? SizedBox(height: BecomeTeacherLayout.inputHeight, child: field)
            : field,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final hasKnownAccount =
        user.account != null && (user.account!.email ?? '').trim().isNotEmpty;
    final isLoggedIn = user.isLoggedIn;
    final lockAccountFields = isLoggedIn && hasKnownAccount;

    final enabled = _canSubmit && !_isSubmitting;
    final cardWidth = widget.width ?? BecomeTeacherLayout.cardWidth;
    final cardPadding = widget.compact
        ? const EdgeInsets.fromLTRB(18, 20, 18, 18)
        : BecomeTeacherLayout.contentPadding;
    final tabsHeight = widget.compact ? 46.0 : BecomeTeacherLayout.tabsHeight;
    final tabFontSize = widget.compact ? 12.5 : BecomeTeacherLayout.tabFontSize;
    final titleFontSize = widget.compact
        ? 22.0
        : BecomeTeacherLayout.formTitleFontSize;
    final titleLineHeight = widget.compact
        ? 27.0
        : BecomeTeacherLayout.formTitleLineHeight;
    final subtitleFontSize = widget.compact
        ? 13.0
        : BecomeTeacherLayout.subtitleFontSize;
    final subtitleLineHeight = widget.compact
        ? 19.0
        : BecomeTeacherLayout.subtitleLineHeight;
    final submitHeight = widget.compact
        ? 48.0
        : BecomeTeacherLayout.submitHeight;

    return Container(
      width: cardWidth,
      // Taller than RegisterCard; page scroll handles overflow.
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BecomeTeacherLayout.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: BecomeTeacherLayout.cardShadowBlur,
            spreadRadius: BecomeTeacherLayout.cardShadowSpread,
            offset: Offset(0, BecomeTeacherLayout.cardShadowOffsetY),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: tabsHeight,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.onLoginTap,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: BecomeTeacherColors.inactiveTabBackground,
                        border: Border(
                          bottom: BorderSide(
                            width: BecomeTeacherLayout.tabsBottomBorderWidth,
                            color: BecomeTeacherColors.tabsDivider,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                            BecomeTeacherLayout.tabsCornerRadius,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: tabFontSize,
                              fontWeight: FontWeight.w700,
                              color: RegisterColors.textSecondary,
                              height:
                                  BecomeTeacherLayout.tabLineHeight /
                                  tabFontSize,
                              letterSpacing:
                                  BecomeTeacherLayout.tabLetterSpacing,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          RegisterColors.gradientStart,
                          RegisterColors.gradientEnd,
                        ],
                      ),
                      border: Border(
                        bottom: BorderSide(
                          width: BecomeTeacherLayout.tabsBottomBorderWidth,
                          color: BecomeTeacherColors.tabsDivider,
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(
                          BecomeTeacherLayout.tabsCornerRadius,
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Tornar-se Apoio',
                          style: TextStyle(
                            fontSize: tabFontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height:
                                BecomeTeacherLayout.tabLineHeight / tabFontSize,
                            letterSpacing: BecomeTeacherLayout.tabLetterSpacing,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Candidata-te a apoio',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w700,
                    color: RegisterColors.textPrimary,
                    height: titleLineHeight / titleFontSize,
                    letterSpacing: BecomeTeacherLayout.formTitleLetterSpacing,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.titleSubtitleGap),
                Text(
                  lockAccountFields
                      ? 'Já tens conta — dados preenchidos.'
                      : 'Se ainda não tens conta, cria-a aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w400,
                    color: RegisterColors.textSecondary,
                    height: subtitleLineHeight / subtitleFontSize,
                    letterSpacing: BecomeTeacherLayout.subtitleLetterSpacing,
                  ),
                ),

                _sectionTitle('Dados da conta'),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Nome Completo',
                  hintText: 'O teu nome completo',
                  controller: _fullNameController,
                  enabled: !lockAccountFields,
                  prefix: const Icon(
                    Icons.person_outline,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Email',
                  hintText: 'o-teu-email@exemplo.com',
                  controller: _emailController,
                  enabled: !lockAccountFields,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(
                    Icons.email_outlined,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                if (!lockAccountFields) ...[
                  const SizedBox(height: BecomeTeacherLayout.fieldGap),
                  _labeledField(
                    label: 'Password',
                    hintText: 'Mínimo 6 caracteres',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefix: const Icon(
                      Icons.lock_outline,
                      size: BecomeTeacherLayout.inputIconSize,
                      color: BecomeTeacherColors.inputIconMuted,
                    ),
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: BecomeTeacherLayout.inputIconSize,
                        color: BecomeTeacherColors.inputIconMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints:
                          BecomeTeacherLayout.passwordSuffixConstraints,
                    ),
                  ),
                  const SizedBox(height: BecomeTeacherLayout.fieldGap),
                  _labeledField(
                    label: 'Confirmar Password',
                    hintText: 'Repete a password',
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    prefix: const Icon(
                      Icons.lock_outline,
                      size: BecomeTeacherLayout.inputIconSize,
                      color: BecomeTeacherColors.inputIconMuted,
                    ),
                    suffix: IconButton(
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: BecomeTeacherLayout.inputIconSize,
                        color: BecomeTeacherColors.inputIconMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints:
                          BecomeTeacherLayout.passwordSuffixConstraints,
                    ),
                  ),
                ],

                _sectionTitle('Dados da candidatura'),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                Text(
                  'Tipo(s) de apoio pretendido(s)',
                  style: const TextStyle(
                    fontSize: BecomeTeacherLayout.fieldLabelFontSize,
                    fontWeight: FontWeight.w700,
                    color: BecomeTeacherColors.fieldLabel,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Professor'),
                      selected: _supportProfessor,
                      onSelected: _isSupportTypeLocked('professor')
                          ? null
                          : (value) =>
                                setState(() => _supportProfessor = value),
                    ),
                    FilterChip(
                      label: const Text('Tutor'),
                      selected: _supportTutor,
                      onSelected: _isSupportTypeLocked('tutor')
                          ? null
                          : (value) =>
                                setState(() => _supportTutor = value),
                    ),
                    FilterChip(
                      label: const Text('Psicólogo'),
                      selected: _supportPsychologist,
                      onSelected: _isSupportTypeLocked('psicologo')
                          ? null
                          : (value) =>
                                setState(() => _supportPsychologist = value),
                    ),
                  ],
                ),
                if (_lockedSupportTypes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _lockedSupportTypesMessage,
                    style: const TextStyle(
                      fontSize: 12,
                      color: RegisterColors.textSecondary,
                    ),
                  ),
                ],
                if (_supportPsychologist) ...[
                  const SizedBox(height: BecomeTeacherLayout.fieldGap),
                  _labeledField(
                    label: 'Comprovativo de Psicologia por link (opcional)',
                    hintText: 'https://…',
                    controller: _psychologistProofDocumentUrlController,
                    keyboardType: TextInputType.url,
                    prefix: const Icon(
                      Icons.verified_outlined,
                      size: BecomeTeacherLayout.inputIconSize,
                      color: BecomeTeacherColors.inputIconMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _pickPsychologistProofFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _psychologistProofFile == null
                          ? 'Anexar ficheiro comprovativo'
                          : 'Ficheiro anexado: ${_psychologistProofFile!.name}',
                    ),
                  ),
                  if (_psychologistProofFile != null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _psychologistProofFile = null;
                        });
                      },
                      child: const Text('Remover ficheiro anexado'),
                    ),
                  const SizedBox(height: 4),
                  const Text(
                    'Submete pelo menos uma opção: link ou ficheiro anexado. A role de psicólogo só é atribuída após aprovação no backoffice.',
                    style: TextStyle(
                      fontSize: 12,
                      color: RegisterColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Username',
                  hintText: 'O teu username',
                  controller: _usernameController,
                  prefix: const Icon(
                    Icons.alternate_email,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Número de telemóvel',
                  hintText: 'Ex: 912345678',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  prefix: const Icon(
                    Icons.phone_iphone,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'NIF',
                  hintText: 'Ex: 123456789',
                  controller: _nifController,
                  keyboardType: TextInputType.number,
                  prefix: const Icon(
                    Icons.badge_outlined,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Escola atual',
                  hintText: 'Ex: Escola Secundária …',
                  controller: _currentSchoolController,
                  prefix: const Icon(
                    Icons.school_outlined,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Anos de experiência',
                  hintText: 'Ex: 3',
                  controller: _yearsExperienceController,
                  keyboardType: TextInputType.number,
                  prefix: const Icon(
                    Icons.timeline_outlined,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'NIF (faturação)',
                  hintText: 'Ex: 123456789',
                  controller: _vatController,
                  keyboardType: TextInputType.number,
                  prefix: const Icon(
                    Icons.receipt_long_outlined,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'IBAN',
                  hintText: 'Ex: PT50…',
                  controller: _ibanController,
                  prefix: const Icon(
                    Icons.account_balance_outlined,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Documento do IBAN (link)',
                  hintText: 'https://…',
                  controller: _ibanDocumentUrlController,
                  keyboardType: TextInputType.url,
                  prefix: const Icon(
                    Icons.link,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _pickIbanDocumentFile,
                  icon: const Icon(Icons.attach_file),
                  label: Text(
                    _ibanDocumentFile == null
                        ? 'Anexar ficheiro IBAN (opcional)'
                        : 'Ficheiro IBAN anexado: ${_ibanDocumentFile!.name}',
                  ),
                ),
                if (_ibanDocumentFile != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _ibanDocumentFile = null;
                      });
                    },
                    child: const Text('Remover ficheiro IBAN anexado'),
                  ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Vídeo de apresentação (link)',
                  hintText: 'https://…',
                  controller: _videoUrlController,
                  keyboardType: TextInputType.url,
                  prefix: const Icon(
                    Icons.ondemand_video_outlined,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                Text(
                  'Foto de perfil (ficheiro obrigatório)',
                  style: const TextStyle(
                    fontSize: BecomeTeacherLayout.fieldLabelFontSize,
                    fontWeight: FontWeight.w700,
                    color: BecomeTeacherColors.fieldLabel,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.labelFieldGap),
                OutlinedButton.icon(
                  onPressed: _pickProfilePhotoFile,
                  icon: const Icon(Icons.image_outlined),
                  label: Text(
                    _profilePhotoFile == null
                        ? 'Selecionar foto de perfil'
                        : 'Foto selecionada: ${_profilePhotoFile!.name}',
                  ),
                ),
                if (_profilePhotoFile != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _profilePhotoFile = null;
                      });
                    },
                    child: const Text('Remover foto selecionada'),
                  ),

                _sectionTitle('Certificados'),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                ...List.generate(_certificates.length, (i) {
                  final c = _certificates[i];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i == _certificates.length - 1
                          ? 0
                          : BecomeTeacherLayout.fieldGap,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _labeledField(
                                label: i == 0 ? 'Nome do certificado' : 'Nome',
                                hintText: 'Ex: Certificado X',
                                controller: c.name,
                                prefix: const Icon(
                                  Icons.description_outlined,
                                  size: BecomeTeacherLayout.inputIconSize,
                                  color: BecomeTeacherColors.inputIconMuted,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width:
                                  BecomeTeacherLayout.certificateNameRemoveGap,
                            ),
                            if (_certificates.length > 1)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    final removed = _certificates.removeAt(i);
                                    removed.dispose();
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: BecomeTeacherColors.removeIcon,
                                ),
                                tooltip: 'Remover',
                              ),
                          ],
                        ),
                        const SizedBox(
                          height: BecomeTeacherLayout.certificateNameLinkGap,
                        ),
                        _labeledField(
                          label: i == 0 ? 'Link do certificado' : 'Link',
                          hintText: 'https://…',
                          controller: c.url,
                          keyboardType: TextInputType.url,
                          prefix: const Icon(
                            Icons.link,
                            size: BecomeTeacherLayout.inputIconSize,
                            color: BecomeTeacherColors.inputIconMuted,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(
                      () => _certificates.add(_CertificateControllers()),
                    ),
                    child: const Text('Adicionar certificado'),
                  ),
                ),

                _sectionTitle('Texto de apresentação'),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Apresentação',
                  hintText: 'Fala um pouco sobre ti…',
                  controller: _presentationController,
                  prefix: const Icon(
                    Icons.edit_outlined,
                    size: BecomeTeacherLayout.inputIconSize,
                    color: BecomeTeacherColors.inputIconMuted,
                  ),
                  maxLines: 4,
                ),

                const SizedBox(height: BecomeTeacherLayout.beforeSubmitGap),
                InkWell(
                  onTap: enabled ? _submit : null,
                  borderRadius: BorderRadius.circular(
                    BecomeTeacherLayout.submitRadius,
                  ),
                  child: Container(
                    height: submitHeight,
                    decoration: BoxDecoration(
                      color: enabled
                          ? null
                          : BecomeTeacherColors.submitDisabledBackground,
                      gradient: enabled
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                RegisterColors.gradientStart,
                                RegisterColors.gradientEnd,
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(
                        BecomeTeacherLayout.submitRadius,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Submeter candidatura',
                      style: TextStyle(
                        fontSize: BecomeTeacherLayout.submitFontSize,
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? Colors.white
                            : BecomeTeacherColors.submitDisabledText,
                        height:
                            BecomeTeacherLayout.submitLineHeight /
                            BecomeTeacherLayout.submitFontSize,
                        letterSpacing: BecomeTeacherLayout.submitLetterSpacing,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
