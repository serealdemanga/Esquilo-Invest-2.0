import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

const int dashboardHomeTabIndex = 0;
const int dashboardIntelligenceTabIndex = 1;
const int dashboardPortfolioTabIndex = 2;
const int dashboardProfileTabIndex = 3;

class DashboardShellBackground extends StatelessWidget {
  const DashboardShellBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[AppPalette.background, AppPalette.backgroundAlt],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -40,
            left: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x22FF6A1F),
                    blurRadius: 90,
                    spreadRadius: 20,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 120,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x186A86FF),
                    blurRadius: 90,
                    spreadRadius: 18,
                  ),
                ],
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class DashboardHeaderBar extends StatelessWidget {
  const DashboardHeaderBar({
    super.key,
    required this.subtitle,
    this.onBack,
    this.trailing,
  });

  final String subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: <Widget>[
          if (onBack != null) ...<Widget>[
            IconButton.filledTonal(
              onPressed: onBack,
              tooltip: 'Voltar',
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 10),
          ],
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppPalette.panelSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.border),
            ),
            child: Image.asset('assets/brand/esquilo.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Esquilo ',
                        style: AppTheme.hudStyle(size: 16),
                      ),
                      TextSpan(
                        text: 'Invest',
                        style: AppTheme.hudStyle(
                          size: 16,
                          weight: FontWeight.w400,
                          color: AppPalette.textPrimary.withValues(alpha: 0.88),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppPalette.textMuted),
                ),
              ],
            ),
          ),
          trailing ?? const SizedBox(width: 46, height: 46),
        ],
      ),
    );
  }
}

class DashboardBottomDock extends StatelessWidget {
  const DashboardBottomDock({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onOpenAi,
  });

  final int selectedIndex;
  final void Function(int index) onSelected;
  final VoidCallback onOpenAi;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppPalette.panel.withValues(alpha: 0.98),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppPalette.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppPalette.shadow,
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              _DockItem(
                label: 'Home',
                icon: Icons.home_rounded,
                selected: selectedIndex == dashboardHomeTabIndex,
                onTap: () => onSelected(dashboardHomeTabIndex),
              ),
              _DockItem(
                label: 'Dashboard',
                icon: Icons.dashboard_customize_rounded,
                selected: selectedIndex == dashboardIntelligenceTabIndex,
                onTap: () => onSelected(dashboardIntelligenceTabIndex),
              ),
              _DockItem(
                label: 'Carteira',
                icon: Icons.account_balance_wallet_rounded,
                selected: selectedIndex == dashboardPortfolioTabIndex,
                onTap: () => onSelected(dashboardPortfolioTabIndex),
              ),
              _DockItem(
                label: 'Esquilo IA',
                icon: Icons.auto_awesome_rounded,
                selected: false,
                onTap: onOpenAi,
                accentWhenIdle: AppPalette.brand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.accentWhenIdle,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color? accentWhenIdle;

  @override
  Widget build(BuildContext context) {
    final color =
        selected
            ? AppPalette.brand
            : accentWhenIdle ?? AppPalette.textMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTheme.tacticalLabel(
                  size: 12,
                  color: color,
                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
