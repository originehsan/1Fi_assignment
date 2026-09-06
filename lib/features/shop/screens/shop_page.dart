import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/placeholder_tab.dart';
import '../../../theme/app_theme.dart';
import '../marketplace/providers/marketplace_provider.dart';
import '../marketplace/screens/marketplace_listing_screen.dart';

/// The Shop tab: a purple hero banner, a segmented control that overlaps
/// its bottom edge, and a search bar shared across all three sub-tabs.
///
/// `ConsumerStatefulWidget` because this widget now owns the shared
/// search `TextEditingController` (a lifecycle-owned UI object — see
/// rules.md Section 2's `StatefulWidget` exception) in addition to its
/// pre-existing `_selectedIndex` UI-navigation state, and needs Riverpod
/// access to forward the Marketplace tab's search text.
class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> {
  // Pure UI-navigation state, not business state — local setState is the
  // documented exception in rules.md Section 2.
  int _selectedIndex = 0;

  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String get _searchHint {
    switch (_selectedIndex) {
      case 0:
        return 'Search online stores...';
      case 1:
        return 'Search nearby stores...';
      default:
        return 'Search marketplace...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                const _ShopHeroBanner(),
                Positioned(
                  bottom: -28,
                  left: 16,
                  right: 16,
                  child: _SegmentedTabs(
                    selectedIndex: _selectedIndex,
                    onSelect: (index) => setState(() => _selectedIndex = index),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  if (_selectedIndex == 2) {
                    ref.read(marketplaceSearchQueryProvider.notifier).state = value;
                  }
                },
                decoration: InputDecoration(
                  hintText: _searchHint,
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  PlaceholderTab(
                    icon: Icons.storefront_outlined,
                    title: 'Top Brands',
                    subtitle: 'No implementation required for this assignment.',
                  ),
                  PlaceholderTab(
                    icon: Icons.location_on_outlined,
                    title: 'Nearby Stores',
                    subtitle: 'No implementation required for this assignment.',
                  ),
                  MarketplaceListingScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Purple gradient banner flush with the top of the screen (no `SafeArea`
/// — its own top padding clears the status bar instead, so the gradient
/// itself paints behind it; see `ShopPage`'s `AnnotatedRegion` for why the
/// status bar icons render light against it).
///
/// Text-only, deliberately: the real banner has a phone/laptop/car
/// illustration, but no such asset exists in this project and fabricating
/// a placeholder graphic would add visual noise with nothing real to
/// match it against — this is a scoped simplification, not an oversight.
class _ShopHeroBanner extends StatelessWidget {
  const _ShopHeroBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.heroBannerGradientStart, AppColors.primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: AppColors.onPrimary),
                SizedBox(width: 6),
                Text(
                  'NO-COST EMIs',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Shop today, Pay later using Mutual funds.',
            style: TextStyle(
              color: AppColors.onPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No credit score required. No interest. Backed by your investments.',
            style: TextStyle(color: AppColors.onPrimary.withValues(alpha: 0.85), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.selectedIndex, required this.onSelect});

  static const _labels = ['Top Brands', 'Nearby Stores', '1Fi Marketplace'];

  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lavenderTint,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(_labels.length, (index) {
          final isSelected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.cardBackground : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.textPrimary.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _labels[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 3,
                      child: isSelected
                          ? Container(
                              width: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
