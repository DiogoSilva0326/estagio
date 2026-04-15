import 'package:aula_extra/core/data/session/token_storage.dart';
import 'package:aula_extra/core/data/auth/auth_service.dart';
import 'package:aula_extra/core/providers/user_provider.dart';
import 'package:aula_extra/core/session/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        if (!mounted) return;
        setState(() => _availableRoles = {Role.none});

        final userProvider = context.read<UserProvider>();
        if (userProvider.role != Role.none || userProvider.account != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            userProvider.setAccount(null);
            userProvider.setRole(Role.none);
          });
        }
        return;
      }

      // Source of truth: ask backend to re-issue token with CURRENT DB roles.
      // This prevents stale tokens from exposing professor UI.
      AuthSession? session;
      List<String> roles;
      try {
        session = await AuthService(tokenStorage: _tokenStorage).refresh();
        roles = session.backendRoles;

        if (!mounted) return;
        AuthService.applySessionToProvider(
          context.read<UserProvider>(),
          session,
        );
      } catch (_) {
        await SessionManager.instance.handleExpiredSession();
        return;
      }

      if (roles.isEmpty) {
        final available = <Role>{Role.student};
        if (!mounted) return;
        setState(() => _availableRoles = available);

        final current = context.read<UserProvider>().role;
        if (!available.contains(current)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<UserProvider>().setRole(Role.student);
          });
        }
        return;
      }

      final normalized = roles
          .map((r) => r.trim().toLowerCase())
          .where((r) => r.isNotEmpty)
          .toSet();
      final hasTeacher =
          normalized.contains('professor') ||
          normalized.contains('teacher') ||
          normalized.contains('admin');

      // All authenticated users can use the app as student.
      // Only users with professor/admin role can switch to teacher.
      final available = <Role>{Role.student};
      if (hasTeacher) available.add(Role.teacher);

      if (available.isEmpty) {
        available.add(Role.none);
      }

      if (!mounted) return;
      setState(() => _availableRoles = available);

      final current = context.read<UserProvider>().role;
      if (!available.contains(current)) {
        final fallback = available.contains(Role.student)
            ? Role.student
            : (available.contains(Role.teacher) ? Role.teacher : Role.none);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<UserProvider>().setRole(fallback);
        });
      }
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
      onSelected: (role) {
        // Only allow switching to roles granted by backend.
        if (!allowedRoles.contains(role)) return;
        context.read<UserProvider>().setRole(role);
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
