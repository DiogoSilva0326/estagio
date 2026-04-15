import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/tutoring_type_option_dto.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/constants/publicar_anuncio_professor_constants.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/widgets/publicar_anuncio_shared_widgets.dart';
import 'package:flutter/material.dart';

class PublicarAnuncioFormCard extends StatelessWidget {
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
  final InputDecoration Function(String hint) inputDecoration;
  final double? Function(String raw) parsePrice;
  final ValueChanged<String?> onDisciplinaChanged;
  final ValueChanged<String?> onTutoringTypeChanged;
  final VoidCallback onPickPhoto;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return PublicarAnuncioSurfaceCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações do Anúncio',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: PublicarAnuncioProfessorColors.title,
              ),
            ),
            const SizedBox(height: 22),
            const PublicarAnuncioFieldLabel('Disciplina'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedDisciplinaId,
              decoration: inputDecoration('Selecione a disciplina'),
              items: disciplinas
                  .map(
                    (disciplina) => DropdownMenuItem<String>(
                      value: disciplina.idDisciplina,
                      child: Text(disciplina.nome),
                    ),
                  )
                  .toList(growable: false),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Selecione a disciplina.'
                  : null,
              onChanged: onDisciplinaChanged,
            ),
            const SizedBox(height: 18),
            const PublicarAnuncioFieldLabel('Tipo de aula'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedTutoringTypeId,
              decoration: inputDecoration('Selecione o tipo de aula'),
              items: tutoringTypes
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item.idTutoringType,
                      child: Text(item.name),
                    ),
                  )
                  .toList(growable: false),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Selecione o tipo de aula.'
                  : null,
              onChanged: onTutoringTypeChanged,
            ),
            const SizedBox(height: 18),
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
                selectedDisciplina?.cicloEstudosLabel ?? 'Sem nível de ensino',
                style: const TextStyle(
                  fontSize: 14,
                  color: PublicarAnuncioProfessorColors.title,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const PublicarAnuncioFieldLabel('Descrição'),
            const SizedBox(height: 8),
            TextFormField(
              controller: descriptionController,
              minLines: 4,
              maxLines: 5,
              decoration: inputDecoration(
                'Descreva a sua experiência e metodologia de ensino...',
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
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: inputDecoration('Ex: 25'),
              validator: (value) {
                final price = parsePrice(value ?? '');
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
              onTap: uploadingPhoto ? null : onPickPhoto,
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
                    PublicarAnuncioProfileAvatar(photoUrl: photoUrl, size: 88),
                    const SizedBox(height: 14),
                    Text(
                      uploadingPhoto
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
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFFB923C)],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: saving ? null : onSave,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: saving
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
                              isEditing
                                  ? 'Guardar Alterações'
                                  : 'Publicar Anúncio',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
