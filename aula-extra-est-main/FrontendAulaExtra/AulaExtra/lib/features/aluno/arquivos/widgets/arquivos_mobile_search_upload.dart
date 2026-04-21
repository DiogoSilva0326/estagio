import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_constants.dart';
import 'package:flutter/material.dart';

class ArquivosMobileSearchUpload extends StatelessWidget {
  const ArquivosMobileSearchUpload({
    super.key,
    this.onChanged,
    this.onUpload,
    this.isUploading = false,
  });

  final ValueChanged<String>? onChanged;
  final VoidCallback? onUpload;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MobileSearchField(onChanged: onChanged),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: ArquivosConstants.orangeGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: ArquivosConstants.mobileShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isUploading ? null : onUpload,
                borderRadius: BorderRadius.circular(14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUploading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.upload_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      isUploading ? 'A carregar...' : 'Fazer Upload',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 22 / 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MobileSearchField extends StatelessWidget {
  const _MobileSearchField({this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 49,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ArquivosConstants.mobileBorderColor),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(
              Icons.search_rounded,
              size: 20,
              color: ArquivosConstants.mobileMutedColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                decoration: const InputDecoration(
                  hintText: 'Buscar arquivos...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ArquivosConstants.mobileMutedColor,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
