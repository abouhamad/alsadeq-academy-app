/// Live branding/config from `GET /api/v2/general-settings` — prefer this
/// over the repo's static general_settings.json snapshot, which is stale
/// boilerplate for the SaaS demo, not this tenant.
class GeneralSettingsModel {
  final String siteTitle;
  final String? logoUrl;
  final String currencySymbol;
  final String currencyCode;
  final String? timeZone;

  const GeneralSettingsModel({
    required this.siteTitle,
    required this.currencySymbol,
    required this.currencyCode,
    this.logoUrl,
    this.timeZone,
  });

  factory GeneralSettingsModel.fromJson(Map<String, dynamic> json) {
    return GeneralSettingsModel(
      siteTitle: (json['site_title'] ?? 'School').toString(),
      logoUrl: json['logo']?.toString(),
      currencySymbol: (json['currency_symbol'] ?? '').toString(),
      currencyCode: (json['currency_code'] ?? '').toString(),
      timeZone: json['time_zone']?.toString(),
    );
  }
}
