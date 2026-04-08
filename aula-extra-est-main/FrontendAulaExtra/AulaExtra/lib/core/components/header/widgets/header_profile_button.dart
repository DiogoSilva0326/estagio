import 'package:flutter/material.dart';

enum _ProfileMenuAction {
  logout,
}

class HeaderProfileButton extends StatelessWidget {
  const HeaderProfileButton({
    super.key,
    this.onTap,
    this.onLogoutTap,
    this.imageUrl,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLogoutTap;
  final String? imageUrl;

  static const double size = 35;
  static const double _iconSize = 24;
  static const Color _iconColor = Color(0xFF1D1B20);

  Widget _buildIcon() {
    final url = imageUrl?.trim();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _iconColor.withValues(alpha: 0.18),
          width: 1,
        ),
      ),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.person,
                size: _iconSize,
                color: _iconColor,
              ),
            )
          : const Icon(
              Icons.person,
              size: _iconSize,
              color: _iconColor,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (onLogoutTap == null) {
      return InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: _buildIcon(),
      );
    }

    return PopupMenuButton<_ProfileMenuAction>(
      tooltip: '',
      offset: const Offset(0, 40),
      onSelected: (action) {
        switch (action) {
          case _ProfileMenuAction.logout:
            onLogoutTap?.call();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem<_ProfileMenuAction>(
          value: _ProfileMenuAction.logout,
          child: Text('Logout'),
        ),
      ],
      child: _buildIcon(),
    );
  }
}
