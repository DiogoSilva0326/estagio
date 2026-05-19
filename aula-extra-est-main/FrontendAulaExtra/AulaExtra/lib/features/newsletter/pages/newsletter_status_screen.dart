import 'package:aula_extra/core/data/newsletter/newsletter_api.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:flutter/material.dart';

class NewsletterStatusScreen extends StatefulWidget {
  const NewsletterStatusScreen.confirm({
    required this.token,
    super.key,
  }) : isConfirm = true;

  const NewsletterStatusScreen.unsubscribe({
    required this.token,
    super.key,
  }) : isConfirm = false;

  final bool isConfirm;
  final String token;

  @override
  State<NewsletterStatusScreen> createState() => _NewsletterStatusScreenState();
}

class _NewsletterStatusScreenState extends State<NewsletterStatusScreen> {
  final NewsletterApi _newsletterApi = NewsletterApi();
  late final Future<NewsletterActionResult> _future;

  static const Color _pageBackground = Color(0xFFF7F1E9);
  static const Color _cardBackground = Color(0xFFFFFCF8);
  static const Color _primary = Color(0xFFFC9039);
  static const Color _primaryDark = Color(0xFF6A3B10);
  static const Color _secondaryText = Color(0xFF7B6758);
  static const Color _successTint = Color(0xFFEFF8ED);
  static const Color _successColor = Color(0xFF2D8A47);
  static const Color _errorTint = Color(0xFFFFEEE8);
  static const Color _errorColor = Color(0xFFC75A28);

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<NewsletterActionResult> _load() async {
    final token = widget.token.trim();
    if (token.isEmpty) {
      return const NewsletterActionResult(
        success: false,
        message: 'O link recebido não contém um token válido.',
      );
    }

    try {
      return widget.isConfirm
          ? await _newsletterApi.confirm(token)
          : await _newsletterApi.unsubscribe(token);
    } catch (error) {
      return NewsletterActionResult(
        success: false,
        message: error.toString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Stack(
        children: [
          Positioned(
            top: -80,
            right: -50,
            child: _BackgroundBlur(
              size: 240,
              color: _primary.withAlpha(48),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -40,
            child: _BackgroundBlur(
              size: 280,
              color: const Color(0xFFF8C76A).withAlpha(58),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: FutureBuilder<NewsletterActionResult>(
                  future: _future,
                  builder: (context, snapshot) {
                    final loading = snapshot.connectionState != ConnectionState.done;
                    final result = snapshot.data;
                    final success = result?.success == true;

                    return Container(
                      padding: const EdgeInsets.all(34),
                      decoration: BoxDecoration(
                        color: _cardBackground,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withAlpha(160),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A6A3B10),
                            blurRadius: 42,
                            offset: Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 18,
                            runSpacing: 18,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _StatusIcon(
                                isLoading: loading,
                                isSuccess: success,
                                isConfirm: widget.isConfirm,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: loading
                                      ? _primary.withAlpha(28)
                                      : (success ? _successTint : _errorTint),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _eyebrow(loading, success),
                                  style: TextStyle(
                                    color: loading
                                        ? _primaryDark
                                        : (success ? _successColor : _errorColor),
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _title(loading, success),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: _primaryDark,
                              height: 1.02,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            loading
                                ? 'Estamos a tratar do teu pedido e a atualizar a tua preferência de newsletter.'
                                : (result?.message.trim().isNotEmpty == true
                                    ? result!.message
                                    : _fallbackMessage(success)),
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.65,
                              color: _secondaryText,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8EFE5),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              _supportingMessage(loading, success),
                              style: const TextStyle(
                                color: _primaryDark,
                                fontSize: 14.5,
                                height: 1.55,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (loading)
                            const SizedBox(
                              height: 32,
                              width: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.8,
                                color: _primary,
                              ),
                            )
                          else
                            Wrap(
                              spacing: 14,
                              runSpacing: 14,
                              children: [
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      Routes.home,
                                      (route) => false,
                                    );
                                  },
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: _primaryDark,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Voltar ao início'),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamedAndRemoveUntil(
                                      Routes.contactos,
                                      (route) => false,
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _primaryDark,
                                    side: BorderSide(
                                      color: _primaryDark.withAlpha(72),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text('Falar com a equipa'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _eyebrow(bool loading, bool success) {
    if (loading) {
      return 'A PROCESSAR';
    }

    if (widget.isConfirm) {
      return success ? 'SUBSCRIÇÃO ATIVA' : 'ERRO NA CONFIRMAÇÃO';
    }

    return success ? 'SUBSCRIÇÃO REMOVIDA' : 'ERRO NO CANCELAMENTO';
  }

  String _title(bool loading, bool success) {
    if (loading) {
      return 'Newsletter';
    }

    if (widget.isConfirm) {
      return success ? 'Subscrição confirmada' : 'Confirmação falhou';
    }

    return success ? 'Subscrição cancelada' : 'Cancelamento falhou';
  }

  String _fallbackMessage(bool success) {
    if (widget.isConfirm) {
      return success
          ? 'Obrigado. A tua subscrição foi confirmada com sucesso.'
          : 'Não foi possível confirmar a tua subscrição com este link.';
    }

    return success
        ? 'A tua subscrição foi cancelada.'
        : 'Não foi possível cancelar a tua subscrição com este link.';
  }

  String _supportingMessage(bool loading, bool success) {
    if (loading) {
      return 'Se este processo demorar mais do que o esperado, volta a abrir o link recebido no teu email.';
    }

    if (widget.isConfirm) {
      return success
          ? 'A partir de agora vais receber novidades, novos explicadores e atualizações da plataforma com o visual e tom do Apoio Extra.'
          : 'Este link pode já ter sido usado ou expirado. Se precisares, podes voltar a subscrever-te no footer do site.';
    }

    return success
        ? 'O teu email foi removido da newsletter. Se mudares de ideias, podes voltar a subscrever-te a qualquer momento no site.'
        : 'Não conseguimos concluir o cancelamento com este link. Pede um novo email de remoção para garantir que o token está atualizado.';
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.isLoading,
    required this.isSuccess,
    required this.isConfirm,
  });

  final bool isLoading;
  final bool isSuccess;
  final bool isConfirm;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isLoading
        ? _NewsletterStatusScreenState._primary.withAlpha(28)
        : isSuccess
            ? _NewsletterStatusScreenState._successTint
            : _NewsletterStatusScreenState._errorTint;
    final iconColor = isLoading
        ? _NewsletterStatusScreenState._primaryDark
        : isSuccess
            ? _NewsletterStatusScreenState._successColor
            : _NewsletterStatusScreenState._errorColor;

    final icon = isLoading
        ? Icons.schedule_rounded
        : isSuccess
            ? (isConfirm ? Icons.mark_email_read_rounded : Icons.unsubscribe_rounded)
            : Icons.error_outline_rounded;

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, color: iconColor, size: 36),
    );
  }
}

class _BackgroundBlur extends StatelessWidget {
  const _BackgroundBlur({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}