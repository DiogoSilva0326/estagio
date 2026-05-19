import 'package:aula_extra/core/data/auth_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/login/assets/login_assets.dart';
import 'package:aula_extra/features/login/constants/login_colors.dart';
import 'package:aula_extra/features/login/constants/login_mobile_layout.dart';
import 'package:aula_extra/features/login/constants/login_social.dart';
import 'package:aula_extra/features/login/widgets/divider_with_label.dart';
import 'package:aula_extra/features/login/widgets/login_mobile_field.dart';
import 'package:aula_extra/features/login/widgets/login_mobile_social_button.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginMobileFormSection extends StatefulWidget {
  const LoginMobileFormSection({super.key, required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  State<LoginMobileFormSection> createState() => _LoginMobileFormSectionState();
}

class _LoginMobileFormSectionState extends State<LoginMobileFormSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_isSubmitting) return false;
    if (_emailController.text.trim().isEmpty) return false;
    if (_passwordController.text.isEmpty) return false;
    return true;
  }

  String _resolveTargetRoute(Role role) {
    if (role == Role.student) return Routes.areasAluno;
    if (role == Role.teacher || role == Role.tutor || role == Role.psychologist) {
      return Routes.professorMeusAlunos;
    }
    return Routes.home;
  }

  void _showProviderNotAvailable(String provider) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login com $provider ainda não está disponível.')),
    );
  }

  Future<void> _handleLogin() async {
    if (!_canSubmit) return;

    final user = context.read<UserProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSubmitting = true);
    try {
      final session = await AuthService().login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      AuthService.applySessionToProvider(user, session);

        final targetRoute = _resolveTargetRoute(session.appRole);

      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (_isSubmitting) return;

    final user = context.read<UserProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSubmitting = true);
    try {
      final session = await AuthService().loginWithGoogle();
      AuthService.applySessionToProvider(user, session);

      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil(_resolveTargetRoute(session.appRole), (route) => false);
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
      width: LoginMobileLayout.cardWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(LoginMobileLayout.cardRadius),
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
          _MobileAuthTabs(onRegisterTap: widget.onRegisterTap),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Bem-vindo de volta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25.072,
                    fontWeight: FontWeight.w700,
                    color: LoginColors.textPrimary,
                    letterSpacing: 0.3305,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Entra na tua conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: LoginColors.textSecondary,
                    letterSpacing: -0.15,
                  ),
                ),
                const SizedBox(height: 24),
                ...LoginSocial.order.map((provider) {
                  final index = LoginSocial.order.indexOf(provider);
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == LoginSocial.order.length - 1 ? 0 : 12,
                    ),
                    child: LoginMobileSocialButton(
                      text: 'Continuar com ${LoginSocial.labels[provider]!}',
                      iconAsset: LoginSocial.assets[provider]!,
                      backgroundColor: LoginSocial.backgroundColors[provider]!,
                      borderColor: LoginSocial.borderColors[provider]!,
                      textColor: LoginSocial.textColors[provider]!,
                      onTap: provider == 'google'
                          ? _handleGoogleLogin
                          : () => _showProviderNotAvailable(LoginSocial.labels[provider]!),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                const DividerWithLabel(),
                const SizedBox(height: 16),
                LoginMobileField(
                  label: 'Email',
                  hintText: 'o-teu-email@exemplo.com',
                  prefixAsset: LoginAssets.email,
                  obscureText: false,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                LoginMobileField(
                  label: 'Password',
                  hintText: '•••••••••',
                  prefixAsset: LoginAssets.password,
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  onChanged: (_) => setState(() {}),
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
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Esqueceste-te da password?',
                    style: TextStyle(
                      fontSize: 13.372,
                      fontWeight: FontWeight.w700,
                      color: LoginColors.gradientStart,
                      letterSpacing: -0.2612,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: LoginMobileLayout.primaryButtonHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _canSubmit
                          ? LoginMobileLayout.actionGradient
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
                      onPressed: _canSubmit ? _handleLogin : null,
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
                              'Entrar',
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ainda não tens conta? ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: LoginColors.textSecondary,
                        letterSpacing: -0.15,
                      ),
                    ),
                    InkWell(
                      onTap: widget.onRegisterTap,
                      child: const Text(
                        'Regista-te',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF6900),
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

class _MobileAuthTabs extends StatelessWidget {
  const _MobileAuthTabs({required this.onRegisterTap});

  final VoidCallback onRegisterTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52.67,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [LoginColors.gradientStart, LoginColors.gradientEnd],
                ),
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
                  color: Colors.white,
                  letterSpacing: -0.1504,
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onRegisterTap,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                  ),
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
                    color: Color(0xFF6A7282),
                    letterSpacing: -0.1504,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
