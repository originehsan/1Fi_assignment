import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Generic blank-tab content, used wherever a section of the app is
/// intentionally out of scope for this assignment.
///
/// Lives in `core/widgets/` because it has two real consumers from the
/// start: Shop's own blank sub-tabs (Top Brands, Nearby Stores) and the
/// app shell's top-level blank tabs (Home, EMI Dues, Limit, Profile) — see
/// architecture.md Section 3.
class PlaceholderTab extends StatelessWidget {
  const PlaceholderTab({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Outside the scope of this assignment.')),
                  );
                },
                child: Text(ctaLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
