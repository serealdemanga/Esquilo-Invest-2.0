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
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: palette.foreground,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            label,
            style: AppTheme.tacticalLabel(
              size: 11,
              color: palette.foreground,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _ChipPalette _resolveTone(StatusChipTone tone) {
    switch (tone) {
      case StatusChipTone.info:
        return const _ChipPalette(
          foreground: AppPalette.cobalt,
          border: Color(0x306A86FF),
          background: Color(0x106A86FF),
        );
      case StatusChipTone.warning:
        return const _ChipPalette(
          foreground: AppPalette.gold,
          border: Color(0x30F0B74A),
          background: Color(0x10F0B74A),
        );
      case StatusChipTone.danger:
        return const _ChipPalette(
          foreground: AppPalette.red,
          border: Color(0x30FF6C62),
          background: Color(0x10FF6C62),
        );
      case StatusChipTone.positive:
        return const _ChipPalette(
          foreground: AppPalette.green,
          border: Color(0x304FD38C),
          background: Color(0x104FD38C),
        );
      case StatusChipTone.neutral:
        return const _ChipPalette(
          foreground: AppPalette.textMuted,
          border: Color(0x24F8E7D8),
          background: Color(0x16181E2B),
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
