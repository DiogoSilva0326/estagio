import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/data/professors/professors_api.dart';
import 'package:aula_extra/core/data/professors/professors_service.dart';
import 'package:aula_extra/features/become_teacher/constants/become_teacher_constants.dart';
import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BecomeTeacherCard extends StatefulWidget {
  const BecomeTeacherCard({
    super.key,
    required this.onLoginTap,
  });

  final VoidCallback onLoginTap;

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
  final _videoUrlController = TextEditingController();
  final _bioImageUrlController = TextEditingController();
  final _presentationController = TextEditingController();

  final List<_CertificateControllers> _certificates = [_CertificateControllers()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>();
      final account = user.account;

      if (account != null) {
        if ((account.fullName ?? '').trim().isNotEmpty) {
          _fullNameController.text = account.fullName!.trim();
        }
        if ((account.email ?? '').trim().isNotEmpty) {
          _emailController.text = account.email!.trim();
        }
        if ((account.username ?? '').trim().isNotEmpty) {
          _usernameController.text = account.username!.trim();
        }
        if ((account.mobileNumber ?? '').trim().isNotEmpty) {
          _mobileController.text = account.mobileNumber!.trim();
        }
        if ((account.nif ?? '').trim().isNotEmpty) {
          _nifController.text = account.nif!.trim();
        }
      }

      setState(() {});
    });
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
    _videoUrlController.dispose();
    _bioImageUrlController.dispose();
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

  bool get _hasAtLeastOneCertificate {
    return _certificates.any((c) => c.name.text.trim().isNotEmpty || c.url.text.trim().isNotEmpty);
  }

  bool get _canSubmit {
    final user = context.read<UserProvider>();
    if (!user.isLoggedIn) return false;

    if (_usernameController.text.trim().isEmpty) return false;
    if (_mobileController.text.trim().isEmpty) return false;
    if (_nifController.text.trim().isEmpty) return false;
    if (_presentationController.text.trim().isEmpty) return false;

    final ye = _yearsExperienceController.text.trim();
    if (ye.isNotEmpty && int.tryParse(ye) == null) return false;

    // Optional URLs, but if provided should look like a URL.
    if (!_looksLikeUrl(_videoUrlController.text)) return false;
    if (!_looksLikeUrl(_bioImageUrlController.text)) return false;
    if (!_looksLikeUrl(_ibanDocumentUrlController.text)) return false;
    for (final c in _certificates) {
      if ((c.url.text.trim().isNotEmpty) && !_looksLikeUrl(c.url.text)) return false;
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
      final yearsExperienceRaw = _yearsExperienceController.text.trim();
      final yearsExperience = yearsExperienceRaw.isEmpty ? null : int.tryParse(yearsExperienceRaw);

      final certificates = <UpsertProfessorCertificateInput>[];
      for (final c in _certificates) {
        final name = c.name.text.trim();
        final url = c.url.text.trim();
        if (name.isEmpty || url.isEmpty) continue;
        certificates.add(UpsertProfessorCertificateInput(name: name, fileUrl: url));
      }

      final service = ProfessorsService();
      final session = await service.upsertMyProfessor(
        username: _usernameController.text,
        mobileNumber: _mobileController.text,
        nif: _nifController.text,
        currentSchool: _currentSchoolController.text,
        yearsExperience: yearsExperience,
        presentationVideoUrl: _videoUrlController.text,
        photo: _bioImageUrlController.text,
        biography: _presentationController.text,
        vat: _vatController.text,
        iban: _ibanController.text,
        ibanDocumentUrl: _ibanDocumentUrlController.text,
        certificates: certificates.isEmpty ? null : certificates,
      );

      AuthService.applySessionToProvider(user, session);

      final isTeacher = session.appRole == Role.teacher;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isTeacher
                ? 'Perfil de professor atualizado.'
                : 'Candidatura submetida. Aguarda aprovação do administrador.',
          ),
        ),
      );

      Navigator.pushReplacementNamed(
        context,
        isTeacher ? Routes.professorPerfil : Routes.perfilAluno,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: BecomeTeacherLayout.sectionTitlePadding,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: BecomeTeacherLayout.sectionTitleFontSize,
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
          borderSide: const BorderSide(color: RegisterColors.stroke, width: BecomeTeacherLayout.inputBorderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BecomeTeacherLayout.inputRadius),
          borderSide: const BorderSide(color: RegisterColors.stroke, width: BecomeTeacherLayout.inputBorderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BecomeTeacherLayout.inputRadius),
          borderSide: const BorderSide(color: RegisterColors.stroke, width: BecomeTeacherLayout.inputBorderWidth),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(BecomeTeacherLayout.inputRadius),
          borderSide: const BorderSide(color: RegisterColors.stroke, width: BecomeTeacherLayout.inputBorderWidth),
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
            height: BecomeTeacherLayout.fieldLabelLineHeight / BecomeTeacherLayout.fieldLabelFontSize,
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
    final hasKnownAccount = user.account != null && (user.account!.email ?? '').trim().isNotEmpty;
    final isLoggedIn = user.isLoggedIn;
    final lockAccountFields = isLoggedIn && hasKnownAccount;

    final enabled = _canSubmit && !_isSubmitting;

    return Container(
      width: BecomeTeacherLayout.cardWidth,
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
            height: BecomeTeacherLayout.tabsHeight,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.onLoginTap,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: BecomeTeacherColors.inactiveTabBackground,
                        border: Border(
                          bottom: BorderSide(width: BecomeTeacherLayout.tabsBottomBorderWidth, color: BecomeTeacherColors.tabsDivider),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(BecomeTeacherLayout.tabsCornerRadius),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: BecomeTeacherLayout.tabFontSize,
                          fontWeight: FontWeight.w700,
                          color: RegisterColors.textSecondary,
                          height: BecomeTeacherLayout.tabLineHeight / BecomeTeacherLayout.tabFontSize,
                          letterSpacing: BecomeTeacherLayout.tabLetterSpacing,
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
                        colors: [RegisterColors.gradientStart, RegisterColors.gradientEnd],
                      ),
                      border: Border(
                        bottom: BorderSide(width: BecomeTeacherLayout.tabsBottomBorderWidth, color: BecomeTeacherColors.tabsDivider),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(BecomeTeacherLayout.tabsCornerRadius),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Tornar-se Explicador',
                      style: TextStyle(
                        fontSize: BecomeTeacherLayout.tabFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: BecomeTeacherLayout.tabLineHeight / BecomeTeacherLayout.tabFontSize,
                        letterSpacing: BecomeTeacherLayout.tabLetterSpacing,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: BecomeTeacherLayout.contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Candidata-te a explicador',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: BecomeTeacherLayout.formTitleFontSize,
                    fontWeight: FontWeight.w700,
                    color: RegisterColors.textPrimary,
                    height: BecomeTeacherLayout.formTitleLineHeight / BecomeTeacherLayout.formTitleFontSize,
                    letterSpacing: BecomeTeacherLayout.formTitleLetterSpacing,
                  ),
                ),
                const SizedBox(height: BecomeTeacherLayout.titleSubtitleGap),
                Text(
                  lockAccountFields ? 'Já tens conta — dados preenchidos.' : 'Se ainda não tens conta, cria-a aqui.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: BecomeTeacherLayout.subtitleFontSize,
                    fontWeight: FontWeight.w400,
                    color: RegisterColors.textSecondary,
                    height: BecomeTeacherLayout.subtitleLineHeight / BecomeTeacherLayout.subtitleFontSize,
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
                  prefix: const Icon(Icons.person_outline, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Email',
                  hintText: 'o-teu-email@exemplo.com',
                  controller: _emailController,
                  enabled: !lockAccountFields,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.email_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                if (!lockAccountFields) ...[
                  const SizedBox(height: BecomeTeacherLayout.fieldGap),
                  _labeledField(
                    label: 'Password',
                    hintText: 'Mínimo 6 caracteres',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefix: const Icon(Icons.lock_outline, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                    suffix: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: BecomeTeacherLayout.inputIconSize,
                        color: BecomeTeacherColors.inputIconMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BecomeTeacherLayout.passwordSuffixConstraints,
                    ),
                  ),
                  const SizedBox(height: BecomeTeacherLayout.fieldGap),
                  _labeledField(
                    label: 'Confirmar Password',
                    hintText: 'Repete a password',
                    controller: _confirmController,
                    obscureText: _obscureConfirm,
                    prefix: const Icon(Icons.lock_outline, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                    suffix: IconButton(
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: BecomeTeacherLayout.inputIconSize,
                        color: BecomeTeacherColors.inputIconMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BecomeTeacherLayout.passwordSuffixConstraints,
                    ),
                  ),
                ],

                _sectionTitle('Dados da candidatura'),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Username',
                  hintText: 'O teu username',
                  controller: _usernameController,
                  prefix: const Icon(Icons.alternate_email, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Número de telemóvel',
                  hintText: 'Ex: 912345678',
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  prefix: const Icon(Icons.phone_iphone, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'NIF',
                  hintText: 'Ex: 123456789',
                  controller: _nifController,
                  keyboardType: TextInputType.number,
                  prefix: const Icon(Icons.badge_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Escola atual',
                  hintText: 'Ex: Escola Secundária …',
                  controller: _currentSchoolController,
                  prefix: const Icon(Icons.school_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Anos de experiência',
                  hintText: 'Ex: 3',
                  controller: _yearsExperienceController,
                  keyboardType: TextInputType.number,
                  prefix: const Icon(Icons.timeline_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'NIF (faturação)',
                  hintText: 'Ex: 123456789',
                  controller: _vatController,
                  keyboardType: TextInputType.number,
                  prefix: const Icon(Icons.receipt_long_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'IBAN',
                  hintText: 'Ex: PT50…',
                  controller: _ibanController,
                  prefix: const Icon(Icons.account_balance_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Documento do IBAN (link)',
                  hintText: 'https://…',
                  controller: _ibanDocumentUrlController,
                  keyboardType: TextInputType.url,
                  prefix: const Icon(Icons.link, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Vídeo de apresentação (link)',
                  hintText: 'https://…',
                  controller: _videoUrlController,
                  keyboardType: TextInputType.url,
                  prefix: const Icon(Icons.ondemand_video_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Imagem de biografia (link)',
                  hintText: 'https://…',
                  controller: _bioImageUrlController,
                  keyboardType: TextInputType.url,
                  prefix: const Icon(Icons.image_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                ),

                _sectionTitle('Certificados'),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                ...List.generate(_certificates.length, (i) {
                  final c = _certificates[i];
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == _certificates.length - 1 ? 0 : BecomeTeacherLayout.fieldGap),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _labeledField(
                                label: i == 0 ? 'Nome do certificado' : 'Nome',
                                hintText: 'Ex: Certificado X',
                                controller: c.name,
                                prefix: const Icon(Icons.description_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                              ),
                            ),
                            const SizedBox(width: BecomeTeacherLayout.certificateNameRemoveGap),
                            if (_certificates.length > 1)
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    final removed = _certificates.removeAt(i);
                                    removed.dispose();
                                  });
                                },
                                icon: const Icon(Icons.close, size: 18, color: BecomeTeacherColors.removeIcon),
                                tooltip: 'Remover',
                              ),
                          ],
                        ),
                        const SizedBox(height: BecomeTeacherLayout.certificateNameLinkGap),
                        _labeledField(
                          label: i == 0 ? 'Link do certificado' : 'Link',
                          hintText: 'https://…',
                          controller: c.url,
                          keyboardType: TextInputType.url,
                          prefix: const Icon(Icons.link, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _certificates.add(_CertificateControllers())),
                    child: const Text('Adicionar certificado'),
                  ),
                ),

                _sectionTitle('Texto de apresentação'),
                const SizedBox(height: BecomeTeacherLayout.fieldGap),
                _labeledField(
                  label: 'Apresentação',
                  hintText: 'Fala um pouco sobre ti…',
                  controller: _presentationController,
                  prefix: const Icon(Icons.edit_outlined, size: BecomeTeacherLayout.inputIconSize, color: BecomeTeacherColors.inputIconMuted),
                  maxLines: 4,
                ),

                const SizedBox(height: BecomeTeacherLayout.beforeSubmitGap),
                InkWell(
                  onTap: enabled ? _submit : null,
                  borderRadius: BorderRadius.circular(BecomeTeacherLayout.submitRadius),
                  child: Container(
                    height: BecomeTeacherLayout.submitHeight,
                    decoration: BoxDecoration(
                      color: enabled ? null : BecomeTeacherColors.submitDisabledBackground,
                      gradient: enabled
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [RegisterColors.gradientStart, RegisterColors.gradientEnd],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(BecomeTeacherLayout.submitRadius),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Submeter candidatura',
                      style: TextStyle(
                        fontSize: BecomeTeacherLayout.submitFontSize,
                        fontWeight: FontWeight.w700,
                        color: enabled ? Colors.white : BecomeTeacherColors.submitDisabledText,
                        height: BecomeTeacherLayout.submitLineHeight / BecomeTeacherLayout.submitFontSize,
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
