import 'package:flutter/material.dart';

import 'core/widgets/placeholder_tab.dart';
import 'features/shop/screens/shop_page.dart';
import 'theme/app_theme.dart';

/// Top-level 5-tab bottom navigation shell, so the app resembles 1Fi's
/// real 5-tab structure. Only the Shop tab's Marketplace section is
/// actually implemented — everything else is an explicit placeholder, per
/// architecture.md Section 15.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  // Pure UI-navigation state, not business state — local setState is the
  // documented exception in rules.md Section 2.
  int _currentIndex = 1;

  static const _tabs = [
    PlaceholderTab(
      icon: Icons.home_outlined,
      title: 'Home',
      subtitle: 'Your 1Fi dashboard will live here.',
    ),
    ShopPage(),
    PlaceholderTab(
      icon: Icons.receipt_long_outlined,
      title: 'Nothing due yet',
      subtitle: "Looks like you haven't shopped yet with 1Fi",
      ctaLabel: 'Check eligibility',
    ),
    PlaceholderTab(
      icon: Icons.trending_up_outlined,
      title: 'Limit',
      subtitle: 'Unlock your limit to see it here.',
    ),
    PlaceholderTab(
      icon: Icons.person_outline,
      title: 'Profile',
      subtitle: 'Your profile details will live here.',
    ),
  ];

  static const _destinations = [
    _NavDestinationData(icon: Icons.home_outlined, label: 'Home'),
    _NavDestinationData(icon: Icons.storefront_outlined, label: 'Shop'),
    _NavDestinationData(icon: Icons.receipt_long_outlined, label: 'EMI Dues'),
    _NavDestinationData(icon: Icons.trending_up_outlined, label: 'Limit'),
    _NavDestinationData(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: _FloatingBottomNav(
        selectedIndex: _currentIndex,
        onSelect: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

/// One bottom-nav destination's static icon/label pair. Kept separate from
/// selection state so `_AppShellState._destinations` stays a plain const
/// list — icon/label choice never changes with selection, only color does.
class _NavDestinationData {
  const _NavDestinationData({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Floating pill-shaped bottom nav bar, replacing Flutter's default
/// Material `NavigationBar`. Matches the real 1Fi app (confirmed from
/// screenshots): a white bar with left/right/bottom margins and a soft
/// shadow, where the selected tab is marked by a short colored line above
/// its icon rather than the default filled-background selection shape.
/// Single consumer (`_AppShellState`) — stays private to this file per
/// rules.md's widget-reuse rule.
class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({required this.selectedIndex, required this.onSelect});

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var index = 0; index < _AppShellState._destinations.length; index++)
              Expanded(
                child: _NavItem(
                  data: _AppShellState._destinations[index],
                  selected: selectedIndex == index,
                  onTap: () => onSelect(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.data, required this.selected, required this.onTap});

  final _NavDestinationData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed-height reservation so unselected items don't shift when
          // selection changes — same pattern already used for the Shop
          // page's segmented-control underline.
          SizedBox(
            height: 4,
            child: selected
                ? Center(
                    child: Container(
                      width: 20,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Icon(data.icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
