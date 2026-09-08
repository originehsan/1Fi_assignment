import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/placeholder_tab.dart';
import '../../../theme/app_theme.dart';
import '../marketplace/providers/marketplace_provider.dart';
import '../marketplace/screens/marketplace_listing_screen.dart';

/// The Shop tab: a purple hero banner, a segmented control that overlaps
/// its bottom edge, and a search bar shared across all three sub-tabs.
///
/// `ConsumerStatefulWidget` because this widget owns the shared search
/// `TextEditingController` and `FocusNode` (lifecycle-owned UI objects —
/// see rules.md Section 2's `StatefulWidget` exception) in addition to
/// its pre-existing `_selectedIndex` UI-navigation state, and needs
/// Riverpod access to forward the Marketplace tab's search text.
///
/// Also mixes in `WidgetsBindingObserver` solely to detect the on-screen
/// keyboard closing via the system back button/gesture (see
/// `didChangeMetrics` below) — this is view-metrics observation, not
/// business state, so it doesn't implicate rules.md Section 2's Riverpod
/// requirement.
class ShopPage extends ConsumerStatefulWidget {
  const ShopPage({super.key});

  @override
  ConsumerState<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends ConsumerState<ShopPage> with WidgetsBindingObserver {
  // Pure UI-navigation state, not business state — local setState is the
  // documented exception in rules.md Section 2.
  int _selectedIndex = 0;

  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  // Tracks the keyboard's own inset across `didChangeMetrics` calls so it
  // can tell "just closed" (was open, now 0) apart from "hasn't opened
  // yet" (was already 0, still 0) — both read as `viewInsets.bottom == 0`
  // at a single point in time, so only the transition is meaningful. This
  // mirrors the exact pattern Flutter's own `EditableText` uses internally
  // (`_lastBottomViewInset`, see framework source: `editable_text.dart`)
  // — an earlier version of this fix compared only the current value and
  // ended up unfocusing the field the instant it gained focus, since the
  // keyboard-show animation's first metrics tick can still read 0 before
  // the inset has actually risen.
  double _lastBottomInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Bug fix: the on-screen keyboard can be dismissed via the system back
  // button/gesture without the user ever tapping elsewhere on screen.
  // Flutter doesn't clear a TextField's logical focus just because the
  // keyboard closes, so the cursor would otherwise keep blinking after
  // this happens. `didChangeMetrics` fires whenever the view's metrics
  // change, including the keyboard inset changing — this is the same API
  // Flutter's own `EditableText` uses internally to detect keyboard
  // show/hide (see framework source: `editable_text.dart`).
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (!mounted) return;
    final bottomInset = View.of(context).viewInsets.bottom;
    final keyboardJustClosed = _lastBottomInset > 0 && bottomInset == 0;
    if (keyboardJustClosed && _searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
    _lastBottomInset = bottomInset;
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

  // Bug fix: dismisses the search field's focus on a tap anywhere else on
  // the page. This is deliberately NOT wrapped around the search field's
  // own TextField (see the two separate GestureDetectors in build() below
  // rather than one wrapping the whole Column) — wrapping the field
  // itself in this handler was tried first and empirically broke tapping
  // directly into the field: the field's own focus request and this
  // handler's unfocus() land in the same gesture-resolution pass, and
  // unfocus() wins, so the field could never actually gain focus. Every
  // *other* tappable region (banner/segmented-control area, tab content)
  // is still wrapped, so "tap outside the field to dismiss it" still
  // holds everywhere that isn't the field itself.
  void _dismissSearchFocus() => _searchFocusNode.unfocus();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _dismissSearchFocus,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Stack(
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
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
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
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _dismissSearchFocus,
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
          ),
        ],
      ),
    );
  }
}

/// Purple gradient banner that starts below the system status bar, not
/// behind it — `ShopPage` wraps this in a `SafeArea(top: true)` so it
/// naturally clears the actual status bar height on whatever device this
/// runs on, rather than guessing a fixed offset. The status bar itself
/// renders in the system's default style; this app makes no attempt to
/// override its icon color.
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
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
            // InkWell (not a bare GestureDetector) wrapping the entire
            // segment Container below — full Expanded width, and a
            // guaranteed minHeight so the tappable area can never shrink
            // to less than a standard touch target regardless of how
            // tall the label/indicator content happens to measure.
            // borderRadius matches the segment's own visual radius so
            // any ripple clips to the segment's shape.
            child: InkWell(
              onTap: () => onSelect(index),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
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
                        fontWeight: FontWeight.bold,
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
