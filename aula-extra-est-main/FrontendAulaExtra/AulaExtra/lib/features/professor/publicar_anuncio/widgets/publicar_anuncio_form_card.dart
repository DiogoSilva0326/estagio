import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/tutoring_type_option_dto.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/constants/publicar_anuncio_professor_constants.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/widgets/publicar_anuncio_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:aula_extra/core/providers/user_provider.dart'; 
import 'package:aula_extra/core/config/teaching_roles_config.dart'; 

class PublicarAnuncioFormCard extends StatefulWidget {
  const PublicarAnuncioFormCard({
    required this.formKey,
    required this.disciplinas,
    required this.tutoringTypes,
    required this.selectedDisciplinaId,
    required this.selectedTutoringTypeId,
    required this.selectedDisciplina,
    required this.descriptionController,
    required this.priceController,
    required this.uploadingPhoto,
    required this.photoUrl,
    required this.saving,
    required this.isEditing,
    required this.isMobile,
    required this.inputDecoration,
    required this.parsePrice,
    required this.onDisciplinaChanged,
    required this.onTutoringTypeChanged,
    required this.onPickPhoto,
    required this.onSave,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final List<DisciplinaDto> disciplinas;
  final List<TutoringTypeOptionDto> tutoringTypes;
  final String? selectedDisciplinaId;
  final String? selectedTutoringTypeId;
  final DisciplinaDto? selectedDisciplina;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final bool uploadingPhoto;
  final String? photoUrl;
  final bool saving;
  final bool isEditing;
  final bool isMobile;
  final InputDecoration Function(String hint) inputDecoration;
  final double? Function(String raw) parsePrice;
  final ValueChanged<String?> onDisciplinaChanged;
  final ValueChanged<String?> onTutoringTypeChanged;
  final VoidCallback onPickPhoto;
  final VoidCallback onSave;

  @override
  State<PublicarAnuncioFormCard> createState() =>
      _PublicarAnuncioFormCardState();
}

class _PublicarAnuncioFormCardState extends State<PublicarAnuncioFormCard> {
  bool _crianca = false;
  bool _adolescente = false;
  bool _adulto = false;
  bool _senior = false;
  bool _todos = false;

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged, Color primaryColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1D2838),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final config = TeachingRoleConfig.fromRole(userProvider.role);
    
    final isExplicador = config.roleName == 'Explicador';
    final subjectLabel = isExplicador ? 'Disciplina' : 'Especialidade';

    return PublicarAnuncioSurfaceCard(
      padding: EdgeInsets.all(
        widget.isMobile ? PublicarAnuncioProfessorLayout.mobileCardPadding : 28,
      ),
      radius: widget.isMobile ? PublicarAnuncioProfessorLayout.mobileCardRadius : 28,
      child: Form(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Anúncio',
              style: TextStyle(
                fontSize: widget.isMobile ? 22 : 26,
                fontWeight: FontWeight.w700,
                color: PublicarAnuncioProfessorColors.title,
              ),
            ),
            SizedBox(height: widget.isMobile ? 18 : 22),

            PublicarAnuncioFieldLabel(subjectLabel),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: widget.selectedDisciplinaId,
              decoration: widget.inputDecoration('Selecione a $subjectLabel'),
              items: widget.disciplinas
                  .map(
                    (disciplina) => DropdownMenuItem<String>(
                      value: disciplina.idDisciplina,
                      child: Text(disciplina.nome),
                    ),
                  )
                  .toList(growable: false),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Selecione a $subjectLabel.'
                  : null,
              onChanged: widget.onDisciplinaChanged,
            ),
            const SizedBox(height: 18),

            PublicarAnuncioFieldLabel(isExplicador ? 'Tipo de aula' : 'Formato da sessão'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: widget.selectedTutoringTypeId,
              decoration: widget.inputDecoration('Selecione o formato'),
              items: widget.tutoringTypes
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.idTutoringType,
                      child: Text(item.name),
                    ),
                  )
                  .toList(growable: false),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Selecione o formato.'
                  : null,
              onChanged: widget.onTutoringTypeChanged,
            ),
            const SizedBox(height: 18),

            if (isExplicador) ...[
              const PublicarAnuncioFieldLabel('Nível de Ensino'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PublicarAnuncioProfessorColors.surfaceBorder,
                  ),
                ),
                child: Text(
                  widget.selectedDisciplina?.cicloEstudosLabel ?? 'Sem nível de ensino',
                  style: const TextStyle(
                    fontSize: 14,
                    color: PublicarAnuncioProfessorColors.title,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ] else ...[
              const PublicarAnuncioFieldLabel('Faixa etária'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 24, 
                runSpacing: 16, 
                children: [
                  _buildCheckbox('Criança', _crianca, (v) => setState(() => _crianca = v ?? false), config.primaryColor),
                  _buildCheckbox('Adolescente', _adolescente, (v) => setState(() => _adolescente = v ?? false), config.primaryColor),
                  _buildCheckbox('Adulto', _adulto, (v) => setState(() => _adulto = v ?? false), config.primaryColor),
                  _buildCheckbox('Sénior', _senior, (v) => setState(() => _senior = v ?? false), config.primaryColor),
                  _buildCheckbox('Todos', _todos, (v) => setState(() => _todos = v ?? false), config.primaryColor),
                ],
              ),
            ],

            const SizedBox(height: 18),
            const PublicarAnuncioFieldLabel('Descrição'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.descriptionController,
              minLines: 4,
              maxLines: 5,
              decoration: widget.inputDecoration(
                'Descreva a sua experiência e metodologia...',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Descreva o anúncio.';
                }
                if (value.trim().length < 20) {
                  return 'Use pelo menos 20 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            const PublicarAnuncioFieldLabel('Preço por total (€)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: widget.inputDecoration('Ex: 25'),
              validator: (value) {
                final price = widget.parsePrice(value ?? '');
                if (price == null || price <= 0) {
                  return 'Introduza um preço válido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            const PublicarAnuncioFieldLabel('Foto de Perfil'),
            const SizedBox(height: 8),
            InkWell(
              onTap: widget.uploadingPhoto ? null : widget.onPickPhoto,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: PublicarAnuncioProfessorColors.surfaceBorder,
                  ),
                ),
                child: Column(
                  children: [
                    PublicarAnuncioProfileAvatar(photoUrl: widget.photoUrl, size: 88),
                    const SizedBox(height: 14),
                    Text(
                      widget.uploadingPhoto
                          ? 'A carregar foto...'
                          : 'Clique para atualizar a foto',
                      style: const TextStyle(
                        color: PublicarAnuncioProfessorColors.title,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'PNG, JPG ou WEBP até 5MB. Se já tiver foto de perfil, ela é usada automaticamente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PublicarAnuncioProfessorColors.mutedText,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: widget.isMobile ? 48 : 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isExplicador ? null : config.primaryColor,
                  gradient: isExplicador
                      ? const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFFB923C)],
                        )
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.saving ? null : widget.onSave,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: widget.saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.isEditing
                                  ? 'Guardar Alterações'
                                  : 'Publicar Anúncio',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.isMobile ? 15 : 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}