import 'package:aula_extra/core/components/footer/constants/footer_colors.dart';
import 'package:aula_extra/core/data/newsletter/newsletter_api.dart';
import 'package:flutter/material.dart';

class FooterNewsletterBlock extends StatefulWidget {
  const FooterNewsletterBlock({
    super.key,
    required this.scale,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.textAlign = TextAlign.start,
  });

  final double scale;
  final CrossAxisAlignment crossAxisAlignment;
  final TextAlign textAlign;

  @override
  State<FooterNewsletterBlock> createState() => _FooterNewsletterBlockState();
}

class _FooterNewsletterBlockState extends State<FooterNewsletterBlock> {
  final NewsletterApi _newsletterApi = NewsletterApi();
  late final TextEditingController _emailController;
  bool _isSubmitting = false;
  String? _feedbackMessage;
  bool _feedbackIsSuccess = false;

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  double s(double value) => value * widget.scale;

  Future<void> _submitSubscribe() async {
    final email = _emailController.text.trim();

    if (!_emailRegex.hasMatch(email)) {
      setState(() {
        _feedbackIsSuccess = false;
        _feedbackMessage = 'Introduz um email válido.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _feedbackMessage = null;
    });

    try {
      final result = await _newsletterApi.subscribe(
        email: email,
        locale: Localizations.maybeLocaleOf(context)?.toLanguageTag() ?? 'pt-PT',
      );

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _feedbackIsSuccess = result.success;
        _feedbackMessage = result.message;
        if (result.success) {
          _emailController.clear();
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _feedbackIsSuccess = false;
        _feedbackMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final fieldWidth = s(220).clamp(176.0, 260.0);

    return Column(
      crossAxisAlignment: widget.crossAxisAlignment,
      children: [
        Text(
          'NEWSLETTER',
          textAlign: widget.textAlign,
          style: TextStyle(
            fontSize: s(16),
            fontWeight: FontWeight.w700,
            color: FooterColors.textColor,
          ),
        ),
        SizedBox(height: s(10)),
        SizedBox(
          width: fieldWidth,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onSubmitted: _isSubmitting ? null : (_) => _submitSubscribe(),
            style: TextStyle(
              fontSize: s(13),
              color: FooterColors.textColor,
            ),
            decoration: InputDecoration(
              hintText: 'O teu email',
              isDense: true,
              filled: true,
              fillColor: Colors.white.withAlpha(36),
              contentPadding: EdgeInsets.symmetric(
                horizontal: s(12),
                vertical: s(11),
              ),
              hintStyle: TextStyle(
                fontSize: s(13),
                color: FooterColors.textColor.withAlpha(179),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(s(10)),
                borderSide: BorderSide(
                  color: Colors.white.withAlpha(56),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(s(10)),
                borderSide: const BorderSide(color: Colors.white, width: 1.1),
              ),
            ),
          ),
        ),
        SizedBox(height: s(10)),
        SizedBox(
          width: fieldWidth,
          child: OutlinedButton(
            onPressed: _isSubmitting ? null : _submitSubscribe,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withAlpha(92)),
              padding: EdgeInsets.symmetric(vertical: s(10)),
              textStyle: TextStyle(
                fontSize: s(11.8),
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(s(10)),
              ),
            ),
            child: _isSubmitting
                ? SizedBox(
                    height: s(14),
                    width: s(14),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Subscrever'),
          ),
        ),
        if (_feedbackMessage != null) ...[
          SizedBox(height: s(8)),
          SizedBox(
            width: fieldWidth,
            child: Text(
              _feedbackMessage!,
              textAlign: widget.textAlign,
              style: TextStyle(
                fontSize: s(11.5),
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: _feedbackIsSuccess
                    ? const Color(0xFFF5FFE8)
                    : const Color(0xFFFFE5E1),
              ),
            ),
          ),
        ],
        SizedBox(height: s(6)),
        Text(
          const [
            'Subscreve para',
            'receber atualizações',
            'sobre novos apoios',
            'e ofertas especiais.',
          ].join('\n'),
          textAlign: widget.textAlign,
          style: TextStyle(
            fontSize: s(14),
            fontWeight: FontWeight.w400,
            color: FooterColors.textColor,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}