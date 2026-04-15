import 'package:flutter/material.dart';

Future<bool?> showAppConfirmationDialog(
  BuildContext context, {
  required String title,
  required Widget content,
  required String confirmLabel,
  String cancelLabel = 'Cancelar',
  IconData icon = Icons.delete_outline_rounded,
  List<Color>? confirmGradient = const [Color(0xFFF15C64), Color(0xFFFC9039)],
  Color? confirmColor,
  bool inlineHeader = false,
  Color iconColor = const Color(0xFFFB2C36),
  Color iconBackgroundColor = const Color(0xFFFFF1F2),
  Color iconBorderColor = const Color(0xFFFECACA),
  bool showIconBorder = true,
  double iconContainerRadius = 16,
  double iconContainerSize = 52,
  Color titleColor = const Color(0xFF111827),
  Color textColor = const Color(0xFF4B5563),
  Color cancelBorderColor = const Color(0xFFE5E7EB),
  Color cancelTextColor = const Color(0xFF374151),
  Color closeIconColor = const Color(0xFF6B7280),
  bool barrierDismissible = true,
  double maxWidth = 520,
  double? width,
  double? height,
  double borderRadius = 28,
  EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(28, 28, 28, 24),
  EdgeInsetsGeometry contentPadding = EdgeInsets.zero,
  double headerBottomSpacing = 12,
  double actionsTopSpacing = 28,
  double actionButtonHeight = 42,
  double actionSpacing = 12,
  bool forceHorizontalActions = false,
  TextStyle? titleStyle,
  TextStyle? textStyle,
  TextStyle? cancelTextStyle,
  TextStyle? confirmTextStyle,
  double iconSize = 24,
  double closeButtonSize = 36,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => AppConfirmationDialog(
      title: title,
      content: content,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      icon: icon,
      confirmGradient: confirmGradient,
      confirmColor: confirmColor,
      inlineHeader: inlineHeader,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
      iconBorderColor: iconBorderColor,
      showIconBorder: showIconBorder,
      iconContainerRadius: iconContainerRadius,
      iconContainerSize: iconContainerSize,
      titleColor: titleColor,
      textColor: textColor,
      cancelBorderColor: cancelBorderColor,
      cancelTextColor: cancelTextColor,
      closeIconColor: closeIconColor,
      maxWidth: maxWidth,
      width: width,
      height: height,
      borderRadius: borderRadius,
      padding: padding,
      contentPadding: contentPadding,
      headerBottomSpacing: headerBottomSpacing,
      actionsTopSpacing: actionsTopSpacing,
      actionButtonHeight: actionButtonHeight,
      actionSpacing: actionSpacing,
      forceHorizontalActions: forceHorizontalActions,
      titleStyle: titleStyle,
      textStyle: textStyle,
      cancelTextStyle: cancelTextStyle,
      confirmTextStyle: confirmTextStyle,
      iconSize: iconSize,
      closeButtonSize: closeButtonSize,
    ),
  );
}

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmLabel,
    this.cancelLabel = 'Cancelar',
    this.icon = Icons.delete_outline_rounded,
    this.confirmGradient = const [Color(0xFFF15C64), Color(0xFFFC9039)],
    this.confirmColor,
    this.inlineHeader = false,
    this.iconColor = const Color(0xFFFB2C36),
    this.iconBackgroundColor = const Color(0xFFFFF1F2),
    this.iconBorderColor = const Color(0xFFFECACA),
    this.showIconBorder = true,
    this.iconContainerRadius = 16,
    this.iconContainerSize = 52,
    this.titleColor = const Color(0xFF111827),
    this.textColor = const Color(0xFF4B5563),
    this.cancelBorderColor = const Color(0xFFE5E7EB),
    this.cancelTextColor = const Color(0xFF374151),
    this.closeIconColor = const Color(0xFF6B7280),
    this.maxWidth = 520,
    this.width,
    this.height,
    this.borderRadius = 28,
    this.padding = const EdgeInsets.fromLTRB(28, 28, 28, 24),
    this.contentPadding = EdgeInsets.zero,
    this.headerBottomSpacing = 12,
    this.actionsTopSpacing = 28,
    this.actionButtonHeight = 42,
    this.actionSpacing = 12,
    this.forceHorizontalActions = false,
    this.titleStyle,
    this.textStyle,
    this.cancelTextStyle,
    this.confirmTextStyle,
    this.iconSize = 24,
    this.closeButtonSize = 36,
  });

  final String title;
  final Widget content;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final List<Color>? confirmGradient;
  final Color? confirmColor;
  final bool inlineHeader;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color iconBorderColor;
  final bool showIconBorder;
  final double iconContainerRadius;
  final double iconContainerSize;
  final Color titleColor;
  final Color textColor;
  final Color cancelBorderColor;
  final Color cancelTextColor;
  final Color closeIconColor;
  final double maxWidth;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;
  final double headerBottomSpacing;
  final double actionsTopSpacing;
  final double actionButtonHeight;
  final double actionSpacing;
  final bool forceHorizontalActions;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;
  final TextStyle? cancelTextStyle;
  final TextStyle? confirmTextStyle;
  final double iconSize;
  final double closeButtonSize;

  @override
  Widget build(BuildContext context) {
    final effectiveTitleStyle =
        titleStyle ??
        TextStyle(
          color: titleColor,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
        );
    final effectiveTextStyle =
        textStyle ?? TextStyle(color: textColor, fontSize: 15.5, height: 1.5);

    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          minWidth: width ?? 0,
          minHeight: height ?? 0,
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: Padding(
            padding: padding,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stackActions =
                    !forceHorizontalActions && constraints.maxWidth < 420;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (inlineHeader)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _AppConfirmationIcon(
                            icon: icon,
                            iconColor: iconColor,
                            iconBackgroundColor: iconBackgroundColor,
                            iconBorderColor: iconBorderColor,
                            showBorder: showIconBorder,
                            radius: iconContainerRadius,
                            size: iconContainerSize,
                            iconSize: iconSize,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(title, style: effectiveTitleStyle),
                          ),
                          SizedBox(
                            width: closeButtonSize,
                            height: closeButtonSize,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              icon: const Icon(Icons.close_rounded),
                              color: closeIconColor,
                              splashRadius: 18,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AppConfirmationIcon(
                            icon: icon,
                            iconColor: iconColor,
                            iconBackgroundColor: iconBackgroundColor,
                            iconBorderColor: iconBorderColor,
                            showBorder: showIconBorder,
                            radius: iconContainerRadius,
                            size: iconContainerSize,
                            iconSize: iconSize,
                          ),
                          const Spacer(),
                          SizedBox(
                            width: closeButtonSize,
                            height: closeButtonSize,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              icon: const Icon(Icons.close_rounded),
                              color: closeIconColor,
                              splashRadius: 18,
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(title, style: effectiveTitleStyle),
                    ],
                    SizedBox(height: headerBottomSpacing),
                    Padding(
                      padding: contentPadding,
                      child: DefaultTextStyle(
                        style: effectiveTextStyle,
                        child: content,
                      ),
                    ),
                    SizedBox(height: actionsTopSpacing),
                    if (stackActions) ...[
                      _AppConfirmationSecondaryButton(
                        label: cancelLabel,
                        borderColor: cancelBorderColor,
                        textColor: cancelTextColor,
                        textStyle: cancelTextStyle,
                        height: actionButtonHeight,
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      SizedBox(height: actionSpacing),
                      _AppConfirmationPrimaryButton(
                        label: confirmLabel,
                        gradient: confirmGradient,
                        color: confirmColor,
                        textStyle: confirmTextStyle,
                        height: actionButtonHeight,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: _AppConfirmationSecondaryButton(
                              label: cancelLabel,
                              borderColor: cancelBorderColor,
                              textColor: cancelTextColor,
                              textStyle: cancelTextStyle,
                              height: actionButtonHeight,
                              onPressed: () => Navigator.of(context).pop(false),
                            ),
                          ),
                          SizedBox(width: actionSpacing),
                          Expanded(
                            child: _AppConfirmationPrimaryButton(
                              label: confirmLabel,
                              gradient: confirmGradient,
                              color: confirmColor,
                              textStyle: confirmTextStyle,
                              height: actionButtonHeight,
                              onPressed: () => Navigator.of(context).pop(true),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AppConfirmationIcon extends StatelessWidget {
  const _AppConfirmationIcon({
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.iconBorderColor,
    required this.showBorder,
    required this.radius,
    required this.size,
    required this.iconSize,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color iconBorderColor;
  final bool showBorder;
  final double radius;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: iconBackgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: showBorder ? Border.all(color: iconBorderColor) : null,
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}

class _AppConfirmationSecondaryButton extends StatelessWidget {
  const _AppConfirmationSecondaryButton({
    required this.label,
    required this.borderColor,
    required this.textColor,
    required this.textStyle,
    required this.height,
    required this.onPressed,
  });

  final String label;
  final Color borderColor;
  final Color textColor;
  final TextStyle? textStyle;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style:
              textStyle ??
              TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: -0.31,
              ),
        ),
      ),
    );
  }
}

class _AppConfirmationPrimaryButton extends StatelessWidget {
  const _AppConfirmationPrimaryButton({
    required this.label,
    required this.gradient,
    required this.color,
    required this.textStyle,
    required this.height,
    required this.onPressed,
  });

  final String label;
  final List<Color>? gradient;
  final Color? color;
  final TextStyle? textStyle;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: color,
          gradient: gradient == null
              ? null
              : LinearGradient(
                  begin: const Alignment(0.0, 0.5),
                  end: const Alignment(1.0, 0.5),
                  colors: gradient!,
                ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style:
                    textStyle ??
                    const TextStyle(
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
}
