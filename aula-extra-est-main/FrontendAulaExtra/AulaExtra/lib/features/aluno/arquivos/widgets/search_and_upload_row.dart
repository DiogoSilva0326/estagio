import 'package:flutter/material.dart';

class SearchAndUploadRow extends StatelessWidget {
  const SearchAndUploadRow({super.key, this.onChanged, this.onUpload});

  final ValueChanged<String>? onChanged;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SearchField(onChanged: onChanged)),
        const SizedBox(width: 22.292),
        _GradientButton(
          label: 'Fazer Upload',
          icon: Icons.upload_rounded,
          onTap: onUpload ?? () {},
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({this.onChanged});

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 69.662,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19.505),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.393),
        ),
        child: Row(
          children: [
            SizedBox(width: 22.292),
            Icon(Icons.search_rounded, size: 27.865, color: Color(0xFF101828)),
            SizedBox(width: 16.719),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: 'Buscar arquivos...',
                  hintStyle: TextStyle(
                    fontSize: 22.292,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(10, 10, 10, 0.5),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 16.719),
                ),
              ),
            ),
            SizedBox(width: 22.292),
          ],
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 69.662,
      width: 235.556,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(19.505),
        child: InkWell(
          borderRadius: BorderRadius.circular(19.505),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(19.505),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF6B00), Color(0xFFFF9966)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 27.865, color: Colors.white),
                const SizedBox(width: 16.719),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22.292,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 33.438 / 22.292,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
