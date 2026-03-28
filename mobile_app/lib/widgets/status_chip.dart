import 'package:flutter/material.dart';

import '../app/app_theme.dart';

enum StatusChipTone { neutral, info, warning, danger, positive }

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.tone = StatusChipTone.neutral,
  });

  final String label;
  final StatusChipTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = _resolveTone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: palette.background,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTheme.tacticalLabel(size: 11, color: palette.foreground),
      ),
    );
  }

  _ChipPalette _resolveTone(StatusChipTone tone) {
    switch (tone) {
      case StatusChipTone.info:
        return const _ChipPalette(
          foreground: AppPalette.cyan,
          border: Color(0x5538BDF8),
          background: Color(0x1A38BDF8),
        );
      case StatusChipTone.warning:
        return const _ChipPalette(
          foreground: AppPalette.amber,
          border: Color(0x55F59E0B),
          background: Color(0x1AF59E0B),
        );
      case StatusChipTone.danger:
        return const _ChipPalette(
          foreground: AppPalette.red,
          border: Color(0x55FCA5A5),
          background: Color(0x1AFCA5A5),
        );
      case StatusChipTone.positive:
        return const _ChipPalette(
          foreground: AppPalette.green,
          border: Color(0x556EE7B7),
          background: Color(0x1A6EE7B7),
        );
      case StatusChipTone.neutral:
        return const _ChipPalette(
          foreground: AppPalette.textMuted,
          border: AppPalette.border,
          background: AppPalette.panelAlt,
        );
    }
  }
}

class _ChipPalette {
  const _ChipPalette({
    required this.foreground,
    required this.border,
    required this.background,
  });

  final Color foreground;
  final Color border;
  final Color background;
}
