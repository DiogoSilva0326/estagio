import 'package:aula_extra/core/data/education/dtos/area_dto.dart';
import 'package:aula_extra/core/data/education/dtos/ciclo_estudo_dto.dart';
import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/features/professor/minhas_disciplinas/constants/minhas_disciplinas_professor_colors.dart';
import 'package:flutter/material.dart';

class ProfessorDisciplinaDialogResult {
  const ProfessorDisciplinaDialogResult({
    this.idDisciplina,
    required this.idArea,
    required this.idCicloEstudo,
    required this.nome,
    this.descricao,
  });

  final String? idDisciplina;
  final String idArea;
  final String idCicloEstudo;
  final String nome;
  final String? descricao;
}

class ProfessorDisciplinaDialog extends StatefulWidget {
  const ProfessorDisciplinaDialog({
    super.key,
    required this.areas,
    required this.ciclos,
    required this.catalog,
    this.initialDisciplina,
  });

  final List<AreaDto> areas;
  final List<CicloEstudoDto> ciclos;
  final List<DisciplinaDto> catalog;
  final DisciplinaDto? initialDisciplina;

  @override
  State<ProfessorDisciplinaDialog> createState() =>
      _ProfessorDisciplinaDialogState();
}

class _ProfessorDisciplinaDialogState extends State<ProfessorDisciplinaDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();

  String? _selectedAreaId;
  String? _selectedCicloId;
  String? _selectedCatalogDisciplinaId;

  bool get _isEditing => widget.initialDisciplina != null;

  List<AreaDto> get _sortedAreas {
    final items = [...widget.areas];
    items.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return items;
  }

  List<CicloEstudoDto> get _sortedCiclos {
    final items = [...widget.ciclos];
    items.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return items;
  }

  List<DisciplinaDto> get _filteredCatalog {
    final query = _nomeController.text.trim().toLowerCase();
    final items = widget.catalog
        .where((disciplina) {
          if (_selectedAreaId != null && disciplina.idArea != _selectedAreaId) {
            return false;
          }

          if (query.isEmpty) return true;
          return disciplina.nome.toLowerCase().contains(query);
        })
        .toList(growable: false);

    final sorted = [...items];
    sorted.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return sorted.take(6).toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDisciplina;
    _selectedAreaId = initial?.idArea;
    _selectedCicloId = initial?.idCicloEstudo;
    _selectedCatalogDisciplinaId = initial?.idDisciplina;
    _nomeController.text = initial?.nome ?? '';
    _descricaoController.text = initial?.descricao ?? '';
    _nomeController.addListener(_handleNomeChanged);
  }

  @override
  void dispose() {
    _nomeController
      ..removeListener(_handleNomeChanged)
      ..dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  void _handleNomeChanged() {
    final selected = widget.catalog.cast<DisciplinaDto?>().firstWhere(
      (item) => item?.idDisciplina == _selectedCatalogDisciplinaId,
      orElse: () => null,
    );

    if (selected == null) {
      setState(() {});
      return;
    }

    if (selected.nome.trim().toLowerCase() !=
        _nomeController.text.trim().toLowerCase()) {
      setState(() {
        _selectedCatalogDisciplinaId = null;
      });
      return;
    }

    setState(() {});
  }

  void _selectCatalogDisciplina(DisciplinaDto disciplina) {
    setState(() {
      _selectedCatalogDisciplinaId = disciplina.idDisciplina;
      _selectedAreaId = disciplina.idArea ?? _selectedAreaId;
      _nomeController.text = disciplina.nome;
      if (_descricaoController.text.trim().isEmpty &&
          (disciplina.descricao?.trim().isNotEmpty ?? false)) {
        _descricaoController.text = disciplina.descricao!.trim();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _filteredCatalog;

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
          child: Form(
            key: _formKey,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final useTwoColumns = constraints.maxWidth >= 820;
                final fieldWidth = useTwoColumns
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;
                final stackActions = constraints.maxWidth < 520;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isEditing
                                      ? 'Editar disciplina'
                                      : 'Criar disciplina',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: MinhasDisciplinasProfessorColors
                                        .dialogTitle,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Defina a área, a disciplina e o ciclo de estudos para guardar corretamente no seu perfil.',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    color: MinhasDisciplinasProfessorColors
                                        .dialogText,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: fieldWidth,
                            child: _buildLabeledField(
                              label: 'Área',
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedAreaId,
                                decoration: _inputDecoration(
                                  hint: 'Selecione a área',
                                ),
                                items: _sortedAreas
                                    .map(
                                      (area) => DropdownMenuItem<String>(
                                        value: area.idArea,
                                        child: Text(area.nome),
                                      ),
                                    )
                                    .toList(growable: false),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Selecione a área.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _selectedAreaId = value;
                                    final selected = widget.catalog
                                        .cast<DisciplinaDto?>()
                                        .firstWhere(
                                          (item) =>
                                              item?.idDisciplina ==
                                              _selectedCatalogDisciplinaId,
                                          orElse: () => null,
                                        );
                                    if (selected != null &&
                                        selected.idArea != value) {
                                      _selectedCatalogDisciplinaId = null;
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: fieldWidth,
                            child: _buildLabeledField(
                              label: 'Ciclo de estudos',
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCicloId,
                                decoration: _inputDecoration(
                                  hint: 'Selecione o ciclo',
                                ),
                                items: _sortedCiclos
                                    .map(
                                      (ciclo) => DropdownMenuItem<String>(
                                        value: ciclo.idCicloEstudo,
                                        child: Text(ciclo.nome),
                                      ),
                                    )
                                    .toList(growable: false),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Selecione o ciclo de estudos.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCicloId = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Disciplina',
                        child: TextFormField(
                          controller: _nomeController,
                          decoration: _inputDecoration(
                            hint: 'Escreva ou escolha uma disciplina existente',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Introduza o nome da disciplina.';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              MinhasDisciplinasProfessorColors.dialogSurfaceAlt,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: MinhasDisciplinasProfessorColors
                                .dialogSurfaceAltBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _selectedCatalogDisciplinaId == null
                                      ? Icons.edit_note_rounded
                                      : Icons.library_books_outlined,
                                  size: 18,
                                  color:
                                      MinhasDisciplinasProfessorColors.subtitle,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCatalogDisciplinaId == null
                                      ? 'Nova disciplina personalizada'
                                      : 'Disciplina existente selecionada',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: MinhasDisciplinasProfessorColors
                                        .dialogInfoTitle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (suggestions.isEmpty)
                              const Text(
                                'Sem sugestões para a área selecionada. Pode guardar como nova disciplina.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: MinhasDisciplinasProfessorColors
                                      .dialogInfoText,
                                ),
                              )
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: suggestions
                                    .map(
                                      (disciplina) => ActionChip(
                                        label: Text(disciplina.nome),
                                        onPressed: () =>
                                            _selectCatalogDisciplina(
                                              disciplina,
                                            ),
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLabeledField(
                        label: 'Descrição',
                        child: TextFormField(
                          controller: _descricaoController,
                          minLines: 3,
                          maxLines: 5,
                          decoration: _inputDecoration(
                            hint: 'Descrição opcional para contexto adicional',
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (stackActions) ...[
                        _buildSecondaryDialogButton(
                          label: 'Cancelar',
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 12),
                        _buildPrimaryDialogButton(
                          label: 'Guardar',
                          onTap: _submit,
                        ),
                      ] else
                        Row(
                          children: [
                            Expanded(
                              child: _buildSecondaryDialogButton(
                                label: 'Cancelar',
                                onTap: () => Navigator.of(context).pop(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildPrimaryDialogButton(
                                label: 'Guardar',
                                onTap: _submit,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      ProfessorDisciplinaDialogResult(
        idDisciplina: _selectedCatalogDisciplinaId,
        idArea: _selectedAreaId!,
        idCicloEstudo: _selectedCicloId!,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim().isEmpty
            ? null
            : _descricaoController.text.trim(),
      ),
    );
  }

  Widget _buildLabeledField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: MinhasDisciplinasProfessorColors.dialogText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildSecondaryDialogButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: MinhasDisciplinasProfessorColors.dialogCancelBorder,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MinhasDisciplinasProfessorColors.dialogText,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
            letterSpacing: -0.31,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryDialogButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.0, 0.5),
            end: Alignment(1.0, 0.5),
            colors: MinhasDisciplinasProfessorColors.dialogGradient,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  letterSpacing: -0.31,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: MinhasDisciplinasProfessorColors.dialogHint,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: MinhasDisciplinasProfessorColors.dialogBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: MinhasDisciplinasProfessorColors.dialogBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFC9039), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
