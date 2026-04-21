import 'package:flutter/material.dart';

class ArquivosProfessorMobileSearchUpload extends StatelessWidget {
  const ArquivosProfessorMobileSearchUpload({
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
        SizedBox(
          height: 49.36,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 0.69),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Color(0xFF98A2B3),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    decoration: const InputDecoration(
                      hintText: 'Buscar arquivos...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(10, 10, 10, 0.5),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF101828),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFFF6900),
              borderRadius: BorderRadius.circular(14),
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
                        size: 16,
                        color: Colors.white,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      isUploading ? 'A carregar...' : 'Fazer Upload',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 20 / 14,
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
