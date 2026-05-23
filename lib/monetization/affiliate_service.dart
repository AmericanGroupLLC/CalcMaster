import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../lib_currency.dart';
import 'analytics_service.dart';
import 'monetization_config.dart';

/// Catalogue of affiliate slots and their per-region URLs. The keys are stable
/// `slot` IDs that double as analytics tags. When a region-specific URL isn't
/// configured, falls back to the US URL — and ultimately to a generic search
/// URL — so the CTAs always work even before deals are signed.
class AffiliateService {
  static final AffiliateService instance = AffiliateService._();
  AffiliateService._();

  /// Returns the best URL to launch for the given slot + current region,
  /// already augmented with the appropriate affiliate tag when present.
  Uri urlFor(String slot, RegionId region) {
    final base = _baseUrls[slot] ?? _baseUrls['_fallback']!;
    final tag = _amazonTagFor(region);
    if (tag.isEmpty) return Uri.parse(base);
    final separator = base.contains('?') ? '&' : '?';
    return Uri.parse('$base${separator}tag=$tag');
  }

  String _amazonTagFor(RegionId region) {
    switch (region) {
      case RegionId.US:
        return MonetizationConfig.amazonAssociatesTagUS;
      case RegionId.UK:
        return MonetizationConfig.amazonAssociatesTagUK;
      case RegionId.IN:
        return MonetizationConfig.amazonAssociatesTagIN;
      default:
        return MonetizationConfig.amazonAssociatesTagUS;
    }
  }

  Future<bool> open(BuildContext context, String slot, RegionId region) async {
    AnalyticsService.instance.logAffiliateClick('amazon', slot, region.name);
    final uri = urlFor(slot, region);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link.')),
        );
      }
      return false;
    }
  }

  // Slot URLs are sourced from the single MonetizationConfig file so launch-day
  // updates touch only one place.
  static Map<String, String> get _baseUrls => MonetizationConfig.affiliateSlots;
}
