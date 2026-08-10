/// Country data: name, dial code, ISO 3166-1 alpha-2 code, flag SVG path.
class CountryData {
  final String name;
  final String dialCode;
  final String code; // ISO alpha-2
  final String nationality;

  const CountryData({
    required this.name,
    required this.dialCode,
    required this.code,
    required this.nationality,
  });

  String get displayWithDial => '$dialCode  $name';
}

/// Comprehensive list of all countries with their dial codes, flags, and nationalities.
const List<CountryData> allCountries = [
  CountryData(name: 'Afghanistan', dialCode: '+93', code: 'af', nationality: 'Afghan'),
  CountryData(name: 'Albania', dialCode: '+355', code: 'al', nationality: 'Albanian'),
  CountryData(name: 'Algeria', dialCode: '+213', code: 'dz', nationality: 'Algerian'),
  CountryData(name: 'Andorra', dialCode: '+376', code: 'ad', nationality: 'Andorran'),
  CountryData(name: 'Angola', dialCode: '+244', code: 'ao', nationality: 'Angolan'),
  CountryData(name: 'Argentina', dialCode: '+54', code: 'ar', nationality: 'Argentine'),
  CountryData(name: 'Armenia', dialCode: '+374', code: 'am', nationality: 'Armenian'),
  CountryData(name: 'Australia', dialCode: '+61', code: 'au', nationality: 'Australian'),
  CountryData(name: 'Austria', dialCode: '+43', code: 'at', nationality: 'Austrian'),
  CountryData(name: 'Azerbaijan', dialCode: '+994', code: 'az', nationality: 'Azerbaijani'),
  CountryData(name: 'Bahrain', dialCode: '+973', code: 'bh', nationality: 'Bahraini'),
  CountryData(name: 'Bangladesh', dialCode: '+880', code: 'bd', nationality: 'Bangladeshi'),
  CountryData(name: 'Belarus', dialCode: '+375', code: 'by', nationality: 'Belarusian'),
  CountryData(name: 'Belgium', dialCode: '+32', code: 'be', nationality: 'Belgian'),
  CountryData(name: 'Brazil', dialCode: '+55', code: 'br', nationality: 'Brazilian'),
  CountryData(name: 'Brunei', dialCode: '+673', code: 'bn', nationality: 'Bruneian'),
  CountryData(name: 'Bulgaria', dialCode: '+359', code: 'bg', nationality: 'Bulgarian'),
  CountryData(name: 'Cambodia', dialCode: '+855', code: 'kh', nationality: 'Cambodian'),
  CountryData(name: 'Cameroon', dialCode: '+237', code: 'cm', nationality: 'Cameroonian'),
  CountryData(name: 'Canada', dialCode: '+1', code: 'ca', nationality: 'Canadian'),
  CountryData(name: 'Chad', dialCode: '+235', code: 'td', nationality: 'Chadian'),
  CountryData(name: 'Chile', dialCode: '+56', code: 'cl', nationality: 'Chilean'),
  CountryData(name: 'China', dialCode: '+86', code: 'cn', nationality: 'Chinese'),
  CountryData(name: 'Colombia', dialCode: '+57', code: 'co', nationality: 'Colombian'),
  CountryData(name: 'Congo', dialCode: '+242', code: 'cg', nationality: 'Congolese'),
  CountryData(name: 'Costa Rica', dialCode: '+506', code: 'cr', nationality: 'Costa Rican'),
  CountryData(name: 'Croatia', dialCode: '+385', code: 'hr', nationality: 'Croatian'),
  CountryData(name: 'Cuba', dialCode: '+53', code: 'cu', nationality: 'Cuban'),
  CountryData(name: 'Cyprus', dialCode: '+357', code: 'cy', nationality: 'Cypriot'),
  CountryData(name: 'Czech Republic', dialCode: '+420', code: 'cz', nationality: 'Czech'),
  CountryData(name: 'Denmark', dialCode: '+45', code: 'dk', nationality: 'Danish'),
  CountryData(name: 'Dominican Republic', dialCode: '+1', code: 'do', nationality: 'Dominican'),
  CountryData(name: 'Ecuador', dialCode: '+593', code: 'ec', nationality: 'Ecuadorian'),
  CountryData(name: 'Egypt', dialCode: '+20', code: 'eg', nationality: 'Egyptian'),
  CountryData(name: 'Estonia', dialCode: '+372', code: 'ee', nationality: 'Estonian'),
  CountryData(name: 'Ethiopia', dialCode: '+251', code: 'et', nationality: 'Ethiopian'),
  CountryData(name: 'Finland', dialCode: '+358', code: 'fi', nationality: 'Finnish'),
  CountryData(name: 'France', dialCode: '+33', code: 'fr', nationality: 'French'),
  CountryData(name: 'Georgia', dialCode: '+995', code: 'ge', nationality: 'Georgian'),
  CountryData(name: 'Germany', dialCode: '+49', code: 'de', nationality: 'German'),
  CountryData(name: 'Ghana', dialCode: '+233', code: 'gh', nationality: 'Ghanaian'),
  CountryData(name: 'Greece', dialCode: '+30', code: 'gr', nationality: 'Greek'),
  CountryData(name: 'Hong Kong', dialCode: '+852', code: 'hk', nationality: 'Hong Konger'),
  CountryData(name: 'Hungary', dialCode: '+36', code: 'hu', nationality: 'Hungarian'),
  CountryData(name: 'Iceland', dialCode: '+354', code: 'is', nationality: 'Icelandic'),
  CountryData(name: 'India', dialCode: '+91', code: 'in', nationality: 'Indian'),
  CountryData(name: 'Indonesia', dialCode: '+62', code: 'id', nationality: 'Indonesian'),
  CountryData(name: 'Iran', dialCode: '+98', code: 'ir', nationality: 'Iranian'),
  CountryData(name: 'Iraq', dialCode: '+964', code: 'iq', nationality: 'Iraqi'),
  CountryData(name: 'Ireland', dialCode: '+353', code: 'ie', nationality: 'Irish'),
  CountryData(name: 'Israel', dialCode: '+972', code: 'il', nationality: 'Israeli'),
  CountryData(name: 'Italy', dialCode: '+39', code: 'it', nationality: 'Italian'),
  CountryData(name: 'Japan', dialCode: '+81', code: 'jp', nationality: 'Japanese'),
  CountryData(name: 'Jordan', dialCode: '+962', code: 'jo', nationality: 'Jordanian'),
  CountryData(name: 'Kazakhstan', dialCode: '+7', code: 'kz', nationality: 'Kazakh'),
  CountryData(name: 'Kenya', dialCode: '+254', code: 'ke', nationality: 'Kenyan'),
  CountryData(name: 'Kuwait', dialCode: '+965', code: 'kw', nationality: 'Kuwaiti'),
  CountryData(name: 'Kyrgyzstan', dialCode: '+996', code: 'kg', nationality: 'Kyrgyz'),
  CountryData(name: 'Laos', dialCode: '+856', code: 'la', nationality: 'Laotian'),
  CountryData(name: 'Latvia', dialCode: '+371', code: 'lv', nationality: 'Latvian'),
  CountryData(name: 'Lebanon', dialCode: '+961', code: 'lb', nationality: 'Lebanese'),
  CountryData(name: 'Libya', dialCode: '+218', code: 'ly', nationality: 'Libyan'),
  CountryData(name: 'Lithuania', dialCode: '+370', code: 'lt', nationality: 'Lithuanian'),
  CountryData(name: 'Luxembourg', dialCode: '+352', code: 'lu', nationality: 'Luxembourger'),
  CountryData(name: 'Malaysia', dialCode: '+60', code: 'my', nationality: 'Malaysian'),
  CountryData(name: 'Maldives', dialCode: '+960', code: 'mv', nationality: 'Maldivian'),
  CountryData(name: 'Malta', dialCode: '+356', code: 'mt', nationality: 'Maltese'),
  CountryData(name: 'Mauritius', dialCode: '+230', code: 'mu', nationality: 'Mauritian'),
  CountryData(name: 'Mexico', dialCode: '+52', code: 'mx', nationality: 'Mexican'),
  CountryData(name: 'Moldova', dialCode: '+373', code: 'md', nationality: 'Moldovan'),
  CountryData(name: 'Monaco', dialCode: '+377', code: 'mc', nationality: 'Monegasque'),
  CountryData(name: 'Mongolia', dialCode: '+976', code: 'mn', nationality: 'Mongolian'),
  CountryData(name: 'Montenegro', dialCode: '+382', code: 'me', nationality: 'Montenegrin'),
  CountryData(name: 'Morocco', dialCode: '+212', code: 'ma', nationality: 'Moroccan'),
  CountryData(name: 'Myanmar', dialCode: '+95', code: 'mm', nationality: 'Burmese'),
  CountryData(name: 'Namibia', dialCode: '+264', code: 'na', nationality: 'Namibian'),
  CountryData(name: 'Nepal', dialCode: '+977', code: 'np', nationality: 'Nepali'),
  CountryData(name: 'Netherlands', dialCode: '+31', code: 'nl', nationality: 'Dutch'),
  CountryData(name: 'New Zealand', dialCode: '+64', code: 'nz', nationality: 'New Zealander'),
  CountryData(name: 'Nigeria', dialCode: '+234', code: 'ng', nationality: 'Nigerian'),
  CountryData(name: 'North Korea', dialCode: '+850', code: 'kp', nationality: 'North Korean'),
  CountryData(name: 'North Macedonia', dialCode: '+389', code: 'mk', nationality: 'Macedonian'),
  CountryData(name: 'Norway', dialCode: '+47', code: 'no', nationality: 'Norwegian'),
  CountryData(name: 'Oman', dialCode: '+968', code: 'om', nationality: 'Omani'),
  CountryData(name: 'Pakistan', dialCode: '+92', code: 'pk', nationality: 'Pakistani'),
  CountryData(name: 'Palestine', dialCode: '+970', code: 'ps', nationality: 'Palestinian'),
  CountryData(name: 'Peru', dialCode: '+51', code: 'pe', nationality: 'Peruvian'),
  CountryData(name: 'Philippines', dialCode: '+63', code: 'ph', nationality: 'Filipino'),
  CountryData(name: 'Poland', dialCode: '+48', code: 'pl', nationality: 'Polish'),
  CountryData(name: 'Portugal', dialCode: '+351', code: 'pt', nationality: 'Portuguese'),
  CountryData(name: 'Qatar', dialCode: '+974', code: 'qa', nationality: 'Qatari'),
  CountryData(name: 'Romania', dialCode: '+40', code: 'ro', nationality: 'Romanian'),
  CountryData(name: 'Russia', dialCode: '+7', code: 'ru', nationality: 'Russian'),
  CountryData(name: 'Saudi Arabia', dialCode: '+966', code: 'sa', nationality: 'Saudi'),
  CountryData(name: 'Senegal', dialCode: '+221', code: 'sn', nationality: 'Senegalese'),
  CountryData(name: 'Serbia', dialCode: '+381', code: 'rs', nationality: 'Serbian'),
  CountryData(name: 'Singapore', dialCode: '+65', code: 'sg', nationality: 'Singaporean'),
  CountryData(name: 'Slovakia', dialCode: '+421', code: 'sk', nationality: 'Slovak'),
  CountryData(name: 'Slovenia', dialCode: '+386', code: 'si', nationality: 'Slovenian'),
  CountryData(name: 'Somalia', dialCode: '+252', code: 'so', nationality: 'Somali'),
  CountryData(name: 'South Africa', dialCode: '+27', code: 'za', nationality: 'South African'),
  CountryData(name: 'South Korea', dialCode: '+82', code: 'kr', nationality: 'South Korean'),
  CountryData(name: 'Spain', dialCode: '+34', code: 'es', nationality: 'Spanish'),
  CountryData(name: 'Sri Lanka', dialCode: '+94', code: 'lk', nationality: 'Sri Lankan'),
  CountryData(name: 'Sudan', dialCode: '+249', code: 'sd', nationality: 'Sudanese'),
  CountryData(name: 'Sweden', dialCode: '+46', code: 'se', nationality: 'Swedish'),
  CountryData(name: 'Switzerland', dialCode: '+41', code: 'ch', nationality: 'Swiss'),
  CountryData(name: 'Syria', dialCode: '+963', code: 'sy', nationality: 'Syrian'),
  CountryData(name: 'Taiwan', dialCode: '+886', code: 'tw', nationality: 'Taiwanese'),
  CountryData(name: 'Tajikistan', dialCode: '+992', code: 'tj', nationality: 'Tajik'),
  CountryData(name: 'Tanzania', dialCode: '+255', code: 'tz', nationality: 'Tanzanian'),
  CountryData(name: 'Thailand', dialCode: '+66', code: 'th', nationality: 'Thai'),
  CountryData(name: 'Tunisia', dialCode: '+216', code: 'tn', nationality: 'Tunisian'),
  CountryData(name: 'Turkey', dialCode: '+90', code: 'tr', nationality: 'Turkish'),
  CountryData(name: 'Turkmenistan', dialCode: '+993', code: 'tm', nationality: 'Turkmen'),
  CountryData(name: 'Uganda', dialCode: '+256', code: 'ug', nationality: 'Ugandan'),
  CountryData(name: 'Ukraine', dialCode: '+380', code: 'ua', nationality: 'Ukrainian'),
  CountryData(name: 'United Arab Emirates', dialCode: '+971', code: 'ae', nationality: 'Emirati'),
  CountryData(name: 'United Kingdom', dialCode: '+44', code: 'gb', nationality: 'British'),
  CountryData(name: 'United States', dialCode: '+1', code: 'us', nationality: 'American'),
  CountryData(name: 'Uruguay', dialCode: '+598', code: 'uy', nationality: 'Uruguayan'),
  CountryData(name: 'Uzbekistan', dialCode: '+998', code: 'uz', nationality: 'Uzbek'),
  CountryData(name: 'Venezuela', dialCode: '+58', code: 've', nationality: 'Venezuelan'),
  CountryData(name: 'Vietnam', dialCode: '+84', code: 'vn', nationality: 'Vietnamese'),
  CountryData(name: 'Yemen', dialCode: '+967', code: 'ye', nationality: 'Yemeni'),
  CountryData(name: 'Zambia', dialCode: '+260', code: 'zm', nationality: 'Zambian'),
  CountryData(name: 'Zimbabwe', dialCode: '+263', code: 'zw', nationality: 'Zimbabwean'),
];

/// Find a country by its ISO alpha-2 code.
CountryData? countryByCode(String code) {
  try {
    return allCountries.firstWhere(
      (c) => c.code == code.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
}

/// Find a country by its dial code.
CountryData? countryByDialCode(String dialCode) {
  try {
    return allCountries.firstWhere(
      (c) => c.dialCode == dialCode,
    );
  } catch (_) {
    return null;
  }
}