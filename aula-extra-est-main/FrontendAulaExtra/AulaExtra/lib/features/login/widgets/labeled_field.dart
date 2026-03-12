import 'package:aula_extra/core/widgets/asset_picture.dart';
import 'package:aula_extra/features/login/constants/login_colors.dart';
import 'package:flutter/material.dart';

class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.hintText,
    required this.prefixAsset,
    required this.obscureText,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.suffix,
  });

  final String label;
  final String hintText;
  final String prefixAsset;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.7,
            fontWeight: FontWeight.w700,
            color: Color(0xFF364153),
            height: 16.715 / 11.7,
            letterSpacing: -0.1257,
          ),
        ),
        const SizedBox(height: 6.686),
        SizedBox(
          height: 43.458,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 13.372,
                fontWeight: FontWeight.w400,
                color: Color.fromRGBO(10, 10, 10, 0.5),
                letterSpacing: -0.2612,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(start: 13.372, end: 10),
                child: AssetPicture(prefixAsset, width: 16.715, height: 16.715),
              ),
              prefixIconConstraints: const BoxConstraints.tightFor(width: 40.115, height: 43.458),
              suffixIcon: suffix,
              contentPadding: const EdgeInsets.symmetric(horizontal: 13.372, vertical: 10.029),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11.7),
                borderSide: const BorderSide(color: LoginColors.stroke, width: 1.671),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11.7),
                borderSide: const BorderSide(color: LoginColors.stroke, width: 1.671),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11.7),
                borderSide: const BorderSide(color: LoginColors.stroke, width: 1.671),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
