import 'package:aula_extra/features/login/assets/login_assets.dart';
import 'package:aula_extra/features/login/constants/login_colors.dart';
import 'package:aula_extra/features/login/constants/login_social.dart';
import 'package:aula_extra/features/login/widgets/divider_with_label.dart';
import 'package:aula_extra/features/login/widgets/labeled_field.dart';
import 'package:aula_extra/features/login/widgets/social_button.dart';
import 'package:aula_extra/core/data/auth_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({
    super.key,
    required this.onRegisterTap,
  });

  final VoidCallback onRegisterTap;

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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

      final targetRoute = session.appRole == Role.teacher
          ? Routes.professorMeusAlunos
          : session.appRole == Role.student
              ? Routes.areasAluno
              : Routes.home;

      if (!mounted) return;
      navigator.pushNamedAndRemoveUntil(targetRoute, (r) => false);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  List<Widget> _buildSocialButtons() {
    final providers = LoginSocial.order;
    return [
      for (var i = 0; i < providers.length; i++) ...[
        SocialButton(
          text: 'Continuar com ${LoginSocial.labels[providers[i]]!}',
          iconAsset: LoginSocial.assets[providers[i]]!,
          backgroundColor: LoginSocial.backgroundColors[providers[i]]!,
          borderColor: LoginSocial.borderColors[providers[i]]!,
          textColor: LoginSocial.textColors[providers[i]]!,
        ),
        if (i != providers.length - 1) const SizedBox(height: 10.029),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 427.891,
      height: 686.131,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.057),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 41.786,
            spreadRadius: -10.029,
            offset: Offset(0, 20.893),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 50.979,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [LoginColors.gradientStart, LoginColors.gradientEnd],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                      ),
                      border: const Border(
                        bottom: BorderSide(width: 0.836, color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 15.043,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 23.4 / 15.043,
                        letterSpacing: -0.3673,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: widget.onRegisterTap,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                        border: Border(
                          bottom: BorderSide(width: 0.836, color: Color(0xFFE5E7EB)),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Registar-me',
                        style: TextStyle(
                          fontSize: 15.043,
                          fontWeight: FontWeight.w700,
                          color: LoginColors.textSecondary,
                          height: 23.4 / 15.043,
                          letterSpacing: -0.3673,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26.74, 26.74, 26.74, 0),
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
                    height: 30.086 / 25.072,
                    letterSpacing: 0.3305,
                  ),
                ),
                const SizedBox(height: 6.686),
                const Text(
                  'Entra na tua conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.372,
                    fontWeight: FontWeight.w400,
                    color: LoginColors.textSecondary,
                    height: 20.057 / 13.372,
                    letterSpacing: -0.2612,
                  ),
                ),
                const SizedBox(height: 20.061),
                ..._buildSocialButtons(),
                const SizedBox(height: 20.0),
                const DividerWithLabel(),
                const SizedBox(height: 20.0),
                LabeledField(
                  label: 'Email',
                  hintText: 'o-teu-email@exemplo.com',
                  prefixAsset: LoginAssets.email,
                  obscureText: false,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 20.0),
                LabeledField(
                  label: 'Password',
                  hintText: '••••••••',
                  prefixAsset: LoginAssets.password,
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  onChanged: (_) => setState(() {}),
                  suffix: IconButton(
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 16.715,
                      color: const Color(0xFF6A7282),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
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
                      height: 20.057 / 13.372,
                      letterSpacing: -0.2612,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _canSubmit ? _handleLogin : null,
                  borderRadius: BorderRadius.circular(11.7),
                  child: Container(
                    height: 50.144,
                    decoration: BoxDecoration(
                      color: _canSubmit ? null : const Color(0xFFD1D5DC),
                      gradient: _canSubmit
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [LoginColors.gradientStart, LoginColors.gradientEnd],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(11.7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _isSubmitting ? 'A entrar...' : 'Entrar',
                      style: TextStyle(
                        fontSize: 15.043,
                        fontWeight: FontWeight.w700,
                        color: _canSubmit ? Colors.white : const Color(0xFF6A7282),
                        height: 23.4 / 15.043,
                        letterSpacing: -0.3673,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ainda não tens conta?',
                      style: TextStyle(
                        fontSize: 13.372,
                        fontWeight: FontWeight.w400,
                        color: LoginColors.textSecondary,
                        height: 20.057 / 13.372,
                        letterSpacing: -0.2612,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: widget.onRegisterTap,
                      child: const Text(
                        'Regista-te',
                        style: TextStyle(
                          fontSize: 13.372,
                          fontWeight: FontWeight.w700,
                          color: LoginColors.gradientStart,
                          height: 20.057 / 13.372,
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
