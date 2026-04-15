import 'package:aula_extra/core/data/auth_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/register/assets/register_assets.dart';
import 'package:aula_extra/features/register/constants/register_colors.dart';
import 'package:aula_extra/features/register/constants/register_mobile_layout.dart';
import 'package:aula_extra/features/register/constants/register_social.dart';
import 'package:aula_extra/features/register/widgets/divider_with_label.dart';
import 'package:aula_extra/features/register/widgets/register_mobile_dropdown.dart';
import 'package:aula_extra/features/register/widgets/register_mobile_field.dart';
import 'package:aula_extra/features/register/widgets/register_mobile_social_button.dart';
import 'package:aula_extra/features/register/widgets/terms_text.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterMobileFormSection extends StatefulWidget {
  const RegisterMobileFormSection({super.key, required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  State<RegisterMobileFormSection> createState() =>
      _RegisterMobileFormSectionState();
}

class _RegisterMobileFormSectionState extends State<RegisterMobileFormSection> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;
  bool _isSubmitting = false;
  String? _educationLevel;

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
      navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: RegisterMobileLayout.cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(RegisterMobileLayout.cardRadius),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 25,
            spreadRadius: -5,
            offset: Offset(0, 20),
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            blurRadius: 10,
            spreadRadius: -6,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RegisterMobileTabs(onLoginTap: widget.onLoginTap),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Cria a tua conta gratuita',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.072,
                    fontWeight: FontWeight.w700,
                    color: RegisterColors.textPrimary,
                    letterSpacing: 0.3305,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'E começa a aprender hoje!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: RegisterColors.textSecondary,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 24),
                ...RegisterSocial.order.map((provider) {
                  final index = RegisterSocial.order.indexOf(provider);
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == RegisterSocial.order.length - 1 ? 0 : 12,
                    ),
                    child: RegisterMobileSocialButton(
                      text: 'Registar com ${RegisterSocial.labels[provider]!}',
                      iconAsset: RegisterSocial.assets[provider]!,
                      backgroundColor:
                          RegisterSocial.backgroundColors[provider]!,
                      borderColor: RegisterSocial.borderColors[provider]!,
                      textColor: RegisterSocial.textColors[provider]!,
                    ),
                  );
                }),
                const SizedBox(height: 20),
                const RegisterDividerWithLabel(),
                const SizedBox(height: 16),
                RegisterMobileField(
                  label: 'Nome Completo',
                  hintText: 'O teu nome completo',
                  controller: _nameController,
                  prefix: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Color(0xFF99A1AF),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                RegisterMobileField(
                  label: 'Email',
                  hintText: 'o-teu-email@exemplo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const AssetPicture(
                    RegisterAssets.email,
                    width: 20,
                    height: 20,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                RegisterMobileDropdown(
                  label: 'Nível de Ensino',
                  value: _educationLevel,
                  onChanged: (value) => setState(() => _educationLevel = value),
                ),
                const SizedBox(height: 16),
                RegisterMobileField(
                  label: 'Password',
                  hintText: 'Mínimo 6 caracteres',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefix: const AssetPicture(
                    RegisterAssets.password,
                    width: 20,
                    height: 20,
                  ),
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: const Color(0xFF98A2B3),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                RegisterMobileField(
                  label: 'Confirmar Password',
                  hintText: 'Repete a password',
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  prefix: const AssetPicture(
                    RegisterAssets.password,
                    width: 20,
                    height: 20,
                  ),
                  suffix: IconButton(
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: const Color(0xFF98A2B3),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) =>
                            setState(() => _acceptTerms = value ?? false),
                        side: const BorderSide(
                          color: RegisterColors.stroke,
                          width: 1.2,
                        ),
                        activeColor: RegisterColors.gradientStart,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TermsText(onChanged: () => setState(() {})),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: RegisterMobileLayout.primaryButtonHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _canSubmit
                          ? RegisterMobileLayout.actionGradient
                          : null,
                      color: _canSubmit ? null : const Color(0xFFD1D5DC),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.10),
                          blurRadius: 15,
                          offset: Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.10),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _handleRegister : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Registar-me',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3125,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Ao registar, concordas com os nossos Termos e recebes atualizações sobre novas aulas e ofertas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6A7282),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Já tens conta? ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: RegisterColors.textSecondary,
                        letterSpacing: -0.15,
                      ),
                    ),
                    InkWell(
                      onTap: widget.onLoginTap,
                      child: const Text(
                        'Entra',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: RegisterColors.gradientStart,
                          letterSpacing: -0.3125,
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

class _RegisterMobileTabs extends StatelessWidget {
  const _RegisterMobileTabs({required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.67,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onLoginTap,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(24)),
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.691),
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Entrar',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6A7282),
                    letterSpacing: -0.1504,
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
                borderRadius: BorderRadius.only(topRight: Radius.circular(24)),
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE5E7EB), width: 0.691),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Registar-me',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.1504,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
