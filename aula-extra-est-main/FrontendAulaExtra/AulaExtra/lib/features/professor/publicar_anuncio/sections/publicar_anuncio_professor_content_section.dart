import 'package:aula_extra/core/data/education/dtos/disciplina_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ad_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/professor_ads_form_data_dto.dart';
import 'package:aula_extra/core/data/professor_ads/dtos/tutoring_type_option_dto.dart';
import 'package:aula_extra/core/data/professor_ads/professor_ads_api.dart';
import 'package:aula_extra/core/data/professor_ads/professor_ads_service.dart';
import 'package:aula_extra/core/data/users/users_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/features/home/widgets/full_bleed_scaled_section.dart';
import 'package:aula_extra/features/professor/core/widgets/professor_menu_nav.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/constants/publicar_anuncio_professor_constants.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/widgets/publicar_anuncio_form_card.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/widgets/publicar_anuncio_preview_card.dart';
import 'package:aula_extra/features/professor/publicar_anuncio/widgets/publicar_anuncio_shared_widgets.dart';
import 'package:aula_extra/features/tutor_profile_view/models/tutor_profile_args.dart';
import 'package:aula_extra/routes/routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PublicarAnuncioProfessorContentSection extends StatefulWidget {
  const PublicarAnuncioProfessorContentSection({super.key, this.initialAd});

  final ProfessorAdDto? initialAd;

  @override
  State<PublicarAnuncioProfessorContentSection> createState() =>
      _PublicarAnuncioProfessorContentSectionState();
}

class _PublicarAnuncioProfessorContentSectionState
    extends State<PublicarAnuncioProfessorContentSection> {
  final ProfessorAdsService _adsService = ProfessorAdsService();
  final UsersService _usersService = UsersService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ProfessorAdsFormDataDto? _data;
  bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;
  String? _error;
  String? _selectedDisciplinaId;
  String? _selectedTutoringTypeId;
  String? _photoUrl;

  bool get _isEditing => widget.initialAd != null;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_handlePreviewChanged);
    _priceController.addListener(_handlePreviewChanged);
    _load();
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_handlePreviewChanged);
    _priceController.removeListener(_handlePreviewChanged);
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handlePreviewChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _adsService.getMyData();
      if (!mounted) return;

      setState(() {
        _data = data;
        _loading = false;
      });

      _initializeSelection();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  void _initializeSelection() {
    final data = _data;
    if (data == null) return;

    final initialAd = widget.initialAd;
    final firstDisciplinaId = data.disciplinas
        .cast<DisciplinaDto?>()
        .firstWhere(
          (item) => item?.idDisciplina.trim().isNotEmpty ?? false,
          orElse: () => null,
        )
        ?.idDisciplina;
    final firstTutoringTypeId = data.tutoringTypes
        .cast<TutoringTypeOptionDto?>()
        .firstWhere(
          (item) => item?.idTutoringType.trim().isNotEmpty ?? false,
          orElse: () => null,
        )
        ?.idTutoringType;

    _selectedDisciplinaId = _isEditing
        ? initialAd?.idDisciplina
        : firstDisciplinaId;
    _selectedTutoringTypeId = _isEditing
        ? initialAd?.idTutoringType
        : firstTutoringTypeId;

    if (_isEditing) {
      _descriptionController.text = initialAd?.description ?? '';
      _priceController.text = initialAd?.sessionPrice == null
          ? ''
          : _formatPrice(initialAd!.sessionPrice!);
      _photoUrl = initialAd?.photoUrl ?? data.profilePhotoUrl;
    } else {
      _descriptionController.clear();
      _priceController.clear();
      _photoUrl = data.profilePhotoUrl;
    }

    if (mounted) {
      setState(() {});
    }
  }

  DisciplinaDto? get _selectedDisciplina {
    final data = _data;
    if (data == null || _selectedDisciplinaId == null) return null;

    return data.disciplinas.cast<DisciplinaDto?>().firstWhere(
      (item) => item?.idDisciplina == _selectedDisciplinaId,
      orElse: () => null,
    );
  }

  TutoringTypeOptionDto? get _selectedTutoringType {
    final data = _data;
    if (data == null || _selectedTutoringTypeId == null) return null;

    return data.tutoringTypes.cast<TutoringTypeOptionDto?>().firstWhere(
      (item) => item?.idTutoringType == _selectedTutoringTypeId,
      orElse: () => null,
    );
  }

  ProfessorAdDto? get _selectedAd {
    if (!_isEditing) return null;

    final data = _data;
    if (data == null ||
        _selectedDisciplinaId == null ||
        _selectedTutoringTypeId == null) {
      return null;
    }

    return data.ads.cast<ProfessorAdDto?>().firstWhere(
      (item) =>
          item?.idDisciplina == _selectedDisciplinaId &&
          item?.idTutoringType == _selectedTutoringTypeId,
      orElse: () => null,
    );
  }

  void _syncSelectionState() {
    if (!_isEditing) return;

    final selectedAd = _selectedAd;
    final data = _data;
    if (data == null) return;

    _descriptionController.text = selectedAd?.description ?? '';
    _priceController.text = selectedAd?.sessionPrice == null
        ? ''
        : _formatPrice(selectedAd?.sessionPrice ?? 0);
    _photoUrl = selectedAd?.photoUrl ?? data.profilePhotoUrl;

    if (mounted) {
      setState(() {});
    }
  }

  void _openPublicProfile(String displayName) {
    final ad = _selectedAd ?? widget.initialAd;
    if (ad == null) return;

    Navigator.of(context).pushNamed(
      Routes.tutorProfile,
      arguments: TutorProfileArgs(
        professorId: ad.idProfessor,
        name: displayName,
        country: 'Online',
        rating: 0,
        reviewCount: 0,
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : (ad.description?.trim().isNotEmpty == true
                  ? ad.description!.trim()
                  : 'Professor disponível para novas aulas.'),
        lessonsText: 'Professor Aula Extra',
        pricePerHour:
            (_parsePrice(_priceController.text) ?? ad.sessionPrice ?? 0)
                .round(),
        tags: [
          if ((_selectedDisciplina?.nome ?? ad.disciplinaNome ?? '')
              .trim()
              .isNotEmpty)
            (_selectedDisciplina?.nome ?? ad.disciplinaNome!).trim(),
          if ((_selectedTutoringType?.name ?? ad.tutoringTypeName ?? '')
              .trim()
              .isNotEmpty)
            (_selectedTutoringType?.name ?? ad.tutoringTypeName!).trim(),
        ],
      ),
    );
  }

  String _formatPrice(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  double? _parsePrice(String raw) {
    final normalized = raw
        .trim()
        .replaceAll('€', '')
        .replaceAll(' ', '')
        .replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  Future<void> _pickPhoto() async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
    );

    final file = picked == null || picked.files.isEmpty
        ? null
        : picked.files.first;
    if (file == null || file.bytes == null) return;

    if (file.bytes!.length > PublicarAnuncioProfessorConfig.maxFileSizeBytes) {
      _showSnackBar('A imagem deve ter no máximo 5MB.');
      return;
    }

    setState(() => _uploadingPhoto = true);
    try {
      final uploaded = await _usersService.uploadMyProfileImage(
        bytes: file.bytes!,
        fileName: file.name,
      );
      if (!mounted) return;

      final uploadedUrl = uploaded.profileImageUrl?.trim();
      setState(() {
        _photoUrl = uploadedUrl;
        final data = _data;
        if (data != null) {
          _data = ProfessorAdsFormDataDto(
            profilePhotoUrl: uploadedUrl,
            disciplinas: data.disciplinas,
            tutoringTypes: data.tutoringTypes,
            ads: data.ads,
          );
        }
        _uploadingPhoto = false;
      });

      final provider = context.read<UserProvider>();
      final account = provider.account;
      if (account != null) {
        provider.setAccount(account.copyWith(profileImageUrl: uploadedUrl));
      }

      _showSnackBar('Foto atualizada com sucesso.');
    } catch (error) {
      if (!mounted) return;
      setState(() => _uploadingPhoto = false);
      _showSnackBar('Não foi possível carregar a foto: $error');
    }
  }

  Future<void> _saveAd() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDisciplinaId == null || _selectedTutoringTypeId == null) {
      _showSnackBar('Selecione a disciplina e o tipo de aula.');
      return;
    }

    final price = _parsePrice(_priceController.text);
    if (price == null || price <= 0) {
      _showSnackBar('Introduza um preço válido.');
      return;
    }

    setState(() => _saving = true);
    try {
      final saved = await _adsService.upsertMyAd(
        idDisciplina: _selectedDisciplinaId!,
        idTutoringType: _selectedTutoringTypeId!,
        sessionPrice: price,
        description: _descriptionController.text,
        photoUrl: _photoUrl,
      );
      if (!mounted) return;

      final data = _data;
      if (data != null) {
        final updatedAds =
            data.ads
                .where(
                  (item) =>
                      !(item.idDisciplina == saved.idDisciplina &&
                          item.idTutoringType == saved.idTutoringType),
                )
                .toList(growable: true)
              ..insert(0, saved);

        setState(() {
          _data = ProfessorAdsFormDataDto(
            profilePhotoUrl: _photoUrl ?? data.profilePhotoUrl,
            disciplinas: data.disciplinas,
            tutoringTypes: data.tutoringTypes,
            ads: updatedAds,
          );
          _saving = false;
        });
      } else {
        setState(() => _saving = false);
      }

      _showSnackBar(
        _isEditing
            ? 'Anúncio atualizado com sucesso.'
            : 'Anúncio publicado com sucesso.',
      );
    } on ProfessorAdsException catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnackBar(error.message);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnackBar('Não foi possível publicar o anúncio: $error');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final account = context.watch<UserProvider>().account;
    final displayName = (account?.fullName?.trim().isNotEmpty ?? false)
        ? account!.fullName!.trim()
        : (account?.username?.trim().isNotEmpty ?? false)
        ? account!.username!.trim()
        : 'Professor';

    return Container(
      color: PublicarAnuncioProfessorColors.pageBackground,
      child: FullBleedScaledSection(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(42, 42, 42, 56),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final showSidebar = constraints.maxWidth >= 1180;
              final splitCards = constraints.maxWidth >= 980;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSidebar) ...[
                    const ProfessorMenuNav(selectedIndex: 5),
                    const SizedBox(width: 28),
                  ],
                  Expanded(
                    child: _buildContent(
                      context,
                      displayName: displayName,
                      splitCards: splitCards,
                      showSidebar: showSidebar,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context, {
    required String displayName,
    required bool splitCards,
    required bool showSidebar,
  }) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return PublicarAnuncioStateCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Não foi possível carregar a página.',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: PublicarAnuncioProfessorColors.title,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: PublicarAnuncioProfessorColors.mutedText,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: _load,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final data = _data;
    if (data == null) {
      return const SizedBox.shrink();
    }

    if (data.disciplinas.isEmpty) {
      return PublicarAnuncioStateCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Primeiro adicione uma disciplina.',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: PublicarAnuncioProfessorColors.title,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Só pode publicar anúncios para disciplinas já configuradas em Minhas Disciplinas.',
              style: TextStyle(
                fontSize: 15,
                color: PublicarAnuncioProfessorColors.mutedText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(Routes.professorMinhasDisciplinas),
              child: const Text('Ir para Minhas Disciplinas'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isEditing ? 'Editar Anúncio' : 'Publicar Anúncio',
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: PublicarAnuncioProfessorColors.title,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _isEditing
              ? 'Atualize os campos do anúncio selecionado. O nível de ensino continua bloqueado automaticamente pela disciplina.'
              : 'Selecione uma das suas disciplinas, confirme o tipo de aula e publique o anúncio com o nível de ensino bloqueado automaticamente.',
          style: const TextStyle(
            fontSize: 15,
            color: PublicarAnuncioProfessorColors.mutedText,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        if (!showSidebar)
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: ProfessorMenuNav(selectedIndex: 5),
          ),
        if (splitCards)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildFormCard()),
              const SizedBox(width: 24),
              SizedBox(width: 420, child: _buildPreviewCard(displayName)),
            ],
          )
        else ...[
          _buildFormCard(),
          const SizedBox(height: 24),
          _buildPreviewCard(displayName),
        ],
      ],
    );
  }

  Widget _buildFormCard() {
    final data = _data;
    return PublicarAnuncioFormCard(
      formKey: _formKey,
      disciplinas: data?.disciplinas ?? const <DisciplinaDto>[],
      tutoringTypes: data?.tutoringTypes ?? const <TutoringTypeOptionDto>[],
      selectedDisciplinaId: _selectedDisciplinaId,
      selectedTutoringTypeId: _selectedTutoringTypeId,
      selectedDisciplina: _selectedDisciplina,
      descriptionController: _descriptionController,
      priceController: _priceController,
      uploadingPhoto: _uploadingPhoto,
      photoUrl: _photoUrl,
      saving: _saving,
      isEditing: _isEditing,
      inputDecoration: _inputDecoration,
      parsePrice: _parsePrice,
      onDisciplinaChanged: (value) {
        setState(() => _selectedDisciplinaId = value);
        _syncSelectionState();
      },
      onTutoringTypeChanged: (value) {
        setState(() => _selectedTutoringTypeId = value);
        _syncSelectionState();
      },
      onPickPhoto: _pickPhoto,
      onSave: _saveAd,
    );
  }

  Widget _buildPreviewCard(String displayName) {
    final selectedDisciplina = _selectedDisciplina;
    final selectedType = _selectedTutoringType;
    final selectedAd = _selectedAd;
    final description = _descriptionController.text.trim().isEmpty
        ? 'Adicione uma descrição para mostrar como ensina e o valor da sua experiência.'
        : _descriptionController.text.trim();
    final price = _parsePrice(_priceController.text);

    return PublicarAnuncioPreviewCard(
      displayName: displayName,
      selectedDisciplina: selectedDisciplina,
      selectedType: selectedType,
      selectedAd: selectedAd,
      description: description,
      formattedPrice: price == null ? '—€' : '${_formatPrice(price)}€',
      photoUrl: _photoUrl,
      onViewProfile: () => _openPublicProfile(displayName),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: PublicarAnuncioProfessorColors.surfaceBorder,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: PublicarAnuncioProfessorColors.surfaceBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: PublicarAnuncioProfessorColors.accent,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
    );
  }
}
