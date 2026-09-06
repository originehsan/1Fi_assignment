import 'package:flutter/material.dart';

import 'core/widgets/placeholder_tab.dart';
import 'features/shop/screens/shop_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'EMI Dues'),
          NavigationDestination(icon: Icon(Icons.trending_up_outlined), label: 'Limit'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
