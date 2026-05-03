import 'package:boilerplate/domain/entity/content/content_profile.dart';

/// Hardcoded industries for Template Library UI only. The backend has no industry field.
enum UiContentIndustry {
  technologySaas,
  ecommerce,
  healthcare,
  marketing;

  String get displayName {
    switch (this) {
      case UiContentIndustry.technologySaas:
        return 'Technology/SaaS';
      case UiContentIndustry.ecommerce:
        return 'E-commerce';
      case UiContentIndustry.healthcare:
        return 'Healthcare';
      case UiContentIndustry.marketing:
        return 'Marketing';
    }
  }

  /// Short English label for filter tags (Profiles tab).
  String get tagLabel {
    switch (this) {
      case UiContentIndustry.technologySaas:
        return 'Technology';
      case UiContentIndustry.ecommerce:
        return 'E-commerce';
      case UiContentIndustry.healthcare:
        return 'Healthcare';
      case UiContentIndustry.marketing:
        return 'Marketing';
    }
  }
}

/// Stable UI bucket from profile id (no API field).
UiContentIndustry uiIndustryForContentProfile(ContentProfile profile) {
  var h = 0;
  for (var i = 0; i < profile.id.length; i++) {
    h = 37 * h + profile.id.codeUnitAt(i);
  }
  final idx = h.abs() % UiContentIndustry.values.length;
  return UiContentIndustry.values[idx];
}

List<ContentProfile> profilesInIndustry(
  List<ContentProfile> all,
  UiContentIndustry industry,
) {
  return all.where((p) => uiIndustryForContentProfile(p) == industry).toList();
}

/// `filter == null` means show all profiles.
List<ContentProfile> profilesForTagFilter(
  List<ContentProfile> all,
  UiContentIndustry? filter,
) {
  if (filter == null) return List<ContentProfile>.from(all);
  return profilesInIndustry(all, filter);
}

/// First industry bucket that has at least one profile (for default selection).
UiContentIndustry? firstIndustryWithProfiles(List<ContentProfile> all) {
  for (final industry in UiContentIndustry.values) {
    if (profilesInIndustry(all, industry).isNotEmpty) {
      return industry;
    }
  }
  return null;
}
