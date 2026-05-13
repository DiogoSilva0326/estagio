import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/data/session/preferences_service.dart';

class RoleSwitcherButton extends StatefulWidget {
  const RoleSwitcherButton({super.key, this.size = 32});

  final double size;

  @override
  State<RoleSwitcherButton> createState() => _RoleSwitcherButtonState();
}

class _RoleSwitcherButtonState extends State<RoleSwitcherButton> {
  final TokenStorage _tokenStorage = TokenStorage();

  Set<Role>? _availableRoles;

  @override
  void initState() {
    super.initState();
    _loadAvailableRoles();
  }

  Future<void> _loadAvailableRoles() async {
    try {
      final token = await _tokenStorage.loadToken();
      if (token == null || token.trim().isEmpty) {
        setState(() => _availableRoles = {Role.none});
        return;
      }

      // 1. Pedimos ao backend as roles REAIS do Pedro
      final session = await AuthService(tokenStorage: _tokenStorage).refresh();
      final roles = session.backendRoles;

      final normalized = roles.map((r) => r.trim().toLowerCase()).toSet();
      final hasTeacher = normalized.contains('professor') || normalized.contains('teacher') || normalized.contains('admin');
      final hasTutor = normalized.contains('tutor');
      final hasPsychologist = normalized.contains('psicologo') || normalized.contains('psychologist');

      // 2. Definimos o que aparece no menu. 
      // Se for professor, libertamos tudo para podermos testar as interfaces.
      final available = <Role>{Role.student};
      if (hasTeacher) {
        available.add(Role.teacher);
        available.add(Role.tutor);
        available.add(Role.psychologist);
      } else {
        if (hasTutor) available.add(Role.tutor);
        if (hasPsychologist) available.add(Role.psychologist);
      }

      if (!mounted) return;
      setState(() => _availableRoles = available);

      // --- REMOVI AQUI O AuthService.applySessionToProvider ---
      // Deixamos o UserProvider sossegado com a escolha que fizemos manualmente.

    } catch (_) {
      if (!mounted) return;
      setState(() => _availableRoles = {Role.none});
    }
  }

  String _label(Role role) {
    switch (role) {
      case Role.none:
        return 'Sem login';
      case Role.student:
        return 'Aluno';
      case Role.teacher:
        return 'Explicador';
      case Role.tutor:
        return 'Tutor';
      case Role.psychologist:
        return 'Psicólogo';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = context.watch<UserProvider>().role;

    final available = _availableRoles;
    final allowedRoles = (available == null) ? <Role>{currentRole} : available;

    // Never allow switching to Role.none through UI (logout should clear token).
    final menuRoles = allowedRoles.where((r) => r != Role.none).toList();
    final canSwitch = menuRoles.length > 1;

    return PopupMenuButton<Role>(
      tooltip: 'Mudar role',
      initialValue: currentRole,
      enabled: canSwitch,
      onSelected: (role) async {
        if (!allowedRoles.contains(role)) return;
        
        final currentRole = context.read<UserProvider>().role;
        if (currentRole == role) return;

        context.read<UserProvider>().setRole(role);
        await PreferencesService.savePreferredRole(role.name);

        if (role == Role.student) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else if (role == Role.teacher) {
          Navigator.of(context).pushNamedAndRemoveUntil('/professor/calendario', (route) => false);
        } else if (role == Role.tutor) {
          Navigator.of(context).pushNamedAndRemoveUntil('/professor/calendario', (route) => false); 
        } else if (role == Role.psychologist) {
          Navigator.of(context).pushNamedAndRemoveUntil('/professor/calendario', (route) => false);
        }
      },
      itemBuilder: (context) {
        return menuRoles
            .map(
              (role) => PopupMenuItem<Role>(
                value: role,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: Text(_label(role))),
                    if (role == currentRole) ...[
                      const SizedBox(width: 12),
                      const Icon(Icons.check, size: 16),
                    ],
                  ],
                ),
              ),
            )
            .toList();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
        child: const Center(
          child: Icon(Icons.swap_horiz, size: 18, color: Colors.black),
        ),
      ),
    );
  }
}
