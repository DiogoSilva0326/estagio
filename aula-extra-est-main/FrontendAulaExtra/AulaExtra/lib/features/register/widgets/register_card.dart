import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/register/assets/register_assets.dart';
import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:aula_extra/features/register/widgets/divider_with_label.dart';
import 'package:aula_extra/features/register/widgets/labeled_dropdown.dart';
import 'package:aula_extra/features/register/widgets/labeled_text_field.dart';
import 'package:aula_extra/features/register/widgets/social_register_button.dart';
import 'package:aula_extra/features/register/widgets/terms_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aula_extra/core/data/auth_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';

class RegisterCard extends StatefulWidget {
  const RegisterCard({super.key, required this.onLoginTap, this.onSubmit});

  final VoidCallback onLoginTap;
  final VoidCallback? onSubmit;

  @override
  State<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _isSubmitting = false;

  String? _educationLevel;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_isSubmitting) return false;
    if (!_acceptTerms) return false;
    if (_nameController.text.trim().isEmpty) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (_passwordController.text.length < 6) return false;
    if (_passwordController.text != _confirmController.text) return false;
    return true;
  }

  Future<void> _handleRegister() async {
    if (!_canSubmit) return;

    final user = context.read<UserProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSubmitting = true);
    try {
      final session = await AuthService().register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        educationLevel: (_educationLevel ?? '').trim().isEmpty
            ? null
            : _educationLevel!.trim(),
      );

      AuthService.applySessionToProvider(user, session);

      final targetRoute = session.appRole == Role.teacher
          ? Routes.professorMeusAlunos
          : session.appRole == Role.student
          ? Routes.areasAluno
          : Routes.home;

      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil(targetRoute, (r) => false);
      widget.onSubmit?.call();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _canSubmit;

    return Container(
      width: 428,
      height: 999.781,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.063),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 41.797,
            spreadRadius: -10.031,
            offset: Offset(0, 20.898),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 50.992,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: widget.onLoginTap,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        border: Border(
                          bottom: BorderSide(
                            width: 0.836,
                            color: Color(0xFFE5E7EB),
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          fontSize: 15.047,
                          fontWeight: FontWeight.w700,
                          color: RegisterColors.textSecondary,
                          height: 23.406 / 15.047,
                          letterSpacing: -0.3674,
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
                          width: 0.836,
                          color: Color(0xFFE5E7EB),
                        ),
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Registar-me',
                      style: TextStyle(
                        fontSize: 15.047,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 23.406 / 15.047,
                        letterSpacing: -0.3674,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26.75, 26.75, 26.75, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Cria a tua conta gratuita',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.078,
                    fontWeight: FontWeight.w700,
                    color: RegisterColors.textPrimary,
                    height: 30.094 / 25.078,
                    letterSpacing: 0.3306,
                  ),
                ),
                const SizedBox(height: 6.688),
                const Text(
                  'E começa a aprender hoje!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.375,
                    fontWeight: FontWeight.w400,
                    color: RegisterColors.textSecondary,
                    height: 20.063 / 13.375,
                    letterSpacing: -0.2612,
                  ),
                ),
                const SizedBox(height: 20.063),
                const SocialRegisterButton(
                  text: 'Registar com Google',
                  iconAsset: RegisterAssets.google,
                  backgroundColor: Colors.white,
                  borderColor: RegisterColors.stroke,
                  textColor: Color(0xFF364153),
                ),
                const SizedBox(height: 10.031),
                const SocialRegisterButton(
                  text: 'Registar com Facebook',
                  iconAsset: RegisterAssets.facebook,
                  backgroundColor: Color(0xFF1877F2),
                  borderColor: Colors.transparent,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 10.031),
                const SocialRegisterButton(
                  text: 'Registar com Apple',
                  iconAsset: RegisterAssets.apple,
                  backgroundColor: Colors.black,
                  borderColor: Colors.transparent,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 20.063),
                const RegisterDividerWithLabel(),
                const SizedBox(height: 20.063),
                LabeledTextField(
                  label: 'Nome Completo',
                  hintText: 'O teu nome completo',
                  controller: _nameController,
                  prefix: const Icon(
                    Icons.person_outline,
                    size: 16.719,
                    color: Color(0xFF99A1AF),
                  ),
                ),
                const SizedBox(height: 20.063),
                LabeledTextField(
                  label: 'Email',
                  hintText: 'o-teu-email@exemplo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const AssetPicture(
                    RegisterAssets.email,
                    width: 16.719,
                    height: 16.719,
                  ),
                ),
                const SizedBox(height: 20.063),
                LabeledDropdown(
                  label: 'Nível de Ensino',
                  value: _educationLevel,
                  onChanged: (v) => setState(() => _educationLevel = v),
                ),
                const SizedBox(height: 20.063),
                LabeledTextField(
                  label: 'Password',
                  hintText: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefix: const AssetPicture(
                    RegisterAssets.password,
                    width: 16.719,
                    height: 16.719,
                  ),
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16.719,
                      color: const Color(0xFF99A1AF),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20.063),
                LabeledTextField(
                  label: 'Confirmar Password',
                  hintText: 'Repete a password',
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  prefix: const AssetPicture(
                    RegisterAssets.password,
                    width: 16.719,
                    height: 16.719,
                  ),
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16.719,
                      color: const Color(0xFF99A1AF),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 32,
                      height: 32,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20.063),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16.719,
                      height: 16.719,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) =>
                            setState(() => _acceptTerms = v ?? false),
                        side: const BorderSide(
                          color: RegisterColors.stroke,
                          width: 1.2,
                        ),
                        activeColor: RegisterColors.gradientStart,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 10.031),
                    Expanded(
                      child: TermsText(onChanged: () => setState(() {})),
                    ),
                  ],
                ),
                const SizedBox(height: 20.063),
                InkWell(
                  onTap: enabled ? _handleRegister : null,
                  borderRadius: BorderRadius.circular(11.703),
                  child: Container(
                    height: 50.156,
                    decoration: BoxDecoration(
                      color: enabled ? null : const Color(0xFFD1D5DC),
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
                      borderRadius: BorderRadius.circular(11.703),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isSubmitting ? 'A registar...' : 'Registar-me',
                      style: TextStyle(
                        fontSize: 15.047,
                        fontWeight: FontWeight.w700,
                        color: enabled ? Colors.white : const Color(0xFF6A7282),
                        height: 23.406 / 15.047,
                        letterSpacing: -0.3674,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ao registar, concordas com os nossos Termos e recebes atualizações sobre novas aulas e ofertas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.031,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6A7282),
                    height: 16.301 / 10.031,
                  ),
                ),
                const SizedBox(height: 20.063),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tens conta?',
                      style: TextStyle(
                        fontSize: 13.375,
                        fontWeight: FontWeight.w400,
                        color: RegisterColors.textSecondary,
                        height: 20.063 / 13.375,
                        letterSpacing: -0.2612,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: widget.onLoginTap,
                      child: const Text(
                        'Entra',
                        style: TextStyle(
                          fontSize: 13.375,
                          fontWeight: FontWeight.w700,
                          color: RegisterColors.gradientStart,
                          height: 20.063 / 13.375,
                          letterSpacing: -0.2612,
                        ),
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
