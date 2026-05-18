import 'package:mitologi_clothing_mobile/core/utils/parser_utils.dart';

class SiteSettingsModel {
  final String? siteName;
  final String? siteTagline;
  final String? siteLogo;
  final String? companyFoundedYear;
  final String? aboutHeadline;
  final String? aboutDescription1;
  final String? aboutDescription2;
  final String? aboutImage;
  final List<GuaranteeItem> guaranteesData;
  final List<GuaranteeBonusItem> garansiBonusData;
  final String? ctaTitle;
  final String? ctaSubtitle;
  final String? ctaButtonText;
  final String? ctaButtonLink;
  final String? contactWhatsapp;
  final String? contactAddress;
  final String? contactPhone;
  final String? contactEmail;
  final String? contactMapsEmbed;
  final String? operatingHoursWeekdayLabel;
  final String? operatingHoursWeekday;
  final String? operatingHoursWeekendLabel;
  final String? operatingHoursWeekend;
  final String? socialInstagram;
  final String? socialTiktok;
  final String? socialFacebook;
  final String? socialShopee;
  final dynamic pricingPlastisolData;
  final dynamic pricingAddonsData;
  final dynamic pricingExtraData;
  final List<PricingFeatureItem> pricingFeaturesData;
  final String? aboutShortHistory;
  final String? visionStatement;
  final String? missionStatement;

  SiteSettingsModel({
    this.siteName,
    this.siteTagline,
    this.siteLogo,
    this.companyFoundedYear,
    this.aboutHeadline,
    this.aboutDescription1,
    this.aboutDescription2,
    this.aboutImage,
    this.guaranteesData = const [],
    this.garansiBonusData = const [],
    this.ctaTitle,
    this.ctaSubtitle,
    this.ctaButtonText,
    this.ctaButtonLink,
    this.contactWhatsapp,
    this.contactAddress,
    this.contactPhone,
    this.contactEmail,
    this.contactMapsEmbed,
    this.operatingHoursWeekdayLabel,
    this.operatingHoursWeekday,
    this.operatingHoursWeekendLabel,
    this.operatingHoursWeekend,
    this.socialInstagram,
    this.socialTiktok,
    this.socialFacebook,
    this.socialShopee,
    this.pricingPlastisolData,
    this.pricingAddonsData,
    this.pricingExtraData,
    this.pricingFeaturesData = const [],
    this.aboutShortHistory,
    this.visionStatement,
    this.missionStatement,
  });

  factory SiteSettingsModel.fromJson(Map<String, dynamic> json) {
    final general = ParserUtils.parseMap(json['general']);
    final about = ParserUtils.parseMap(json['about']);
    final beranda = ParserUtils.parseMap(json['beranda']);
    final contact = ParserUtils.parseMap(json['contact']);

    final guarantees = ParserUtils.parseList<GuaranteeItem>(
      json['guaranteesData'],
      (e) => GuaranteeItem.fromJson(e),
    );

    final garansiBonus = ParserUtils.parseList<GuaranteeBonusItem>(
      beranda['garansiBonusData'] ?? json['garansiBonusData'],
      (e) => GuaranteeBonusItem.fromJson(e),
    );

    final pricingFeatures = ParserUtils.parseList<PricingFeatureItem>(
      beranda['pricingFeaturesData'],
      (e) => PricingFeatureItem.fromJson(e),
    );

    return SiteSettingsModel(
      siteName: general['siteName'] as String?,
      siteTagline: general['siteTagline'] as String?,
      siteLogo: general['siteLogo'] as String?,
      companyFoundedYear: general['companyFoundedYear'] as String? ??
          about['companyFoundedYear'] as String?,
      aboutHeadline: about['aboutHeadline'] as String?,
      aboutDescription1: about['aboutDescription1'] as String?,
      aboutDescription2: about['aboutDescription2'] as String?,
      aboutImage: about['aboutImage'] as String?,
      guaranteesData: guarantees,
      garansiBonusData: garansiBonus,
      ctaTitle: beranda['ctaTitle'] as String?,
      ctaSubtitle: beranda['ctaSubtitle'] as String?,
      ctaButtonText: beranda['ctaButtonText'] as String?,
      ctaButtonLink: beranda['ctaButtonLink'] as String?,
      contactWhatsapp: contact['contactWhatsapp'] as String? ??
          contact['whatsappNumber'] as String?,
      contactAddress: contact['contactAddress'] as String?,
      contactPhone: contact['contactPhone'] as String? ??
          contact['whatsappNumber'] as String?,
      contactEmail: contact['contactEmail'] as String?,
      contactMapsEmbed: contact['contactMapsEmbed'] as String?,
      operatingHoursWeekdayLabel:
          contact['operatingHoursWeekdayLabel'] as String?,
      operatingHoursWeekday: contact['operatingHoursWeekday'] as String?,
      operatingHoursWeekendLabel:
          contact['operatingHoursWeekendLabel'] as String?,
      operatingHoursWeekend: contact['operatingHoursWeekend'] as String?,
      socialInstagram: contact['socialInstagram'] as String?,
      socialTiktok: contact['socialTiktok'] as String?,
      socialFacebook: contact['socialFacebook'] as String?,
      socialShopee: contact['socialShopee'] as String?,
      pricingPlastisolData: beranda['pricingPlastisolData'],
      pricingAddonsData: beranda['pricingAddonsData'],
      pricingExtraData: beranda['pricingExtraData'],
      pricingFeaturesData: pricingFeatures,
      aboutShortHistory: about['aboutShortHistory'] as String?,
      visionStatement: about['visionStatement'] as String?,
      missionStatement: about['missionStatement'] as String?,
    );
  }

  factory SiteSettingsModel.empty() => SiteSettingsModel();

  List<PlastisolPriceItem> get plastisolPricing {
    return ParserUtils.parseList<PlastisolPriceItem>(
      pricingPlastisolData,
      (e) => PlastisolPriceItem.fromJson(e),
    );
  }

  List<PricingAddonItem> get pricingAddons {
    return ParserUtils.parseList<PricingAddonItem>(
      pricingAddonsData,
      (e) => PricingAddonItem.fromJson(e),
    );
  }
}

class GuaranteeItem {
  final String title;
  final String description;

  const GuaranteeItem({required this.title, required this.description});

  factory GuaranteeItem.fromJson(Map<String, dynamic> json) {
    return GuaranteeItem(
      title: json['title'] as String? ?? '',
      description:
          (json['description'] as String?) ?? (json['desc'] as String?) ?? '',
    );
  }
}

class GuaranteeBonusItem {
  final String title;
  final String description;

  const GuaranteeBonusItem({required this.title, required this.description});

  factory GuaranteeBonusItem.fromJson(Map<String, dynamic> json) {
    return GuaranteeBonusItem(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class PricingFeatureItem {
  final String text;

  const PricingFeatureItem({required this.text});

  factory PricingFeatureItem.fromJson(Map<String, dynamic> json) {
    return PricingFeatureItem(text: json['text'] as String? ?? '');
  }
}

class PlastisolPriceItem {
  final String title;
  final String? image;
  final String? price;
  final String? short;
  final String? long;
  final bool popular;
  final String? minOrder;

  const PlastisolPriceItem({
    required this.title,
    this.image,
    this.price,
    this.short,
    this.long,
    this.popular = false,
    this.minOrder,
  });

  factory PlastisolPriceItem.fromJson(Map<String, dynamic> json) {
    return PlastisolPriceItem(
      title: json['title'] as String? ?? '',
      image: json['image'] as String?,
      price: json['price'] as String?,
      short: json['short'] as String?,
      long: json['long'] as String?,
      popular: json['popular'] == true,
      minOrder: (json['minOrder'] as String?) ?? (json['min_order'] as String?),
    );
  }
}

class PricingAddonItem {
  final String name;
  final String price;

  const PricingAddonItem({required this.name, required this.price});

  factory PricingAddonItem.fromJson(Map<String, dynamic> json) {
    return PricingAddonItem(
      name: json['name'] as String? ?? '',
      price: json['price'] as String? ?? '',
    );
  }
}
