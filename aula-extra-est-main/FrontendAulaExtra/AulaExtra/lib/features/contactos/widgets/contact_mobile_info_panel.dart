import 'package:aula_extra/features/contactos/widgets/contact_mobile_info_card.dart';
import 'package:flutter/material.dart';

class ContactMobileInfoPanel extends StatelessWidget {
  const ContactMobileInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Entre em Contacto',
          style: TextStyle(
            fontSize: 34,
            height: 1.05,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Tens alguma dúvida? Estamos aqui para ajudar! Envia-nos uma mensagem e responderemos o mais rápido possível.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFFFAA31B),
          ),
        ),
        SizedBox(height: 20),
        ContactMobileInfoCard(
          title: 'Email',
          value: 'contacto@aulaextra.pt',
          icon: Icons.mail_outline_rounded,
          backgroundColor: Color(0x1AFB7B02),
          iconColor: Color(0xFFFB7B02),
        ),
        SizedBox(height: 14),
        ContactMobileInfoCard(
          title: 'Telefone',
          value: '+351 914 359 786',
          icon: Icons.call_outlined,
          backgroundColor: Color(0x1A41A7D7),
          iconColor: Color(0xFF41A7D7),
        ),
      ],
    );
  }
}
