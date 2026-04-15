import 'package:aula_extra/features/contactos/widgets/contact_info_card.dart';
import 'package:flutter/material.dart';

class ContactInfoPanel extends StatelessWidget {
  const ContactInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 74.74),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Entre em Contacto',
            style: TextStyle(
              fontSize: 59.792,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 37.37),
          SizedBox(
            width: 610.381,
            child: Text(
              'Tens alguma dúvida? Estamos aqui para ajudar! Envia-nos uma mensagem e responderemos o mais rápido possível.',
              style: TextStyle(
                fontSize: 24.913,
                height: 1.4,
                fontWeight: FontWeight.w500,
                color: Color(0xFFFAA31B),
              ),
            ),
          ),
          SizedBox(height: 49.827),
          ContactInfoCard(
            title: 'Email',
            value: 'contacto@aulaextra.pt',
            backgroundColor: Color(0x1AFB7B02),
          ),
          SizedBox(height: 37.37),
          ContactInfoCard(
            title: 'Telefone',
            value: '+351 123 456 789',
            backgroundColor: Color(0x1A41A7D7),
          ),
        ],
      ),
    );
  }
}
