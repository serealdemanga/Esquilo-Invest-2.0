import 'package:flutter/material.dart';

import '../app/app_theme.dart';

class PassiveInfoPanel extends StatelessWidget {
  const PassiveInfoPanel({
    super.key,
    required this.child,
    this.accent = AppPalette.textMuted,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
  });

  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.panelAlt.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppPalette.border.withValues(alpha: 0.9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(width: 3, color: accent.withValues(alpha: 0.32)),
              Expanded(
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
