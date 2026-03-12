import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/perfil/constants/perfil_professor_colors.dart';
import 'package:aula_extra/features/professor/perfil/constants/perfil_professor_layout.dart';
import 'package:aula_extra/features/professor/perfil/widgets/full_bleed_scaled_section.dart';
import 'package:flutter/material.dart';

class PerfilProfessorContentSection extends StatelessWidget {
  const PerfilProfessorContentSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      color: PerfilProfessorColors.title,
      fontSize: PerfilProfessorLayout.titleFontSize,
      fontWeight: FontWeight.w700,
      height: PerfilProfessorLayout.titleLineHeight / PerfilProfessorLayout.titleFontSize,
    );

    return Container(
      color: PerfilProfessorColors.background,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.only(
            left: PerfilProfessorLayout.pageLeftPadding,
            right: PerfilProfessorLayout.pageRightPadding,
            top: PerfilProfessorLayout.pageTopPadding,
            bottom: PerfilProfessorLayout.pageBottomPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProfessorMenuNav(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    PerfilProfessorLayout.contentPadding,
                    PerfilProfessorLayout.contentPadding,
                    PerfilProfessorLayout.contentPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            height: PerfilProfessorLayout.titleLineHeight,
                            child: Text('Meu Perfil', style: titleStyle),
                          ),
                          const Spacer(),
                          const _SaveProfileButton(),
                        ],
                      ),
                      const SizedBox(height: 29.229),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _LeftProfileCard(),
                          const SizedBox(width: PerfilProfessorLayout.cardsGap),
                          const Expanded(child: _RightInfoCard()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveProfileButton extends StatelessWidget {
  const _SaveProfileButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: PerfilProfessorLayout.saveButtonHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(PerfilProfessorLayout.saveButtonRadius),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PerfilProfessorColors.primaryGradientTop,
              PerfilProfessorColors.primaryGradientBottom,
            ],
          ),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(PerfilProfessorLayout.saveButtonRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.614),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.save_outlined,
                  color: Colors.white,
                  size: PerfilProfessorLayout.saveButtonIconSize,
                ),
                const SizedBox(width: 10),
                Text(
                  'Salvar Perfil',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: PerfilProfessorLayout.saveButtonFontSize,
                    fontWeight: FontWeight.w600,
                    height: PerfilProfessorLayout.saveButtonLineHeight /
                        PerfilProfessorLayout.saveButtonFontSize,
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

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.width,
    required this.child,
  });

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(PerfilProfessorLayout.cardRadius),
          border: Border.all(
            color: PerfilProfessorColors.cardBorder,
            width: PerfilProfessorLayout.cardBorderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 7.307,
              offset: const Offset(0, 4.871),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.871,
              offset: const Offset(0, 2.436),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PerfilProfessorLayout.cardPadding,
            PerfilProfessorLayout.cardPadding,
            PerfilProfessorLayout.cardPadding,
            0,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LeftProfileCard extends StatelessWidget {
  const _LeftProfileCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      width: PerfilProfessorLayout.leftCardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Foto de Perfil'),
          const SizedBox(height: 19.486),
          const _AvatarBlock(),
          const SizedBox(height: 30.447),
          DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: PerfilProfessorColors.cardBorder,
                  width: PerfilProfessorLayout.cardBorderWidth,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 30.447),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estatísticas',
                    style: TextStyle(
                      color: PerfilProfessorColors.title,
                      fontSize: 19.486,
                      fontWeight: FontWeight.w500,
                      height: 29.229 / 19.486,
                    ),
                  ),
                  const SizedBox(height: 14.614),
                  const _StatRow(label: 'Total de aulas:', value: '142'),
                  const SizedBox(height: 14.614),
                  const _StatRow(
                    label: 'Avaliação:',
                    value: '4.8 ⭐',
                    valueColor: PerfilProfessorColors.warningStarText,
                  ),
                  const SizedBox(height: 14.614),
                  const _StatRow(label: 'Membro desde:', value: 'Jan 2024'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30.447),
          const _LabeledField(
            label: 'Vídeo de apresentação',
            hintText: 'Link do vídeo',
            height: 42,
          ),
          const SizedBox(height: 30.447),
        ],
      ),
    );
  }
}

class _AvatarBlock extends StatelessWidget {
  const _AvatarBlock();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 199.729,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: PerfilProfessorLayout.avatarSize,
                height: PerfilProfessorLayout.avatarSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      PerfilProfessorColors.primaryGradientTop,
                      PerfilProfessorColors.primaryGradientBottom,
                    ],
                  ),
                ),
                child: const Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: PerfilProfessorLayout.avatarTextFontSize,
                      fontWeight: FontWeight.w700,
                      height: PerfilProfessorLayout.avatarTextLineHeight /
                          PerfilProfessorLayout.avatarTextFontSize,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Transform.translate(
                  offset: const Offset(4, 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: PerfilProfessorColors.cardBorder,
                        width: 2.436,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 18.268,
                          offset: const Offset(0, 12.179),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 7.307,
                          offset: const Offset(0, 4.871),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: PerfilProfessorLayout.avatarActionSize,
                        height: PerfilProfessorLayout.avatarActionSize,
                        child: const Icon(
                          Icons.photo_camera_outlined,
                          size: PerfilProfessorLayout.avatarActionIconSize,
                          color: PerfilProfessorColors.text,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 19.486),
          const Text(
            'Clique no ícone para alterar a foto',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: PerfilProfessorColors.muted,
              fontSize: 17.05,
              fontWeight: FontWeight.w400,
              height: 24.357 / 17.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PerfilProfessorColors.muted,
            fontSize: PerfilProfessorLayout.statLabelFontSize,
            fontWeight: FontWeight.w400,
            height: PerfilProfessorLayout.statLabelLineHeight /
                PerfilProfessorLayout.statLabelFontSize,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? PerfilProfessorColors.title,
            fontSize: PerfilProfessorLayout.statValueFontSize,
            fontWeight: FontWeight.w500,
            height: PerfilProfessorLayout.statValueLineHeight /
                PerfilProfessorLayout.statValueFontSize,
          ),
        ),
      ],
    );
  }
}

class _RightInfoCard extends StatelessWidget {
  const _RightInfoCard();

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      width: PerfilProfessorLayout.rightCardWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Informações Pessoais'),
          const SizedBox(height: 29.229),
          Row(
            children: const [
              Expanded(
                child: _LabeledField(
                  label: 'Nome Completo',
                  initialValue: 'Nome do Explicador',
                ),
              ),
              SizedBox(width: 19.486),
              Expanded(
                child: _LabeledField(
                  label: 'Email',
                  initialValue: 'explicador@aulaextra.pt',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.357),
          Row(
            children: const [
              Expanded(
                child: _LabeledField(
                  label: 'Telefone',
                  initialValue: '+351 123 456 789',
                ),
              ),
              SizedBox(width: 19.486),
              Expanded(
                child: _LabeledField(
                  label: 'Preço por Hora (€)',
                  initialValue: '25',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.357),
          const _LabeledField(
            label: 'Biografia',
            initialValue:
                'Sou um explicador experiente com mais de 5 anos de ensino. Especializado em Matemática e Física para todos os níveis.',
            maxLines: 3,
            height: 77.943,
          ),
          const SizedBox(height: 24.357),
          const _LabeledField(
            label: 'Experiência Profissional',
            initialValue:
                '- Professor de Matemática (2018-2023)\n- Explicador particular (2020-presente)\n- Mestrado em Ensino de Matemática',
            maxLines: 4,
            height: 94.993,
          ),
          const SizedBox(height: 24.357),
          const _DisciplinesBlock(),
          const SizedBox(height: 24.357),
          Row(
            children: const [
              Expanded(
                child: _LabeledField(
                  label: 'LinkedIn (opcional)',
                  initialValue: 'linkedin.com/in/seu-perfil',
                  hintColor: Color(0xFF717182),
                ),
              ),
              SizedBox(width: 19.486),
              Expanded(
                child: _LabeledField(
                  label: 'Website (opcional)',
                  initialValue: 'www.seusite.com',
                  hintColor: Color(0xFF717182),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30.447),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: PerfilProfessorColors.title,
        fontSize: PerfilProfessorLayout.sectionTitleFontSize,
        fontWeight: FontWeight.w500,
        height: PerfilProfessorLayout.sectionTitleLineHeight /
            PerfilProfessorLayout.sectionTitleFontSize,
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    this.initialValue,
    this.hintText,
    this.maxLines = 1,
    this.height,
    this.hintColor,
  });

  final String label;
  final String? initialValue;
  final String? hintText;
  final int maxLines;
  final double? height;
  final Color? hintColor;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      minLines: maxLines,
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: TextStyle(
          color: hintColor ?? PerfilProfessorColors.title,
          fontSize: PerfilProfessorLayout.inputFontSize,
          fontWeight: FontWeight.w400,
          height: PerfilProfessorLayout.inputLineHeight /
              PerfilProfessorLayout.inputFontSize,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(PerfilProfessorLayout.inputRadius),
        ),
        filled: true,
        fillColor: PerfilProfessorColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14.614,
          vertical: 10.961,
        ),
      ),
      style: const TextStyle(
        color: PerfilProfessorColors.title,
        fontSize: PerfilProfessorLayout.inputFontSize,
        fontWeight: FontWeight.w400,
        height: PerfilProfessorLayout.inputLineHeight /
            PerfilProfessorLayout.inputFontSize,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: PerfilProfessorLayout.labelFontSize,
            fontWeight: FontWeight.w500,
            height: PerfilProfessorLayout.labelLineHeight /
                PerfilProfessorLayout.labelFontSize,
          ),
        ),
        const SizedBox(height: 4.871),
        if (height == null)
          SizedBox(height: PerfilProfessorLayout.inputHeight, child: field)
        else
          SizedBox(height: height, child: field),
      ],
    );
  }
}

class _DisciplinesBlock extends StatelessWidget {
  const _DisciplinesBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Disciplinas Lecionadas',
          style: TextStyle(
            color: Color(0xFF0A0A0A),
            fontSize: PerfilProfessorLayout.labelFontSize,
            fontWeight: FontWeight.w500,
            height: PerfilProfessorLayout.labelLineHeight /
                PerfilProfessorLayout.labelFontSize,
          ),
        ),
        const SizedBox(height: 9.74),
        Wrap(
          spacing: 9.74,
          runSpacing: 9.74,
          children: const [
            _Badge(text: 'Matemática ×'),
            _Badge(text: 'Física ×'),
            _Badge(text: 'Química ×'),
          ],
        ),
        const SizedBox(height: 12.179),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(PerfilProfessorLayout.inputRadius),
          child: Container(
            height: 38.972,
            width: 196.961,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(PerfilProfessorLayout.inputRadius),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.1),
                width: 1.218,
              ),
            ),
            child: const Text(
              '+ Adicionar Disciplina',
              style: TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 17.05,
                fontWeight: FontWeight.w500,
                height: 24.357 / 17.05,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PerfilProfessorColors.badgeBlue,
        borderRadius: BorderRadius.circular(PerfilProfessorLayout.badgeRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14.614,
          vertical: 4.871,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: PerfilProfessorLayout.badgeFontSize,
            fontWeight: FontWeight.w500,
            height: PerfilProfessorLayout.badgeLineHeight /
                PerfilProfessorLayout.badgeFontSize,
          ),
        ),
      ),
    );
  }
}
