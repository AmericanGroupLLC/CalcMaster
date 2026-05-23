import 'package:flutter/material.dart';

import 'l10n/generated/app_localizations.dart';

/// Translates a Category.id to its localized human label.
/// Used by ConvertCard / ConvertDetail at render time so the const
/// data in lib_units.dart stays simple and locale-agnostic.
String localizedCategoryLabel(BuildContext context, String id) {
  final loc = AppLocalizations.of(context)!;
  switch (id) {
    case 'distance':
      return loc.categoryDistance;
    case 'volume':
      return loc.categoryVolume;
    case 'weight':
      return loc.categoryWeight;
    case 'temperature':
      return loc.categoryTemperature;
    case 'speed':
      return loc.categorySpeed;
    case 'area':
      return loc.categoryArea;
    case 'dataSize':
      return loc.categoryDataSize;
    case 'fuelEconomy':
      return loc.categoryFuelEconomy;
    case 'pressure':
      return loc.categoryPressure;
    case 'energy':
      return loc.categoryEnergy;
    default:
      return id;
  }
}
