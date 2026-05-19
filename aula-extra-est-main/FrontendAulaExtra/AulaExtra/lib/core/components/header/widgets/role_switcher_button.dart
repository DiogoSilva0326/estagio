import 'package:aula_extra/core/data/auth/available_roles.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aula_extra/core/data/session/preferences_service.dart';
import 'package:aula_extra/routes/routes.dart';

class RoleSwitcherButton extends StatefulWidget {
  const RoleSwitcherButton({super.key, this.size = 32});

  final double size;

  @override
  State<RoleSwitcherButton> createState() => _RoleSwitcherButtonState();
}

class _RoleSwitcherButtonState extends State<RoleSwitcherButton> {
  Set<Role>? _availableRoles;

  @override
  void initState() {
    super.initState();
    _loadAvailableRoles();
  }

  Future<void> _loadAvailableRoles() async {
    try {
      final available = await AvailableRoles.fetch();

      if (!mounted) return;
      setState(() => _availableRoles = available);
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
    final allowedRoles = (available == null) ? <Role>{currentRole} : {...available, currentRole};

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
          Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
        } else if (role == Role.teacher) {
          Navigator.of(context).pushNamedAndRemoveUntil(Routes.professorCalendario, (route) => false);
        } else if (role == Role.tutor) {
          Navigator.of(context).pushNamedAndRemoveUntil(Routes.professorCalendario, (route) => false); 
        } else if (role == Role.psychologist) {
          Navigator.of(context).pushNamedAndRemoveUntil(Routes.professorCalendario, (route) => false);
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
