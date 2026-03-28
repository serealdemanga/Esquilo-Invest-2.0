import 'package:flutter/material.dart';

import '../app/app_theme.dart';

class TacticalCard extends StatelessWidget {
  const TacticalCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.accent = AppPalette.amber,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.border),
        gradient: LinearGradient(
          colors: <Color>[
            accent.withValues(alpha: 0.08),
            AppPalette.panel,
            const Color(0xFF09111D),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22020617),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: AppTheme.hudStyle(size: 16)),
                    if (subtitle != null &&
                        subtitle!.trim().isNotEmpty) ...<Widget>[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}
